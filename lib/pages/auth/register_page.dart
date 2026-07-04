import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../onboarding/wizard_onboarding_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool loading = false;
  bool acceptedTerms = false;
  bool receiveTips = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final cleanName = name.text.trim();
    final cleanEmail = email.text.trim();
    final cleanPassword = password.text.trim();
    final cleanConfirmPassword = confirmPassword.text.trim();

    if (cleanName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite seu nome.')));
      return;
    }

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Digite um e-mail válido.')));
      return;
    }

    if (cleanPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A senha precisa ter pelo menos 6 caracteres.')));
      return;
    }

    if (cleanPassword != cleanConfirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As senhas não conferem.')));
      return;
    }

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você precisa aceitar os termos para criar sua conta.')));
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService().register(
        name: cleanName,
        email: cleanEmail,
        password: cleanPassword,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WizardOnboardingPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.health_and_safety, size: 68, color: Color(0xFF22C55E)),
              const SizedBox(height: 14),
              const Text(
                'Vamos começar seu acompanhamento',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Crie sua conta e depois informe seus dados para o Nutri IA montar metas personalizadas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(.70)),
              ),
              const SizedBox(height: 22),

              TextField(
                controller: name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: password,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar senha',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                onSubmitted: (_) => register(),
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                value: acceptedTerms,
                onChanged: loading ? null : (value) => setState(() => acceptedTerms = value ?? false),
                title: const Text('Aceito os termos de uso e a política de privacidade'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: receiveTips,
                onChanged: loading ? null : (value) => setState(() => receiveTips = value ?? true),
                title: const Text('Quero receber dicas de saúde e lembretes inteligentes'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: loading ? null : register,
                icon: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.arrow_forward),
                label: const Text('Criar conta e continuar'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(context),
                child: const Text('Já tenho conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
