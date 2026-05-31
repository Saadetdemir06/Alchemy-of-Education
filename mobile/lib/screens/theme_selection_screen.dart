import 'package:flutter/material.dart';

import '../models/quest_field.dart';
import '../models/quest_theme.dart';

class ThemeSelectionScreen extends StatefulWidget {
  final QuestField field;
  final String topic;
  final String level;

  const ThemeSelectionScreen({
    super.key,
    required this.field,
    required this.topic,
    required this.level,
  });

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  QuestTheme selectedTheme = questThemes.first;
  bool isCreating = false;

  void createQuest() async {
    if (isCreating) return;

    setState(() {
      isCreating = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      isCreating = false;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111528),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Quest blueprint is ready',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.topic} will become a ${selectedTheme.title} quest.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.66),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _SummaryTile(
                title: 'Field',
                subtitle: widget.field.title,
              ),
              const SizedBox(height: 10),
              _SummaryTile(
                title: 'Level',
                subtitle: widget.level,
              ),
              const SizedBox(height: 10),
              _SummaryTile(
                title: 'World',
                subtitle: selectedTheme.title,
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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
    return _MobileFrame(
      child: PopScope(
        canPop: !isCreating,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.35,
                colors: [
                  Color(0xFF25215A),
                  Color(0xFF080B18),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 96),
                    children: [
                      _TopBar(
                        onBack: () {
                          if (!isCreating) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _QuestInfoCard(
                        field: widget.field.title,
                        topic: widget.topic,
                        level: widget.level,
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle(
                        title: 'Choose a world',
                        subtitle:
                            'This changes how the topic will be remembered.',
                      ),
                      const SizedBox(height: 14),
                      ...questThemes.map((theme) {
                        final selected = selectedTheme.title == theme.title;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ThemeChoiceCard(
                            theme: theme,
                            selected: selected,
                            onTap: () {
                              if (isCreating) return;
                              setState(() {
                                selectedTheme = theme;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: _MainButton(
                      isLoading: isCreating,
                      text: 'Create Quest',
                      onTap: createQuest,
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

class _MobileFrame extends StatelessWidget {
  final Widget child;

  const _MobileFrame({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: child,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'World Selection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestInfoCard extends StatelessWidget {
  final String field;
  final String topic;
  final String level;

  const _QuestInfoCard({
    required this.field,
    required this.topic,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.28),
            const Color(0xFF22D3EE).withOpacity(0.10),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your quest base',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          _MiniLine(label: 'Field', value: field),
          const SizedBox(height: 7),
          _MiniLine(label: 'Topic', value: topic),
          const SizedBox(height: 7),
          _MiniLine(label: 'Level', value: level),
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  final String label;
  final String value;

  const _MiniLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
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
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeChoiceCard extends StatelessWidget {
  final QuestTheme theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoiceCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 172,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected
                ? const Color(0xFFBFA7FF)
                : Colors.white.withOpacity(0.10),
            width: selected ? 2.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF8B5CF6).withOpacity(0.36)
                  : Colors.black.withOpacity(0.24),
              blurRadius: selected ? 28 : 14,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
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
                      'Image not found',
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
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.88),
                      Colors.black.withOpacity(0.58),
                      Colors.black.withOpacity(0.18),
                    ],
                  ),
                ),
              ),
              if (selected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                ),
              Positioned(
                top: 13,
                right: 13,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? Colors.white
                        : Colors.black.withOpacity(0.42),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 19,
                          color: Color(0xFF111322),
                        )
                      : null,
                ),
              ),
              Positioned(
                left: 16,
                right: 72,
                top: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      theme.feeling,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF67E8F9).withOpacity(0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      theme.purpose,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 12.2,
                        height: 1.32,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.48),
            fontSize: 12.5,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _MainButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onTap;

  const _MainButton({
    required this.isLoading,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLoading,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.72 : 1,
        duration: const Duration(milliseconds: 160),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF22D3EE),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.34),
                blurRadius: 24,
                offset: const Offset(0, 14),
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
                borderRadius: BorderRadius.circular(21),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SummaryTile({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.065),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.56),
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}