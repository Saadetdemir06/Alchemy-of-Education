import 'package:flutter/material.dart';
import 'profile_screen.dart';

import '../models/quest_field.dart';
import '../models/quest_theme.dart';
import 'adventure_map_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int currentTab = 0;
  bool showTopics = false;

  QuestField selectedField = questFields.first;
  String selectedTopic = questFields.first.topics.first;
  String selectedLevel = 'Başlangıç';
  QuestTheme selectedMode = questThemes.first;

  final List<String> levels = const [
    'Başlangıç',
    'Orta',
    'İleri',
  ];

  final Map<String, String> gateImages = const {
    'Bilgisayar': 'assets/images/gate_computer.png',
    'Biyoloji': 'assets/images/gate_biology.png',
    'Tarih': 'assets/images/gate_history.png',
    'Dil': 'assets/images/gate_language.png',
    'Matematik': 'assets/images/gate_math.png',
    'Psikoloji': 'assets/images/gate_psychology.png',
  };

  final Map<String, String> topicImages = const {
    'Kriptografi': 'assets/images/btn_kriptografi.png',
    'Yapay Zeka': 'assets/images/btn_yapayzeka.png',
    'İşletim Sistemleri': 'assets/images/btn_isletim.png',
    'Veritabanı': 'assets/images/btn_veritabani.png',
    'Algoritmalar': 'assets/images/btn_algoritmalar.png',
    'Sinir Ağları': 'assets/images/btn_siniraglari.png',
  };

  void selectField(QuestField field) {
    setState(() {
      selectedField = field;
      selectedTopic = field.topics.first;
      showTopics = true;
    });
  }

  void goHome() {
    setState(() {
      currentTab = 0;
      showTopics = false;
    });
  }

  void goToGameMode() {
    setState(() {
      currentTab = 1;
    });
  }

  void startLearning() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdventureMapScreen(
          field: selectedField,
          topic: selectedTopic,
          level: selectedLevel,
          mode: selectedMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeRealmPage(
        showTopics: showTopics,
        selectedField: selectedField,
        selectedTopic: selectedTopic,
        selectedLevel: selectedLevel,
        selectedMode: selectedMode,
        gateImages: gateImages,
        topicImages: topicImages,
        levels: levels,
        onFieldTap: selectField,
        onTopicTap: (topic) {
          setState(() {
            selectedTopic = topic;
          });
        },
        onBackToFields: () {
          setState(() {
            showTopics = false;
          });
        },
        onLevelChanged: (level) {
          setState(() {
            selectedLevel = level;
          });
        },
        onGoToGameMode: goToGameMode,
      ),
      _GameModePage(
        selectedMode: selectedMode,
        onModeSelected: (mode) {
          setState(() {
            selectedMode = mode;
          });
        },
        onStart: startLearning,
        onBack: () {
          setState(() {
            currentTab = 0;
          });
        },
      ),
      const ProfileScreen(),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/home_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.68),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 82),
                  child: pages[currentTab],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _ImageBottomNav(
                  currentIndex: currentTab,
                  onHome: goHome,
                  onGame: goToGameMode,
                  onProfile: () {
                    setState(() {
                      currentTab = 2;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeRealmPage extends StatelessWidget {
  final bool showTopics;
  final QuestField selectedField;
  final String selectedTopic;
  final String selectedLevel;
  final QuestTheme selectedMode;
  final Map<String, String> gateImages;
  final Map<String, String> topicImages;
  final List<String> levels;
  final ValueChanged<QuestField> onFieldTap;
  final ValueChanged<String> onTopicTap;
  final VoidCallback onBackToFields;
  final ValueChanged<String> onLevelChanged;
  final VoidCallback onGoToGameMode;

  const _HomeRealmPage({
    required this.showTopics,
    required this.selectedField,
    required this.selectedTopic,
    required this.selectedLevel,
    required this.selectedMode,
    required this.gateImages,
    required this.topicImages,
    required this.levels,
    required this.onFieldTap,
    required this.onTopicTap,
    required this.onBackToFields,
    required this.onLevelChanged,
    required this.onGoToGameMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      children: [
        Image.asset(
          'assets/images/logo_alchemy.png',
          height: 126,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        _InfoPlaque(
          field: selectedField.title,
          topic: selectedTopic,
          level: selectedLevel,
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: showTopics
              ? _TopicSelectionArea(
                  key: const ValueKey('topics'),
                  selectedField: selectedField,
                  selectedTopic: selectedTopic,
                  selectedLevel: selectedLevel,
                  selectedMode: selectedMode,
                  topicImages: topicImages,
                  levels: levels,
                  onTopicTap: onTopicTap,
                  onBackToFields: onBackToFields,
                  onLevelChanged: onLevelChanged,
                  onGoToGameMode: onGoToGameMode,
                )
              : _FieldGateArea(
                  key: const ValueKey('fields'),
                  selectedField: selectedField,
                  gateImages: gateImages,
                  onFieldTap: onFieldTap,
                ),
        ),
      ],
    );
  }
}

class _InfoPlaque extends StatelessWidget {
  final String field;
  final String topic;
  final String level;

  const _InfoPlaque({
    required this.field,
    required this.topic,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B2A1D).withOpacity(0.88),
            const Color(0xFF1A1A22).withOpacity(0.90),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _InfoItem(label: 'Alan', value: field)),
          _GoldDivider(),
          Expanded(child: _InfoItem(label: 'Konu', value: topic)),
          _GoldDivider(),
          Expanded(child: _InfoItem(label: 'Seviye', value: level)),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFFFD58A).withOpacity(0.78),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.7,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFFFFD58A).withOpacity(0.22),
    );
  }
}

class _FieldGateArea extends StatelessWidget {
  final QuestField selectedField;
  final Map<String, String> gateImages;
  final ValueChanged<QuestField> onFieldTap;

  const _FieldGateArea({
    super.key,
    required this.selectedField,
    required this.gateImages,
    required this.onFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ScrollHeader(
          title: 'Alan Kapıları',
          subtitle: 'Bir öğrenme diyarı seç',
        ),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: questFields.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final field = questFields[index];
            final selected = selectedField.title == field.title;
            final imagePath = gateImages[field.title];

            return _ClickableAssetCard(
              imagePath: imagePath,
              selected: selected,
              glowColor: const Color(0xFFFF4FA3),
              onTap: () => onFieldTap(field),
            );
          },
        ),
      ],
    );
  }
}

