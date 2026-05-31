import 'package:flutter/material.dart';

import '../models/quest_theme.dart';
import '../widgets/theme_card.dart';

class CreateAdventureScreen extends StatefulWidget {
  const CreateAdventureScreen({super.key});

  @override
  State<CreateAdventureScreen> createState() => _CreateAdventureScreenState();
}

class _CreateAdventureScreenState extends State<CreateAdventureScreen> {
  final TextEditingController topicController = TextEditingController();

  String selectedLevel = 'Başlangıç';
  QuestTheme selectedTheme = questThemes.first;

  final List<String> levels = [
    'Başlangıç',
    'Orta',
    'İleri',
  ];

  @override
  void dispose() {
    topicController.dispose();
    super.dispose();
  }

  void createAdventure() {
    final topic = topicController.text.trim();

    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce öğrenmek istediğin konuyu yazmalısın.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF17172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Macera taslağı hazır',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$topic konusu, "${selectedTheme.title}" temasıyla $selectedLevel seviyesinde oyunlaştırılacak.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              _PreviewBox(
                title: selectedTheme.title,
                description: selectedTheme.scene,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Devam Et',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [
              Color(0xFF25215A),
              Color(0xFF0F1020),
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              const _Header(),
              const SizedBox(height: 26),
              _TopicInput(controller: topicController),
              const SizedBox(height: 22),
              _LevelSelector(
                levels: levels,
                selectedLevel: selectedLevel,
                onSelected: (level) {
                  setState(() {
                    selectedLevel = level;
                  });
                },
              ),
              const SizedBox(height: 26),
              const _SectionTitle(
                title: 'Tema seç',
                subtitle: 'Konu hangi dünyada maceraya dönüşsün?',
              ),
              const SizedBox(height: 16),
              GridView.builder(
                itemCount: questThemes.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.66,
                ),
                itemBuilder: (context, index) {
                  final theme = questThemes[index];

                  return ThemeCard(
                    theme: theme,
                    isSelected: selectedTheme.title == theme.title,
                    onTap: () {
                      setState(() {
                        selectedTheme = theme;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 28),
              _CreateButton(onPressed: createAdventure),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF22D3EE),
              ],
            ),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MemoryQuest AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bilgiyi maceraya dönüştür.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicInput extends StatelessWidget {
  final TextEditingController controller;

  const _TopicInput({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Yeni macera',
            subtitle: 'Öğrenmek istediğin konuyu yaz.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            cursorColor: const Color(0xFF22D3EE),
            decoration: InputDecoration(
              hintText: 'Örn: Kriptografi, Normalizasyon, İşletim Sistemleri',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFF111322),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.white.withOpacity(0.55),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFF22D3EE),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final List<String> levels;
  final String selectedLevel;
  final ValueChanged<String> onSelected;

  const _LevelSelector({
    required this.levels,
    required this.selectedLevel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionTitle(
          title: 'Seviye',
          subtitle: 'Anlatım zorluğunu belirle.',
        ),
        const SizedBox(height: 14),
        Row(
          children: levels.map((level) {
            final isSelected = selectedLevel == level;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelected(level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : Colors.white.withOpacity(0.075),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.35)
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      level,
                      style: TextStyle(
                        color: Colors.white.withOpacity(
                          isSelected ? 0.98 : 0.62,
                        ),
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.50),
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF22D3EE),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.32),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Macerayı Oluştur',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}

class _PreviewBox extends StatelessWidget {
  final String title;
  final String description;

  const _PreviewBox({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.22),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.map_rounded,
              color: Color(0xFFDDD6FE),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.58),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}