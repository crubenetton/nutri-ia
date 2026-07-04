import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class BackendAIResponse {
  final bool ok;
  final String answer;
  final Map<String, dynamic> raw;

  const BackendAIResponse({
    required this.ok,
    required this.answer,
    required this.raw,
  });
}

class BackendAIClient {
  static const String projectId = 'nutri-ia-ded99';
  static const String region = 'us-central1';

  static String get coachUrl => 'https://$region-$projectId.cloudfunctions.net/coachAI';
  static String get photoUrl => 'https://$region-$projectId.cloudfunctions.net/photoAI';

  static Future<BackendAIResponse> askCoach(String question) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    if (token == null) {
      return const BackendAIResponse(
        ok: false,
        answer: 'Você precisa estar logado para usar a IA.',
        raw: {},
      );
    }

    try {
      final response = await http.post(
        Uri.parse(coachUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'question': question}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return BackendAIResponse(
        ok: data['ok'] == true,
        answer: (data['answer'] ?? data['error'] ?? 'Sem resposta').toString(),
        raw: data,
      );
    } catch (e) {
      return BackendAIResponse(
        ok: false,
        answer: 'Backend IA ainda não está publicado ou houve erro: $e',
        raw: {},
      );
    }
  }

  static Future<Map<String, dynamic>> analyzePhotoHint(String hint) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    if (token == null) return {'ok': false, 'error': 'Usuário não logado'};

    try {
      final response = await http.post(
        Uri.parse(photoUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'hint': hint}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'ok': false, 'error': 'Backend IA ainda não publicado: $e'};
    }
  }
}
