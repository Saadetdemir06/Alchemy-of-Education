import 'package:flutter/material.dart';

import '../models/quest_theme.dart';

class ThemeCard extends StatelessWidget {
  final QuestTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.025 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFBFA7FF)
                  : Colors.white.withOpacity(0.10),
              width: isSelected ? 2.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF8B5CF6).withOpacity(0.40)
                    : Colors.black.withOpacity(0.30),
                blurRadius: isSelected ? 28 : 14,
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
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.03),
                        Colors.black.withOpacity(0.30),
                        Colors.black.withOpacity(0.94),
                      ],
                    ),
                  ),
                ),

                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(27),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.14),
                            const Color(0xFF8B5CF6).withOpacity(0.12),
                          ],
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFFF8FAFC)
                          : Colors.black.withOpacity(0.45),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 19,
                            color: Color(0xFF111322),
                          )
                        : null,
                  ),
                ),

                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
                      const SizedBox(height: 7),
                      Text(
                        theme.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.84),
                          fontSize: 11.5,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 10,
                            ),
                          ],
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