class _TopicSelectionArea extends StatelessWidget {
  final QuestField selectedField;
  final String selectedTopic;
  final String selectedLevel;
  final QuestTheme selectedMode;
  final Map<String, String> topicImages;
  final List<String> levels;
  final ValueChanged<String> onTopicTap;
  final VoidCallback onBackToFields;
  final ValueChanged<String> onLevelChanged;
  final VoidCallback onGoToGameMode;

  const _TopicSelectionArea({
    super.key,
    required this.selectedField,
    required this.selectedTopic,
    required this.selectedLevel,
    required this.selectedMode,
    required this.topicImages,
    required this.levels,
    required this.onTopicTap,
    required this.onBackToFields,
    required this.onLevelChanged,
    required this.onGoToGameMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SoftBackButton(
              text: 'Alan Seçimine Dön',
              onTap: onBackToFields,
            ),
            const SizedBox(height: 12),
            _ScrollHeader(
              title: '${selectedField.title} Görevleri',
              subtitle: 'Bir başlangıç konusu seç',
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          itemCount: selectedField.topics.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.45,
          ),
          itemBuilder: (context, index) {
            final topic = selectedField.topics[index];
            final selected = selectedTopic == topic;
            final imagePath = topicImages[topic];

            if (imagePath != null) {
              return _ClickableAssetCard(
                imagePath: imagePath,
                selected: selected,
                glowColor: selectedMode.glowColor,
                onTap: () => onTopicTap(topic),
              );
            }

            return _FallbackTopicButton(
              text: topic,
              selected: selected,
              glowColor: selectedMode.glowColor,
              onTap: () => onTopicTap(topic),
            );
          },
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Seviye Seç',
            style: TextStyle(
              color: const Color(0xFFFFE7B2),
              fontSize: 17,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: selectedMode.glowColor.withOpacity(0.7),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _LevelSelector(
          levels: levels,
          selectedLevel: selectedLevel,
          glowColor: selectedMode.glowColor,
          onChanged: onLevelChanged,
        ),
        const SizedBox(height: 18),
        _GoToGameModeButton(
          glowColor: selectedMode.glowColor,
          onTap: onGoToGameMode,
        ),
      ],
    );
  }
}

