import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../about/about_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await AuthService().signIn(email: email.text, password: password.text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao entrar: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> forgotPassword() async {
    if (email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite seu e-mail primeiro.')));
      return;
    }

    try {
      await AuthService().resetPassword(email.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail de recuperação enviado.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar recuperação: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.health_and_safety, size: 80, color: Color(0xFF22C55E)),
              const SizedBox(height: 18),
              const Text('Nutri IA', textAlign: TextAlign.center, style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Seu assistente inteligente de alimentação, água, remédios e saúde.', textAlign: TextAlign.center),
              const SizedBox(height: 30),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'E-mail')),
              const SizedBox(height: 12),
              TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha'), onSubmitted: (_) => login()),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: loading ? null : login,
                icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login),
                label: const Text('Entrar'),
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: forgotPassword, child: const Text('Esqueci minha senha')),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text('Criar minha conta'),
              ),
              const SizedBox(height: 22),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              const Text('Desenvolvido por', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 4),
              const Text('Cru Benetton®', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8)),
              const SizedBox(height: 4),
              const Text('Versão 1.0.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
                child: const Text('Sobre o Nutri IA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
