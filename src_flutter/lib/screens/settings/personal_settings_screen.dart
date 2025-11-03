import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_settings.dart';
import '../../theme/tokens.dart';
import '../../widgets/header_bar.dart';

class PersonalSettingsScreen extends ConsumerStatefulWidget {
  const PersonalSettingsScreen({super.key});

  @override
  ConsumerState<PersonalSettingsScreen> createState() => _PersonalSettingsScreenState();
}

class _PersonalSettingsScreenState extends ConsumerState<PersonalSettingsScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userSettingsProvider);
    _nameController = TextEditingController(text: user.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userSettingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_nameController.text != user.displayName) {
      _nameController.value = TextEditingValue(
        text: user.displayName,
        selection: TextSelection.collapsed(offset: user.displayName.length),
      );
    }

    final avatarBytes = user.avatarBytes;

    return Scaffold(
      backgroundColor: isDark ? Tokens.bgPrimaryDark : Tokens.bgPrimaryLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderBar(
              title: '个人资料',
              leftButton: HeaderBarButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight,
                ),
                onPress: () => context.pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F25) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.25)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isDark
                                ? const [Color(0xFF2A2E37), Color(0xFF1F2229)]
                                : const [Color(0xFFF2F5F0), Color(0xFFE6EFE2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              avatarBytes == null ? null : MemoryImage(avatarBytes),
                          child:
                              avatarBytes == null ? const Text('🍒', style: TextStyle(fontSize: 36)) : null,
                        ),
                      ),
                      Material(
                        color: isDark ? Tokens.greenDark100 : Tokens.green100,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _pickAvatar,
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '显示昵称',
                      hintText: '输入名称',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Tokens.brand.withOpacity(0.8), width: 1.6),
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(userSettingsProvider.notifier).updateDisplayName(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _pickAvatar,
                        child: const Text('更换头像'),
                      ),
                      const SizedBox(width: 12),
                      if (avatarBytes != null)
                        TextButton(
                          onPressed: _clearAvatar,
                          child: const Text('恢复默认头像'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '个人资料仅保存在本地设备，不会同步到服务器。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight,
                height: 1.45,
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

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final mime = _inferMimeType(file.extension);
    await ref.read(userSettingsProvider.notifier).updateAvatar(Uint8List.fromList(bytes), mimeType: mime);
  }

  Future<void> _clearAvatar() async {
    await ref.read(userSettingsProvider.notifier).updateAvatar(null);
  }

  String _inferMimeType(String? extension) {
    final ext = extension?.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/png';
    }
  }
}