class _ClickableAssetCard extends StatelessWidget {
  final String? imagePath;
  final bool selected;
  final Color glowColor;
  final VoidCallback onTap;

  const _ClickableAssetCard({
    required this.imagePath,
    required this.selected,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.65),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1D28),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Görsel yok',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
            if (selected)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: glowColor.withOpacity(0.95),
                        width: 2.4,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FallbackTopicButton extends StatelessWidget {
  final String text;
  final bool selected;
  final Color glowColor;
  final VoidCallback onTap;

  const _FallbackTopicButton({
    required this.text,
    required this.selected,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: selected
                ? [
                    glowColor.withOpacity(0.78),
                    const Color(0xFF2A1B2A),
                  ]
                : [
                    const Color(0xFF3A2A1F).withOpacity(0.92),
                    const Color(0xFF111827).withOpacity(0.92),
                  ],
          ),
          border: Border.all(
            color: selected
                ? glowColor
                : const Color(0xFFFFD58A).withOpacity(0.20),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD58A).withOpacity(0.95),
              const Color(0xFF8A5A2D).withOpacity(0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF2B170D),
          size: 24,
        ),
      ),
    );
  }
}

class _SoftBackButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SoftBackButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A33).withOpacity(0.88),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              color: Colors.white.withOpacity(0.78),
              size: 20,
            ),
            const SizedBox(width: 7),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 12.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ScrollHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/topic_title_scroll.png',
      height: 58,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE2B56D),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2B170D),
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      },
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final List<String> levels;
  final String selectedLevel;
  final Color glowColor;
  final ValueChanged<String> onChanged;

  const _LevelSelector({
    required this.levels,
    required this.selectedLevel,
    required this.glowColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.22),
        ),
      ),
      child: Row(
        children: levels.map((level) {
          final selected = selectedLevel == level;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selected ? glowColor.withOpacity(0.34) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? glowColor.withOpacity(0.95)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color:
                        selected ? Colors.white : Colors.white.withOpacity(0.60),
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GoToGameModeButton extends StatelessWidget {
  final Color glowColor;
  final VoidCallback onTap;

  const _GoToGameModeButton({
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            glowColor,
            const Color(0xFFFFD58A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.50),
            blurRadius: 26,
            spreadRadius: 1,
            offset: const Offset(0, 11),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
          width: 1.1,
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF231309),
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports_rounded, size: 21),
            SizedBox(width: 8),
            Text(
              'Macera Modunu Seç',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 21),
          ],
        ),
      ),
    );
  }
}

class _GameModePage extends StatelessWidget {
  final QuestTheme selectedMode;
  final ValueChanged<QuestTheme> onModeSelected;
  final VoidCallback onStart;
  final VoidCallback onBack;

  const _GameModePage({
    required this.selectedMode,
    required this.onModeSelected,
    required this.onStart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final modes = questThemes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _SoftBackButton(
            text: 'Seçimlere Dön',
            onTap: onBack,
          ),
        ),
        const SizedBox(height: 10),
        Image.asset(
          'assets/images/logo_alchemy.png',
          height: 112,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1514).withOpacity(0.82),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFFFD58A).withOpacity(0.25),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Macera Modunu Seç',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE7B2),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Seçtiğin mod, öğrenme yolunun atmosferini ve görev dilini belirler.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 12.2,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 18,
            crossAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final mode = modes[index];
            final selected = mode.title == selectedMode.title;

            return _ModeImageCard(
              mode: mode,
              selected: selected,
              onTap: () => onModeSelected(mode),
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          height: 58,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                selectedMode.glowColor,
                const Color(0xFFFFD58A),
                selectedMode.glowColor.withOpacity(0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: selectedMode.glowColor.withOpacity(0.75),
                blurRadius: 32,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFFFD58A).withOpacity(0.45),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.34),
              width: 1.2,
            ),
          ),
          child: ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFF231309),
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Haydi Öğrenmeye Başlayalım',
                  style: TextStyle(
                    fontSize: 14.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final QuestTheme mode;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ClickableAssetCard(
      imagePath: mode.imagePath,
      selected: selected,
      glowColor: mode.glowColor,
      onTap: onTap,
    );
  }
}

