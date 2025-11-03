import 'dart:math';

import 'package:flutter/material.dart';

import '../../../models/assistant.dart';
import '../../../theme/tokens.dart';

class AssistantMarketCard extends StatelessWidget {
  final AssistantModel assistant;
  final VoidCallback onTap;

  const AssistantMarketCard({
    super.key,
    required this.assistant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final emojiOpacity = isDark ? 0.2 : 0.4; // Platform.OS === 'android' ? (isDark ? 0.1 : 0.9) : isDark ? 0.2 : 0.4

    // 匹配原项目：p-1.5 w-full h-[230px] bg-ui-card-background rounded-2xl
    return Padding(
      padding: const EdgeInsets.all(6), // p-1.5 = 6px
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16), // rounded-2xl
          child: Container(
            height: 230, // h-[230px]
            decoration: BoxDecoration(
              color: isDark ? Tokens.cardDark : Tokens.cardLight, // bg-ui-card-background
              borderRadius: BorderRadius.circular(16), // rounded-2xl
            ),
            child: Stack(
              children: [
                // Background blur emoji - 匹配原项目：w-full h-1/2 absolute top-0 scale-150
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 115, // h-1/2 = 230/2
                  child: Wrap(
                    children: List.generate(8, (index) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 8,
                        child: Transform.scale(
                          scale: 1.5, // scale-150
                          child: Center(
                            child: Text(
                              assistant.emoji ?? '🤖',
                              style: TextStyle(
                                fontSize: 40,
                                opacity: emojiOpacity,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Content - 匹配原项目：flex-1 gap-2 items-center rounded-2xl py-4 px-3.5
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), // py-4 px-3.5
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // EmojiAvatar - 匹配原项目：size={90} borderWidth={5} borderColor
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFF7F7F7),
                              width: 5, // borderWidth={5}
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            assistant.emoji ?? '🤖',
                            style: const TextStyle(fontSize: 45), // size * 0.5
                          ),
                        ),
                        const SizedBox(height: 8), // gap-2
                        // Name - 匹配原项目：text-base text-center
                        Text(
                          assistant.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16, // text-base
                            fontWeight: FontWeight.normal,
                            color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        // Description and Tags - 匹配原项目：flex-1 justify-between items-center
                        Column(
                          children: [
                            // Description - 匹配原项目：text-xs leading-[14px]
                            Text(
                              assistant.description ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12, // text-xs
                                height: 14 / 12, // leading-[14px]
                                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Group Tags - 匹配原项目：gap-2.5 flex-wrap h-[18px] justify-center
                            Wrap(
                              spacing: 10, // gap-2.5
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: (assistant.group ?? []).take(3).map((group) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // py-0.5 px-1
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20), // rounded-[20px]
                                    color: isDark ? Tokens.greenDark10 : Tokens.green10,
                                    border: Border.all(
                                      color: isDark ? Tokens.greenDark20 : Tokens.green20,
                                      width: 0.5, // border-[0.5px]
                                    ),
                                  ),
                                  child: Text(
                                    group.isNotEmpty 
                                        ? '${group[0].toUpperCase()}${group.substring(1)}'
                                        : group,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 10, // text-[10px]
                                      color: isDark ? Tokens.greenDark100 : Tokens.green100,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _EmojiBackdrop extends StatelessWidget {
  final String emoji;

  const _EmojiBackdrop({required this.emoji});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = isDark ? 0.12 : 0.26;
    final random = Random(emoji.hashCode);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(
              painter: _EmojiGridPainter(emoji: emoji, random: random),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmojiGridPainter extends CustomPainter {
  final String emoji;
  final Random random;

  _EmojiGridPainter({required this.emoji, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    const columns = 4;
    const rows = 4;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var x = 0; x < columns; x++) {
      for (var y = 0; y < rows; y++) {
        final scale = 0.8 + random.nextDouble() * 0.6;
        textPainter.text = TextSpan(
          text: emoji,
          style: TextStyle(fontSize: 24 * scale),
        );
        textPainter.layout();
        final offset = Offset(
          x * cellWidth + (cellWidth - textPainter.width) / 2,
          y * cellHeight + (cellHeight - textPainter.height) / 2,
        );
        textPainter.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color border;
  final Color foreground;

  const _TagChip({
    required this.label,
    required this.background,
    required this.border,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          height: 1.1,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
