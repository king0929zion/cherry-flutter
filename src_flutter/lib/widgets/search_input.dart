import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class SearchInput extends StatelessWidget {
  final String? placeholder;
  final ValueChanged<String>? onChangeText;
  final String? value;
  final TextEditingController? controller;

  const SearchInput({
    super.key,
    this.placeholder,
    this.onChangeText,
    this.value,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveController = controller ?? TextEditingController(text: value);

    if (controller == null && value != null) {
      effectiveController.text = value!;
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: effectiveController,
        onChanged: onChangeText,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          isDense: true,
        ),
      ),
    );
  }
}

