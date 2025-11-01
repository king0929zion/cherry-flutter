import 'dart:math';

import 'package:flutter/material.dart';

import '../../../services/assistant_service.dart';
import '../../../theme/tokens.dart';

class AssistantMarketCard extends StatelessWidget {
  final Assistant assistant;
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
    final backgroundColor = isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight;
    final borderColor = isDark ? Tokens.borderDark : Tokens.borderLight;
    final blurColor = (assistant.emoji ?? '🤖');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor.withOpacity(0.12), width: 1),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _EmojiBackdrop(emoji: blurColor),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor.withOpacity(isDark ? 0.82 : 0.9),
                      backgroundColor,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.05 : 0.18),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(isDark ? 0.15 : 0.25),
                          width: 4,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        assistant.emoji ?? '🤖',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      assistant.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        assistant.description ?? assistant.prompt ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.35,
                          color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: [
                        if (assistant.group != null)
                          ...assistant.group!
                              .take(3)
                              .map((g) => _TagChip(
                                    label: g,
                                    background: isDark ? Tokens.greenDark10 : Tokens.green10,
                                    border: isDark ? Tokens.greenDark20 : Tokens.green20,
                                    foreground: isDark ? Tokens.greenDark100 : Tokens.green100,
                                  )),
                        if (assistant.tags != null)
                          ...assistant.tags!
                              .take(2)
                              .map((t) => _TagChip(
                                    label: t,
                                    background: isDark ? Tokens.orangeDark10 : Tokens.orange10,
                                    border: isDark ? Tokens.orangeDark20 : Tokens.orange20,
                                    foreground: isDark ? Tokens.orangeDark100 : Tokens.orange100,
                                  )),
                      ],
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
