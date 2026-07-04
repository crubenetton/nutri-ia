import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../services/nutri_database.dart';
import '../../services/photo_food_analysis_service.dart';

class AIPhotoPage extends StatefulWidget {
  const AIPhotoPage({super.key});

  @override
  State<AIPhotoPage> createState() => _AIPhotoPageState();
}

class _AIPhotoPageState extends State<AIPhotoPage> {
  final hint = TextEditingController();
  Uint8List? imageBytes;
  String fileName = '';
  PhotoFoodResult? baseResult;
  double multiplier = 1.0;
  bool saving = false;

  PhotoFoodResult? get adjustedResult => baseResult?.multiplied(multiplier);

  Future<void> pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        final bytes = reader.result as Uint8List;

        setState(() {
          imageBytes = bytes;
          fileName = file.name;
          baseResult = PhotoFoodAnalysisService.analyze(
            fileName: fileName,
            hint: hint.text,
          );
          multiplier = 1.0;
        });
      });
    });
  }

  void analyzeAgain() {
    setState(() {
      baseResult = PhotoFoodAnalysisService.analyze(
        fileName: fileName,
        hint: hint.text,
      );
      multiplier = 1.0;
    });
  }

  Future<void> saveMeal() async {
    final result = adjustedResult;
    if (result == null) return;

    setState(() => saving = true);

    try {
      await NutriDatabase().addMeal(
        name: '${result.title} - Foto IA',
        calories: result.calories,
        protein: result.protein,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refeição da foto salva no diário.')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget preset(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        hint.text = text;
        analyzeAgain();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = adjustedResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto IA'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Analisar comida por foto',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha uma foto e escreva uma dica opcional para melhorar a estimativa. A próxima etapa será conectar IA visual real via backend seguro.',
            style: TextStyle(color: Colors.white.withOpacity(.75)),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Escolher foto da comida'),
          ),
          if (imageBytes != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.memory(
                imageBytes!,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fileName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: hint,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Dica sobre a foto',
              hintText: 'Ex: arroz com frango / pizza 2 fatias / pão com ovos',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: analyzeAgain,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Analisar novamente'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              preset('pizza 2 fatias'),
              preset('arroz com frango'),
              preset('pão com ovos'),
              preset('hambúrguer'),
              preset('banana'),
              preset('whey'),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultado da Foto IA',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('🍽 ${result.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(result.description),
                    const SizedBox(height: 14),
                    Text('Quantidade: ${(multiplier * 100).round()}% da estimativa'),
                    Slider(
                      value: multiplier,
                      min: 0.25,
                      max: 2.0,
                      divisions: 7,
                      label: '${(multiplier * 100).round()}%',
                      onChanged: (value) => setState(() => multiplier = value),
                    ),
                    const SizedBox(height: 8),
                    Text('🔥 ${result.calories} kcal'),
                    Text('🍗 ${result.protein} g proteína'),
                    Text('🍞 ${result.carbs} g carboidrato'),
                    Text('🥑 ${result.fat} g gordura'),
                    Text('🎯 Confiança: ${result.confidence}%'),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: saving ? null : saveMeal,
                      icon: saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check),
                      label: const Text('Confirmar e salvar no diário'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
