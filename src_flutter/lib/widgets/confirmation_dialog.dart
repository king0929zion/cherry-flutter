import 'package:flutter/material.dart';

/// ConfirmationDialog - 确认对话框
/// 统一的确认操作对话框
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final bool isDangerous;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.isDangerous = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? '取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: isDangerous
              ? FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                )
              : null,
          child: Text(confirmText ?? '确定'),
        ),
      ],
    );
  }

  /// 显示确认对话框并返回结果
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
      ),
    );
    return result ?? false;
  }
}

/// DeleteConfirmationDialog - 删除确认对话框
class DeleteConfirmationDialog extends StatelessWidget {
  final String itemName;
  final String? itemType;

  const DeleteConfirmationDialog({
    super.key,
    required this.itemName,
    this.itemType,
  });

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: '确认删除',
      message: '确定要删除${itemType ?? ""}「$itemName」吗？\n此操作不可撤销。',
      confirmText: '删除',
      isDangerous: true,
    );
  }

  static Future<bool> show(
    BuildContext context, {
    required String itemName,
    String? itemType,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => DeleteConfirmationDialog(
        itemName: itemName,
        itemType: itemType,
      ),
    );
    return result ?? false;
  }
}