class _StartLearningButton extends StatelessWidget {
  final Color glowColor;
  final VoidCallback onTap;

  const _StartLearningButton({
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            glowColor,
            const Color(0xFFFFD58A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.40),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF231309),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text(
          'Haydi Öğrenmeye Başlayalım',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      children: [
        Image.asset(
          'assets/images/logo_alchemy.png',
          height: 116,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        _ScrollHeader(
          title: 'Profil',
          subtitle: 'İlerleme ve hesap ayarları',
        ),
        const SizedBox(height: 16),
        _ProfileScoreCard(),
        const SizedBox(height: 14),
        const _ProfileActionTile(
          title: 'Geçmişim',
          subtitle: 'Tamamladığın öğrenme maceraları',
        ),
        const _ProfileActionTile(
          title: 'Şifre değiştir',
          subtitle: 'Hesap güvenliğini güncelle',
        ),
        const _ProfileActionTile(
          title: 'Puanlarım',
          subtitle: 'Rozetler ve ilerleme puanın',
        ),
        const _ProfileActionTile(
          title: 'Hesabı sil',
          subtitle: 'Kullanıcı hesabını kalıcı olarak sil',
          danger: true,
        ),
      ],
    );
  }
}

class _ProfileScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.26),
        ),
      ),
      child: const Row(
        children: [
          Expanded(child: _ProfileStat(label: 'Puan', value: '0 XP')),
          Expanded(child: _ProfileStat(label: 'Macera', value: '0')),
          Expanded(child: _ProfileStat(label: 'Rozet', value: '0')),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFE7B2),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.60),
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool danger;

  const _ProfileActionTile({
    required this.title,
    required this.subtitle,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: danger
              ? const Color(0xFFFF3D6E).withOpacity(0.34)
              : const Color(0xFFFFD58A).withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: danger
                        ? const Color(0xFFFF6B8A)
                        : const Color(0xFFFFE7B2),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.52),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withOpacity(0.35),
            size: 15,
          ),
        ],
      ),
    );
  }
}

class _ImageBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onHome;
  final VoidCallback onGame;
  final VoidCallback onProfile;

  const _ImageBottomNav({
    required this.currentIndex,
    required this.onHome,
    required this.onGame,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 82,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bottom_nav_frame.png',
                fit: BoxFit.fill,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onHome,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onGame,
                    child: const SizedBox.expand(),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onProfile,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
            Positioned(
              left: currentIndex * 143.0 + 42,
              bottom: 7,
              child: Container(
                width: 56,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD58A),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD58A).withOpacity(0.8),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeImageCard extends StatelessWidget {
  final QuestTheme mode;
  final bool selected;
  final VoidCallback onTap;

  const _ModeImageCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  String get shortMeaning {
    if (mode.title.contains('Fantastik')) {
      return 'Büyü, kapılar ve ejderha yolu';
    }

    if (mode.title.contains('Dedektif')) {
      return 'İpucu, kanıt ve dava çözümü';
    }

    if (mode.title.contains('Uzay')) {
      return 'Galaksi, üs ve görev rotası';
    }

    if (mode.title.contains('Antik')) {
      return 'Tapınak, taş tablet ve muhafız';
    }

    if (mode.title.contains('Laboratuvar')) {
      return 'Deney, formül ve dönüşüm';
    }

    if (mode.title.contains('Korku')) {
      return 'Kilitli oda, gölge ve kaçış';
    }

    return 'Öğrenme macerası';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF15141E).withOpacity(0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected
                ? mode.glowColor
                : const Color(0xFFFFD58A).withOpacity(0.16),
            width: selected ? 2.2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: mode.glowColor.withOpacity(0.55),
                    blurRadius: 24,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 7),
                  ),
                ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      mode.imagePath,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.18),
                            Colors.black.withOpacity(0.76),
                          ],
                        ),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mode.glowColor,
                            boxShadow: [
                              BoxShadow(
                                color: mode.glowColor.withOpacity(0.75),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              mode.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFE7B2),
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              shortMeaning,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
                fontSize: 10.2,
                height: 1.18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFFFFD58A).withOpacity(0.65),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}