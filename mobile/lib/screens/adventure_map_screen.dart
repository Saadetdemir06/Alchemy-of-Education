import 'package:flutter/material.dart';

import '../data/mock_adventure_builder.dart';
import '../models/adventure_models.dart';
import '../models/quest_field.dart';
import '../models/quest_theme.dart';
import '../services/adventure_api_service.dart';
import 'chapter_detail_screen.dart';

class AdventureMapScreen extends StatefulWidget {
  final QuestField field;
  final String topic;
  final String level;
  final QuestTheme mode;

  const AdventureMapScreen({
    super.key,
    required this.field,
    required this.topic,
    required this.level,
    required this.mode,
  });

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen> {
  List<AdventureChapter> chapters = [];

  bool isLoadingAdventure = true;
  bool usedFallback = false;

  AdventureProgress progress = const AdventureProgress(
    gold: 0,
    xp: 0,
    unlockedChapter: 1,
    completedChapters: {},
  );

  @override
  void initState() {
    super.initState();
    loadAdventure();
  }

  Future<void> loadAdventure() async {
    try {
      final aiChapters = await AdventureApiService.generateAdventure(
        field: widget.field.title,
        topic: widget.topic,
        level: widget.level,
        mode: widget.mode.title,
      );

      if (!mounted) return;

      setState(() {
        chapters = aiChapters;
        isLoadingAdventure = false;
        usedFallback = false;
      });
    } catch (e) {
      final fallbackChapters = buildMockAdventure(
        topic: widget.topic,
        modeTitle: widget.mode.title,
      );

      if (!mounted) return;

      setState(() {
        chapters = fallbackChapters;
        isLoadingAdventure = false;
        usedFallback = true;
      });
    }
  }

  String get mapTitle {
    if (widget.mode.title.contains('Dedektif')) {
      return '${widget.topic} Dosyası';
    }

    if (widget.mode.title.contains('Uzay')) {
      return '${widget.topic} Galaksisi';
    }

    if (widget.mode.title.contains('Antik')) {
      return '${widget.topic} Antik Şehri';
    }

    if (widget.mode.title.contains('Laboratuvar')) {
      return '${widget.topic} Laboratuvarı';
    }

    if (widget.mode.title.contains('Korku')) {
      return '${widget.topic} Korku Evi';
    }

    return '${widget.topic} Krallığı';
  }

  int get currentActiveChapterId {
    if (chapters.isEmpty) return 1;

    for (final chapter in chapters) {
      final isCompleted = progress.completedChapters.contains(chapter.id);

      if (chapter.id <= progress.unlockedChapter && !isCompleted) {
        return chapter.id;
      }
    }

    return progress.unlockedChapter.clamp(1, 6);
  }

  String sceneAssetForChapter(int chapterId) {
    final index = chapterId.clamp(1, 6);

    if (widget.mode.title.contains('Dedektif')) {
      const detectiveAssets = [
        'assets/images/detective_case_file.png',
        'assets/images/detective_clue_board.png',
        'assets/images/detective_suspect_card.png',
        'assets/images/detective_evidence_room.png',
        'assets/images/detective_fingerprint.png',
        'assets/images/detective_final_case.png',
      ];

      return detectiveAssets[index - 1];
    }

    if (widget.mode.title.contains('Uzay')) {
      const spaceAssets = [
        'assets/images/space_base_gate.png',
        'assets/images/space_wormhole_portal.png',
        'assets/images/space_signal_tower.png',
        'assets/images/space_station.png',
        'assets/images/space_blackhole_mirror.png',
        'assets/images/space_boss_dragon.png',
      ];

      return spaceAssets[index - 1];
    }

    if (widget.mode.title.contains('Antik')) {
      const ancientAssets = [
        'assets/images/ancient_city_gate.png',
        'assets/images/ancient_city_portal.png',
        'assets/images/ancient_city_tower.png',
        'assets/images/ancient_city_castle.png',
        'assets/images/ancient_city_mirror.png',
        'assets/images/ancient_city_boss_guardian.png',
      ];

      return ancientAssets[index - 1];
    }

    if (widget.mode.title.contains('Laboratuvar')) {
      const laboratoryAssets = [
        'assets/images/laboratory_gate.png',
        'assets/images/laboratory_portal.png',
        'assets/images/laboratory_tower.png',
        'assets/images/laboratory_castle.png',
        'assets/images/laboratory_mirror.png',
        'assets/images/laboratory_boss_monster.png',
      ];

      return laboratoryAssets[index - 1];
    }

    if (widget.mode.title.contains('Korku')) {
      const horrorAssets = [
        'assets/images/horror_house_gate.png',
        'assets/images/horror_house_portal.png',
        'assets/images/horror_house_tower.png',
        'assets/images/horror_house_castle.png',
        'assets/images/horror_house_mirror.png',
        'assets/images/horror_house_boss.png',
      ];

      return horrorAssets[index - 1];
    }

    const fantasyAssets = [
      'assets/images/fantasy_gate.png',
      'assets/images/fantasy_portal.png',
      'assets/images/fantasy_tower.png',
      'assets/images/fantasy_castle.png',
      'assets/images/fantasy_mirror.png',
      'assets/images/fantasy_boss_dragon.png',
    ];

    return fantasyAssets[index - 1];
  }

 void openChapter(AdventureChapter chapter) async {
  if (chapter.id > progress.unlockedChapter) {
    showLockedMessage();
    return;
  }

  final result = await Navigator.push<AdventureProgress>(
    context,
    MaterialPageRoute(
      builder: (_) => ChapterDetailScreen(
        chapter: chapter,
        progress: progress,
        mode: widget.mode,
        field: widget.field.title,
        topic: widget.topic,
        level: widget.level,
        modeTitle: widget.mode.title,
        mapTitle: mapTitle,
        onNewAdventureRequested: () {
          Navigator.pop(context);

          setState(() {
            progress = const AdventureProgress(
              gold: 0,
              xp: 0,
              unlockedChapter: 1,
              completedChapters: {},
            );

            chapters = [];
            isLoadingAdventure = true;
            usedFallback = false;
          });

          loadAdventure();
        },
      ),
    ),
  );

  if (result != null) {
    setState(() {
      progress = result;
    });
  }
}

  void showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Bu görev henüz kilitli. Önce önceki görevi tamamla.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A211B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  double get xpProgress {
    final value = progress.xp / 100;
    if (value > 1) return 1;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  widget.mode.imagePath,
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
                        Colors.black.withOpacity(0.18),
                        Colors.black.withOpacity(0.55),
                        Colors.black.withOpacity(0.92),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: isLoadingAdventure
                    ? _AdventureLoadingView(
                        topic: widget.topic,
                        mode: widget.mode.title,
                        glowColor: widget.mode.glowColor,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                        children: [
                          _MapTopHeader(
                            title: mapTitle,
                            field: widget.field.title,
                            topic: widget.topic,
                            level: widget.level,
                            gold: progress.gold,
                            xp: progress.xp,
                            xpProgress: xpProgress,
                            glowColor: widget.mode.glowColor,
                            onBack: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: 16),
                          _MapTitleRibbon(
                            title: usedFallback
                                ? 'Yedek Macera Haritası'
                                : 'AI Macera Haritası',
                            subtitle: usedFallback
                                ? 'AI cevap vermezse yedek görevler gösterilir.'
                                : 'Görevler yapay zeka ile üretildi.',
                            glowColor: widget.mode.glowColor,
                          ),
                          const SizedBox(height: 12),
                          _VisualAdventureMapCanvas(
                            chapters: chapters,
                            progress: progress,
                            currentActiveChapterId: currentActiveChapterId,
                            glowColor: widget.mode.glowColor,
                            sceneAssetForChapter: sceneAssetForChapter,
                            onChapterTap: openChapter,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdventureLoadingView extends StatelessWidget {
  final String topic;
  final String mode;
  final Color glowColor;

  const _AdventureLoadingView({
    required this.topic,
    required this.mode,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 80, 28, 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1514).withOpacity(0.94),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: glowColor.withOpacity(0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                  backgroundColor: Colors.white.withOpacity(0.10),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Macera Üretiliyor',
                style: TextStyle(
                  color: Color(0xFFFFE7B2),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$topic konusu $mode moduna dönüştürülüyor.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'AI görev adlarını, hikâyeyi, açıklamaları ve quizleri hazırlıyor.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.48),
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapTopHeader extends StatelessWidget {
  final String title;
  final String field;
  final String topic;
  final String level;
  final int gold;
  final int xp;
  final double xpProgress;
  final Color glowColor;
  final VoidCallback onBack;

  const _MapTopHeader({
    required this.title,
    required this.field,
    required this.topic,
    required this.level,
    required this.gold,
    required this.xp,
    required this.xpProgress,
    required this.glowColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.45),
                  border: Border.all(
                    color: const Color(0xFFFFD58A).withOpacity(0.55),
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
                  color: Color(0xFFFFE7B2),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B2A1D).withOpacity(0.92),
                      const Color(0xFF111827).withOpacity(0.92),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFD58A).withOpacity(0.36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFD58A).withOpacity(0.16),
                        border: Border.all(
                          color: const Color(0xFFFFD58A).withOpacity(0.5),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '🪙',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFFE7B2),
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Bilgiyi maceraya çevir.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.58),
                              fontSize: 11.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1514).withOpacity(0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD58A).withOpacity(0.25),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SmallInfoBox(
                      label: 'Alan',
                      value: field,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallInfoBox(
                      label: 'Konu',
                      value: topic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallInfoBox(
                      label: 'Seviye',
                      value: level,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _CurrencyBox(
                    icon: '🪙',
                    label: 'Altın',
                    value: '$gold',
                  ),
                  const SizedBox(width: 9),
                  _CurrencyBox(
                    icon: '✨',
                    label: 'XP',
                    value: '$xp/100',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: xpProgress,
                  minHeight: 9,
                  backgroundColor: Colors.black.withOpacity(0.32),
                  valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallInfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _SmallInfoBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFFFD58A).withOpacity(0.70),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.3,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyBox extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _CurrencyBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD58A).withOpacity(0.16),
          ),
        ),
        child: Row(
          children: [
            Text(icon),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.56),
                fontSize: 10.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFFE7B2),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapTitleRibbon extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color glowColor;

  const _MapTitleRibbon({
    required this.title,
    required this.subtitle,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD58A).withOpacity(0.95),
            const Color(0xFF8A5A2D).withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.explore_rounded,
            color: Color(0xFF2B170D),
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2B170D),
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
                    color: const Color(0xFF2B170D).withOpacity(0.72),
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
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

class _VisualAdventureMapCanvas extends StatelessWidget {
  final List<AdventureChapter> chapters;
  final AdventureProgress progress;
  final int currentActiveChapterId;
  final Color glowColor;
  final String Function(int chapterId) sceneAssetForChapter;
  final ValueChanged<AdventureChapter> onChapterTap;

  const _VisualAdventureMapCanvas({
    required this.chapters,
    required this.progress,
    required this.currentActiveChapterId,
    required this.glowColor,
    required this.sceneAssetForChapter,
    required this.onChapterTap,
  });

  List<Offset> _nodeTopLefts(double width) {
    final right = (width - 165).clamp(145.0, 205.0);
    final left = 2.0;

    return [
      Offset(left, 18),
      Offset(right, 140),
      Offset(left + 12, 285),
      Offset(right - 8, 430),
      Offset(left + 15, 585),
      Offset(right - 6, 735),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final nodePositions = _nodeTopLefts(constraints.maxWidth);

        final roadPoints = <Offset>[
          for (int i = 0; i < nodePositions.length; i++)
            Offset(
              nodePositions[i].dx + 78,
              nodePositions[i].dy + 76,
            ),
        ];

        return SizedBox(
          height: 930,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CurvedRoadPainter(
                    points: roadPoints,
                    activeIndex: currentActiveChapterId - 1,
                    completedChapters: progress.completedChapters,
                    glowColor: glowColor,
                  ),
                ),
              ),
              ...List.generate(chapters.length, (index) {
                final chapter = chapters[index];
                final unlocked = chapter.id <= progress.unlockedChapter;
                final completed =
                    progress.completedChapters.contains(chapter.id);
                final active = chapter.id == currentActiveChapterId;

                return Positioned(
                  left: nodePositions[index].dx,
                  top: nodePositions[index].dy,
                  child: _RoadNodeCard(
                    chapter: chapter,
                    imagePath: sceneAssetForChapter(chapter.id),
                    unlocked: unlocked,
                    completed: completed,
                    active: active,
                    glowColor: glowColor,
                    onTap: () => onChapterTap(chapter),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _RoadNodeCard extends StatelessWidget {
  final AdventureChapter chapter;
  final String imagePath;
  final bool unlocked;
  final bool completed;
  final bool active;
  final Color glowColor;
  final VoidCallback onTap;

  const _RoadNodeCard({
    required this.chapter,
    required this.imagePath,
    required this.unlocked,
    required this.completed,
    required this.active,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = chapter.isBoss ? 138.0 : 124.0;
    final imageWidth = chapter.isBoss ? 148.0 : 140.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 165,
        child: Column(
          children: [
            if (active)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.72, end: 1.0),
                duration: const Duration(milliseconds: 780),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: glowColor.withOpacity(0.20),
                        border: Border.all(color: glowColor),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(0.55),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Şu anki görev',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: active ? 0.98 : 1.0,
                end: active ? 1.04 : 1.0,
              ),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: imageWidth,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: glowColor.withOpacity(0.78),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.16),
                                    blurRadius: 12,
                                  ),
                                ]
                              : completed
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF60D394)
                                            .withOpacity(0.42),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : unlocked
                                      ? [
                                          BoxShadow(
                                            color: glowColor.withOpacity(0.22),
                                            blurRadius: 14,
                                            offset: const Offset(0, 7),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.36),
                                            blurRadius: 13,
                                            offset: const Offset(0, 7),
                                          ),
                                        ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Opacity(
                                opacity: unlocked ? 1 : 0.30,
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1C1D28),
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: const Text(
                                        'Görsel yok',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (!unlocked)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.48),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                              if (active)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: glowColor.withOpacity(0.95),
                                      width: 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!unlocked)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.66),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white70,
                            size: 22,
                          ),
                        ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: _NodeBadge(
                          unlocked: unlocked,
                          completed: completed,
                          active: active,
                          chapterId: chapter.id,
                          isBoss: chapter.isBoss,
                          glowColor: glowColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Transform.translate(
              offset: const Offset(0, -7),
              child: Container(
                width: 155,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: unlocked
                        ? [
                            const Color(0xFF3B2A1D).withOpacity(0.96),
                            const Color(0xFF111827).withOpacity(0.96),
                          ]
                        : [
                            Colors.black.withOpacity(0.60),
                            Colors.black.withOpacity(0.44),
                          ],
                  ),
                  border: Border.all(
                    color: active
                        ? glowColor
                        : completed
                            ? const Color(0xFF60D394)
                            : unlocked
                                ? const Color(0xFFFFD58A).withOpacity(0.30)
                                : Colors.white.withOpacity(0.12),
                    width: active ? 1.8 : 1.1,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: glowColor.withOpacity(0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.26),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    Text(
                      chapter.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFE7B2),
                        fontSize: 11.6,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      chapter.isBoss
                          ? 'Final Boss'
                          : active
                              ? 'Devam edilen görev'
                              : chapter.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.56),
                        fontSize: 9.4,
                        fontWeight: FontWeight.w700,
                      ),
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

class _NodeBadge extends StatelessWidget {
  final bool unlocked;
  final bool completed;
  final bool active;
  final int chapterId;
  final bool isBoss;
  final Color glowColor;

  const _NodeBadge({
    required this.unlocked,
    required this.completed,
    required this.active,
    required this.chapterId,
    required this.isBoss,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    String text;

    if (completed) {
      text = '✓';
    } else if (!unlocked) {
      text = '🔒';
    } else if (isBoss) {
      text = 'B';
    } else {
      text = '$chapterId';
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? const Color(0xFF60D394)
            : active
                ? glowColor
                : unlocked
                    ? const Color(0xFFFFD58A)
                    : const Color(0xFF1C1D28),
        border: Border.all(
          color: Colors.white.withOpacity(0.60),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.7),
                  blurRadius: 16,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: (completed || active || unlocked)
                ? const Color(0xFF231309)
                : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CurvedRoadPainter extends CustomPainter {
  final List<Offset> points;
  final int activeIndex;
  final Set<int> completedChapters;
  final Color glowColor;

  _CurvedRoadPainter({
    required this.points,
    required this.activeIndex,
    required this.completedChapters,
    required this.glowColor,
  });

  Path _segmentPath(Offset a, Offset b) {
    final midY = (a.dy + b.dy) / 2;

    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(
        a.dx,
        midY,
        b.dx,
        midY,
        b.dx,
        b.dy,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseRoadPaint = Paint()
      ..color = const Color(0xFF514A44).withOpacity(0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 42
      ..strokeCap = StrokeCap.round;

    final innerRoadPaint = Paint()
      ..color = const Color(0xFF8A7868).withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round;

    final greenCompletedGlow = Paint()
      ..color = const Color(0xFF60D394).withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final activeGlowPaint = Paint()
      ..color = glowColor.withOpacity(0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);

    final centerLinePaint = Paint()
      ..color = const Color(0xFFFFE7B2).withOpacity(0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      final segment = _segmentPath(points[i], points[i + 1]);
      final fromChapter = i + 1;

      final completedSegment = completedChapters.contains(fromChapter);
      final activeSegment = i < activeIndex;

      canvas.drawPath(segment, baseRoadPaint);
      canvas.drawPath(segment, innerRoadPaint);

      if (completedSegment) {
        canvas.drawPath(segment, greenCompletedGlow);
        canvas.drawPath(segment, centerLinePaint);
      } else if (activeSegment) {
        canvas.drawPath(segment, activeGlowPaint);
        canvas.drawPath(segment, centerLinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedRoadPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.completedChapters != completedChapters ||
        oldDelegate.glowColor != glowColor;
  }
}