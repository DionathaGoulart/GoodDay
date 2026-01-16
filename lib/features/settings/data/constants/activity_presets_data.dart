
import 'package:flutter/material.dart';

class PresetItem {
  final String name;
  final String? emoji; // Prioritize emoji
  final int? iconCode; // Fallback

  const PresetItem({
    required this.name,
    this.emoji,
    this.iconCode,
  });
}

class PresetCategory {
  final String name;
  final String? emoji;
  final int? iconCode;
  final int colorValue;
  final List<PresetItem> items;

  const PresetCategory({
    required this.name,
    required this.colorValue,
    this.emoji,
    this.iconCode,
    required this.items,
  });
}

// Data
class ActivityPresetsData {
  static final List<PresetCategory> groupPresets = [
    PresetCategory(
      name: 'Social',
      emoji: '👥',
      colorValue: Colors.blue.value,
      items: [
        PresetItem(name: 'Família', emoji: '👨‍👩‍👧‍👦'),
        PresetItem(name: 'Amigos', emoji: '👯‍♂️'),
        PresetItem(name: 'Encontro', emoji: '💕'),
        PresetItem(name: 'Festa', emoji: '🎉'),
      ],
    ),
    PresetCategory(
      name: 'Hobbies',
      emoji: '🎨',
      colorValue: Colors.purple.value,
      items: [
        PresetItem(name: 'Leitura', emoji: '📚'),
        PresetItem(name: 'Jogos', emoji: '🎮'),
        PresetItem(name: 'TV/Filmes', emoji: '🎬'),
        PresetItem(name: 'Música', emoji: '🎧'),
      ],
    ),
    PresetCategory(
      name: 'Bem-Estar',
      emoji: '🧘',
      colorValue: Colors.teal.value,
      items: [
        PresetItem(name: 'Exercício', emoji: '💪'),
        PresetItem(name: 'Meditação', emoji: '🧘‍♀️'),
        PresetItem(name: 'Skincare', emoji: '🧖‍♀️'),
        PresetItem(name: 'Relaxar', emoji: '🛁'),
      ],
    ),
    PresetCategory(
      name: 'Trabalho/Estudo',
      emoji: '💼',
      colorValue: Colors.brown.value,
      items: [
        PresetItem(name: 'Trabalho', emoji: '💼'),
        PresetItem(name: 'Aula', emoji: '🏫'),
        PresetItem(name: 'Estudar', emoji: '📝'),
        PresetItem(name: 'Reunião', emoji: '🤝'),
      ],
    ),
     PresetCategory(
      name: 'Tarefas',
      emoji: '🧹',
      colorValue: Colors.amber.value,
      items: [
        PresetItem(name: 'Limpeza', emoji: '🧹'),
        PresetItem(name: 'Cozinhar', emoji: '🍳'),
        PresetItem(name: 'Compras', emoji: '🛒'),
        PresetItem(name: 'Lavanderia', emoji: '🧺'),
      ],
    ),
    PresetCategory(
      name: 'Alimentação',
      emoji: '🍔',
      colorValue: Colors.orange.value,
      items: [
        PresetItem(name: 'Saudável', emoji: '🥗'),
        PresetItem(name: 'Fast Food', emoji: '🍔'),
        PresetItem(name: 'Doce', emoji: '🍫'),
        PresetItem(name: 'Água', emoji: '💧'),
      ],
    ),
    PresetCategory(
      name: 'Sono',
      emoji: '😴',
      colorValue: Colors.indigo.value,
      items: [
        PresetItem(name: 'Dormi cedo', emoji: '🌑'),
        PresetItem(name: 'Dormi tarde', emoji: '🌕'),
        PresetItem(name: 'Insônia', emoji: '👀'),
        PresetItem(name: 'Boa noite', emoji: '💤'),
      ],
    ),
  ];

  static final List<PresetCategory> scalePresets = [
    PresetCategory(
      name: 'Nível de Estresse',
      emoji: '🤯',
      colorValue: Colors.red.value,
      items: [
        PresetItem(name: 'Baixo', emoji: '😌'),
        PresetItem(name: 'Médio', emoji: '😐'),
        PresetItem(name: 'Alto', emoji: '😫'),
      ],
    ),
    PresetCategory(
      name: 'Energia',
      emoji: '⚡',
      colorValue: Colors.yellow.value,
      items: [
        PresetItem(name: 'Baixa', emoji: '🔋'),
        PresetItem(name: 'Média', emoji: '🔌'),
        PresetItem(name: 'Alta', emoji: '⚡'),
      ],
    ),
    PresetCategory(
      name: 'Ansiedade',
      emoji: '😰',
      colorValue: Colors.deepPurple.value,
      items: [
        PresetItem(name: 'Nenhuma', emoji: '🕊️'),
        PresetItem(name: 'Leve', emoji: '😟'),
        PresetItem(name: 'Forte', emoji: '😨'),
        PresetItem(name: 'Crise', emoji: '🆘'),
      ],
    ),
    PresetCategory(
      name: 'Produtividade',
      emoji: '📈',
      colorValue: Colors.green.value,
      items: [
        PresetItem(name: 'Nada', emoji: '📉'),
        PresetItem(name: 'Média', emoji: '📊'),
        PresetItem(name: 'Muita', emoji: '🚀'),
      ],
    ),
    PresetCategory(
      name: 'Bateria Social',
      emoji: '🔋',
      colorValue: Colors.pink.value,
      items: [
        PresetItem(name: 'Esgotada', emoji: '🪫'),
        PresetItem(name: 'Carregando', emoji: '🔌'),
        PresetItem(name: 'Cheia', emoji: '🔋'),
      ],
    ),
  ];
}
