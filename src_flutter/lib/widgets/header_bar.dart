import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

class HeaderBarButton {
  final Widget icon;
  final VoidCallback onPress;

  const HeaderBarButton({
    required this.icon,
    required this.onPress,
  });
}

class HeaderBar extends StatelessWidget {
  final String? title;
  final VoidCallback? onBackPress;
  final HeaderBarButton? leftButton;
  final HeaderBarButton? rightButton;
  final List<HeaderBarButton>? rightButtons;
  final bool showBackButton;

  const HeaderBar({
    super.key,
    this.title,
    this.onBackPress,
    this.leftButton,
    this.rightButton,
    this.rightButtons,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonsToRender = rightButtons ?? (rightButton != null ? [rightButton!] : []);

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 左侧区域
          SizedBox(
            minWidth: 40,
            child: leftButton != null
                ? _buildButton(leftButton!)
                : showBackButton
                    ? _buildButton(HeaderBarButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                        ),
                        onPress: onBackPress ?? () => Navigator.maybePop(context),
                      ))
                    : const SizedBox(width: 40),
          ),
          // 标题区域
          Expanded(
            child: Center(
              child: Text(
                title ?? '',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // 右侧区域
          SizedBox(
            minWidth: 40,
            child: buttonsToRender.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: buttonsToRender
                        .map((button) => Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: _buildButton(button),
                            ))
                        .toList(),
                  )
                : const SizedBox(width: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(HeaderBarButton button) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: button.onPress,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: button.icon,
        ),
      ),
    );
  }
}

