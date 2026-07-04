class V1CompletionItem {
  final String module;
  final int percent;
  final String nextStep;

  const V1CompletionItem({
    required this.module,
    required this.percent,
    required this.nextStep,
  });
}

class V1CompletionService {
  static const items = <V1CompletionItem>[
    V1CompletionItem(module: 'Login e usuários', percent: 100, nextStep: 'Manter estável.'),
    V1CompletionItem(module: 'Perfil inteligente', percent: 90, nextStep: 'Validar todos os campos e melhorar onboarding.'),
    V1CompletionItem(module: 'Diário alimentar', percent: 88, nextStep: 'Melhorar banco de alimentos e porções.'),
    V1CompletionItem(module: 'Água', percent: 88, nextStep: 'Adicionar lembretes locais quando possível.'),
    V1CompletionItem(module: 'Exercícios', percent: 90, nextStep: 'Ajustar gasto por peso e intensidade.'),
    V1CompletionItem(module: 'Medicamentos', percent: 85, nextStep: 'Criar alertas e histórico diário.'),
    V1CompletionItem(module: 'Evolução corporal', percent: 80, nextStep: 'Adicionar gráficos e fotos.'),
    V1CompletionItem(module: 'Dashboard', percent: 88, nextStep: 'Adicionar gráficos pequenos e tendência.'),
    V1CompletionItem(module: 'Relatórios', percent: 75, nextStep: 'Criar gráficos semanais/mensais.'),
    V1CompletionItem(module: 'Coach IA local', percent: 55, nextStep: 'Melhorar respostas com mais contexto.'),
    V1CompletionItem(module: 'Foto IA sem Blaze', percent: 35, nextStep: 'Melhorar estimativa com dica e banco alimentar.'),
  ];

  static int overall() {
    final total = items.fold<int>(0, (sum, item) => sum + item.percent);
    return (total / items.length).round();
  }
}
