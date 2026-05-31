import 'package:flutter/material.dart';

import '../models/quest_field.dart';
import '../models/quest_theme.dart';

class FieldSelectionScreen extends StatefulWidget {
  const FieldSelectionScreen({super.key});

  @override
  State<FieldSelectionScreen> createState() => _FieldSelectionScreenState();
}

class _FieldSelectionScreenState extends State<FieldSelectionScreen> {
  QuestField selectedField = questFields.first;
  String selectedTopic = questFields.first.topics.first;
  String selectedLevel = 'Başlangıç';
  int selectedModeIndex = 0;

  final PageController modeController = PageController(
    viewportFraction: 0.82,
  );

  final List<String> levels = [
    'Başlangıç',
    'Orta',
    'İleri',
  ];

  @override
  void dispose() {
    modeController.dispose();
    super.dispose();
  }

  void selectField(QuestField field) {
    setState(() {
      selectedField = field;
      selectedTopic = field.topics.first;
    });
  }

  void startQuest() {
    final mode = questThemes[selectedModeIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101426),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Macera Hazır',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$selectedTopic konusu, ${mode.title} ile oyunlaştırılacak.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _SummaryRow(label: 'Alan', value: selectedField.title),
              _SummaryRow(label: 'Konu', value: selectedTopic),
              _SummaryRow(label: 'Seviye', value: selectedLevel),
              _SummaryRow(label: 'Mod', value: mode.title),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mode.glowColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Devam Et',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
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
    final activeMode = questThemes[selectedModeIndex];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.35,
                colors: [
                  Color(0xFF17123A),
                  Color(0xFF060814),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      children: [
                        const _Header(),
                        const SizedBox(height: 14),
                        _CompactQuestPanel(
                          field: selectedField,
                          topic: selectedTopic,
                          level: selectedLevel,
                          glowColor: activeMode.glowColor,
                        ),
                        const SizedBox(height: 18),

                        const _SectionTitle(
                          title: 'Alan',
                          subtitle: 'Öğrenmek istediğin alanı seç.',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 62,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: questFields.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final field = questFields[index];
                              final selected =
                                  selectedField.title == field.title;

                              return _OvalFieldCard(
                                field: field,
                                selected: selected,
                                glowColor: activeMode.glowColor,
                                onTap: () => selectField(field),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),
                        const _SectionTitle(
                          title: 'Konu',
                          subtitle: 'Macera buradan başlayacak.',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedField.topics.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final topic = selectedField.topics[index];
                              final selected = selectedTopic == topic;

                              return _OvalTopicChip(
                                text: topic,
                                selected: selected,
                                glowColor: activeMode.glowColor,
                                onTap: () {
                                  setState(() {
                                    selectedTopic = topic;
                                  });
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),
                        const _SectionTitle(
                          title: 'Seviye',
                          subtitle: 'Anlatım derinliği.',
                        ),
                        const SizedBox(height: 10),
                        _OvalLevelSelector(
                          levels: levels,
                          selectedLevel: selectedLevel,
                          glowColor: activeMode.glowColor,
                          onChanged: (level) {
                            setState(() {
                              selectedLevel = level;
                            });
                          },
                        ),

                        const SizedBox(height: 20),
                        const _SectionTitle(
                          title: 'Mod',
                          subtitle: 'Bilginin hangi dünyaya dönüşeceğini seç.',
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 318,
                          child: PageView.builder(
                            controller: modeController,
                            itemCount: questThemes.length,
                            onPageChanged: (index) {
                              setState(() {
                                selectedModeIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final mode = questThemes[index];
                              final active = selectedModeIndex == index;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: _ModeCard(
                                  theme: mode,
                                  active: active,
                                  onTap: () {
                                    modeController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 280),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: _StartButton(
                      glowColor: activeMode.glowColor,
                      onTap: startQuest,
                    ),
                  ),
                ],
              ),
            ),
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
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF22D3EE),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alchemy of Education',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Bilgiyi maceraya çevir.',
                style: TextStyle(
                  color: Color(0xFFA8AABD),
                  fontSize: 12.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactQuestPanel extends StatelessWidget {
  final QuestField field;
  final String topic;
  final String level;
  final Color glowColor;

  const _CompactQuestPanel({
    required this.field,
    required this.topic,
    required this.level,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111629),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: glowColor.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SmallInfo(label: 'Alan', value: field.title),
          ),
          _DividerLine(),
          Expanded(
            child: _SmallInfo(label: 'Konu', value: topic),
          ),
          _DividerLine(),
          Expanded(
            child: _SmallInfo(label: 'Seviye', value: level),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.08),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  final String label;
  final String value;

  const _SmallInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OvalFieldCard extends StatelessWidget {
  final QuestField field;
  final bool selected;
  final Color glowColor;
  final VoidCallback onTap;

  const _OvalFieldCard({
    required this.field,
    required this.selected,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 154,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF18213A) : const Color(0xFF101527),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? glowColor.withOpacity(0.95) : Colors.white10,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.45),
                    blurRadius: 24,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              field.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white.withOpacity(0.78),
                fontSize: 13.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              field.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? glowColor.withOpacity(0.95)
                    : Colors.white.withOpacity(0.42),
                fontSize: 10.1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OvalTopicChip extends StatelessWidget {
  final String text;
  final bool selected;
  final Color glowColor;
  final VoidCallback onTap;

  const _OvalTopicChip({
    required this.text,
    required this.selected,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF18213A) : const Color(0xFF101527),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? glowColor.withOpacity(0.95) : Colors.white10,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white.withOpacity(0.65),
            fontSize: 12.1,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OvalLevelSelector extends StatelessWidget {
  final List<String> levels;
  final String selectedLevel;
  final Color glowColor;
  final ValueChanged<String> onChanged;

  const _OvalLevelSelector({
    required this.levels,
    required this.selectedLevel,
    required this.glowColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF101527),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
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
                  color: selected ? const Color(0xFF18213A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color:
                        selected ? glowColor.withOpacity(0.9) : Colors.transparent,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: glowColor.withOpacity(0.32),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white54,
                    fontSize: 12.1,
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

class _ModeCard extends StatelessWidget {
  final QuestTheme theme;
  final bool active;
  final VoidCallback onTap;

  const _ModeCard({
    required this.theme,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      scale: active ? 1 : 0.94,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            border: Border.all(
              color: active
                  ? theme.glowColor.withOpacity(0.95)
                  : Colors.white.withOpacity(0.10),
              width: active ? 2.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: active
                    ? theme.glowColor.withOpacity(0.50)
                    : Colors.black.withOpacity(0.30),
                blurRadius: active ? 38 : 16,
                spreadRadius: active ? 1.5 : 0,
                offset: const Offset(0, 17),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(41),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  theme.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF15172A),
                      alignment: Alignment.center,
                      child: const Text(
                        'Görsel bulunamadı',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.02),
                        Colors.black.withOpacity(0.24),
                        Colors.black.withOpacity(0.94),
                      ],
                    ),
                  ),
                ),
                if (active)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.glowColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(41),
                      ),
                    ),
                  ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        theme.playStyle,
                        style: TextStyle(
                          color: theme.glowColor.withOpacity(0.95),
                          fontSize: 12.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        theme.shortPurpose,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.76),
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF22D3EE),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 11.4,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  final Color glowColor;
  final VoidCallback onTap;

  const _StartButton({
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
            const Color(0xFF22D3EE),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.42),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
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
        color: const Color(0xFF18213A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12,
                fontWeight: FontWeight.w600,
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