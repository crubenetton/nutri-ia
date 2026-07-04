const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

function cors(res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
}

async function verifyUser(req) {
  const authHeader = req.headers.authorization || "";
  if (!authHeader.startsWith("Bearer ")) throw new Error("missing-auth-token");
  const token = authHeader.substring(7);
  const decoded = await admin.auth().verifyIdToken(token);
  return decoded.uid;
}

async function getUserContext(uid) {
  const userRef = db.collection("users").doc(uid);
  const userSnap = await userRef.get();
  const user = userSnap.exists ? userSnap.data() : {};

  const today = new Date();
  const start = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const end = new Date(start);
  end.setDate(end.getDate() + 1);

  const mealsSnap = await userRef.collection("meals")
    .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(start))
    .where("createdAt", "<", admin.firestore.Timestamp.fromDate(end))
    .get();

  const exercisesSnap = await userRef.collection("exercises")
    .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(start))
    .where("createdAt", "<", admin.firestore.Timestamp.fromDate(end))
    .get();

  let consumedCalories = 0;
  let protein = 0;
  mealsSnap.forEach((doc) => {
    const d = doc.data();
    consumedCalories += Number(d.calories || 0);
    protein += Number(d.protein || 0);
  });

  let exerciseCalories = 0;
  exercisesSnap.forEach((doc) => {
    exerciseCalories += Number(doc.data().calories || 0);
  });

  return {
    user,
    day: {
      consumedCalories,
      protein,
      exerciseCalories,
      targetCalories: Number(user.dailyGoalCalories || 2200),
      proteinTarget: Number(user.proteinGoalGrams || 130),
      waterConsumedLiters: Number(user.waterMlToday || 0) / 1000,
      waterTargetLiters: Number(user.waterGoalLiters || 2.9)
    }
  };
}

function localCoachAnswer(question, context) {
  const q = String(question || "").toLowerCase();
  const day = context.day || {};
  const available = (day.targetCalories || 2200) + (day.exerciseCalories || 0) - (day.consumedCalories || 0);
  const proteinMissing = Math.max(0, (day.proteinTarget || 130) - (day.protein || 0));
  const waterMissing = Math.max(0, (day.waterTargetLiters || 2.9) - (day.waterConsumedLiters || 0));

  if (q.includes("pizza")) {
    if (available >= 800) return `Pode comer pizza hoje. Você ainda tem cerca de ${available} kcal disponíveis. Minha sugestão: 2 fatias e água.`;
    if (available >= 450) return `Dá para encaixar pizza, mas com controle: 1 ou 2 fatias. Você tem cerca de ${available} kcal livres.`;
    return "Hoje está apertado para pizza. Se quiser muito, coma pouco e priorize proteína no restante do dia.";
  }

  if (q.includes("hamburg") || q.includes("lanche")) {
    if (available >= 700) return "Pode encaixar um hambúrguer hoje. Evite batata frita grande e refrigerante para não passar da meta.";
    return "Hoje não está ideal para hambúrguer. Melhor escolher algo com mais proteína e menos gordura.";
  }

  if (q.includes("prote")) return `Faltam cerca de ${proteinMissing} g de proteína. Boas opções: ovos, frango, whey, iogurte ou carne.`;
  if (q.includes("agua") || q.includes("água")) return `Faltam cerca de ${waterMissing.toFixed(1)} L de água hoje. Beba aos poucos, começando com um copo agora.`;
  if (q.includes("jantar") || q.includes("noite")) {
    if (proteinMissing > 30) return `Para jantar, priorize proteína. Ainda faltam ${proteinMissing} g.`;
    if (available > 600) return `Você pode jantar bem. Sugestão: arroz com frango/carne e água. Ainda tem cerca de ${available} kcal.`;
    return "Faça uma janta leve hoje: ovos, frango, iogurte ou whey.";
  }

  return `Resumo do dia: você tem cerca de ${available} kcal disponíveis, faltam ${proteinMissing} g de proteína e ${waterMissing.toFixed(1)} L de água.`;
}

exports.coachAI = functions.https.onRequest(async (req, res) => {
  cors(res);
  if (req.method === "OPTIONS") return res.status(204).send("");
  if (req.method !== "POST") return res.status(405).json({error: "method-not-allowed"});

  try {
    const uid = await verifyUser(req);
    const question = req.body.question || "";
    const context = await getUserContext(uid);
    const answer = localCoachAnswer(question, context);

    await db.collection("users").doc(uid).collection("aiChats").add({
      question,
      answer,
      type: "coach",
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return res.json({ok: true, provider: "local-backend-ready-for-gemini", answer});
  } catch (error) {
    console.error(error);
    return res.status(401).json({ok: false, error: String(error.message || error)});
  }
});

exports.photoAI = functions.https.onRequest(async (req, res) => {
  cors(res);
  if (req.method === "OPTIONS") return res.status(204).send("");
  if (req.method !== "POST") return res.status(405).json({error: "method-not-allowed"});

  try {
    const uid = await verifyUser(req);
    const hint = String(req.body.hint || "").toLowerCase();

    let result = {
      title: "Refeição estimada",
      calories: 400,
      protein: 20,
      carbs: 45,
      fat: 15,
      confidence: 55,
      description: "Estimativa inicial do backend. Próximo passo: conectar Gemini Vision."
    };

    if (hint.includes("pizza")) result = {title:"Pizza", calories:620, protein:24, carbs:62, fat:30, confidence:86, description:"Estimativa para 2 fatias médias."};
    else if (hint.includes("arroz") && hint.includes("frango")) result = {title:"Arroz com frango", calories:520, protein:42, carbs:55, fat:12, confidence:82, description:"Estimativa para prato com arroz e frango."};
    else if (hint.includes("hamb")) result = {title:"Hambúrguer", calories:700, protein:35, carbs:48, fat:38, confidence:78, description:"Estimativa para hambúrguer médio."};

    await db.collection("users").doc(uid).collection("photoAnalyses").add({
      hint,
      result,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return res.json({ok: true, provider: "local-backend-ready-for-vision", result});
  } catch (error) {
    console.error(error);
    return res.status(401).json({ok: false, error: String(error.message || error)});
  }
});
