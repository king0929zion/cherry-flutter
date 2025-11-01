import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/provider_settings.dart';
import '../../widgets/settings_group.dart';
import '../../theme/tokens.dart';

/// ProvidersSettingsScreen - 供应商设置页面
/// 像素级还原原项目UI和布局
class ProvidersSettingsScreen extends ConsumerStatefulWidget {
  const ProvidersSettingsScreen({super.key});

  @override
  ConsumerState<ProvidersSettingsScreen> createState() => _ProvidersSettingsScreenState();
}

class _ProvidersSettingsScreenState extends ConsumerState<ProvidersSettingsScreen> {
  late TextEditingController _providerIdCtrl;
  late TextEditingController _baseUrlCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _tempCtrl;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(providerSettingsProvider);
    _providerIdCtrl = TextEditingController(text: settings.providerId);
    _baseUrlCtrl = TextEditingController(text: settings.baseUrl);
    _modelCtrl = TextEditingController(text: settings.model);
    _apiKeyCtrl = TextEditingController(text: settings.apiKey);
    _tempCtrl = TextEditingController(text: settings.temperature.toString());
  }

  @override
  void dispose() {
    _providerIdCtrl.dispose();
    _baseUrlCtrl.dispose();
    _modelCtrl.dispose();
    _apiKeyCtrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final settings = ref.read(providerSettingsProvider);
    final notifier = ref.read(providerSettingsProvider.notifier);
    
    final t = double.tryParse(_tempCtrl.text.trim());
    await notifier.update(settings.copyWith(
      providerId: _providerIdCtrl.text.trim(),
      baseUrl: _baseUrlCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      apiKey: _apiKeyCtrl.text.trim(),
      temperature: t ?? settings.temperature,
    ));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('供应商设置'), // TODO: i18n
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Provider 基本信息
          const SettingsSectionTitle(title: '基本信息'),
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Provider ID',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _providerIdCtrl,
                      decoration: InputDecoration(
                        hintText: 'openai',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // API 配置
          const SettingsSectionTitle(title: 'API 配置'),
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Base URL
                    Text('Base URL', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _baseUrlCtrl,
                      decoration: InputDecoration(
                        hintText: 'https://api.openai.com/v1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // API Key
                    Text('API Key', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apiKeyCtrl,
                      obscureText: _obscureApiKey,
                      decoration: InputDecoration(
                        hintText: 'sk-...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscureApiKey = !_obscureApiKey);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 模型设置
          const SettingsSectionTitle(title: '模型设置'),
          const SizedBox(height: 8),
          SettingsGroup(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model
                    Text('模型', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _modelCtrl,
                      decoration: InputDecoration(
                        hintText: 'gpt-4',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Temperature
                    Text('Temperature', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tempCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0.7',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '控制输出随机性，范围 0-2',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark 
                          ? Tokens.textSecondaryDark 
                          : Tokens.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
