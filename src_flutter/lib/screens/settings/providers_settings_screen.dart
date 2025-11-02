import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/provider_settings.dart';
import '../../providers/model_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/model_selector.dart';
import '../../models/model.dart';

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
  double _temperature = 0.7;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(providerSettingsProvider);
    _providerIdCtrl = TextEditingController(text: settings.providerId);
    _baseUrlCtrl = TextEditingController(text: settings.baseUrl);
    _modelCtrl = TextEditingController(text: settings.model);
    _apiKeyCtrl = TextEditingController(text: settings.apiKey);
    _temperature = settings.temperature;
  }

  @override
  void dispose() {
    _providerIdCtrl.dispose();
    _baseUrlCtrl.dispose();
    _modelCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final settings = ref.read(providerSettingsProvider);
    final notifier = ref.read(providerSettingsProvider.notifier);

    await notifier.update(
      settings.copyWith(
        providerId: _providerIdCtrl.text.trim(),
        baseUrl: _baseUrlCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        apiKey: _apiKeyCtrl.text.trim(),
        temperature: _temperature,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
    }
  }

  Future<void> _testConnection() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已发送测试请求（模拟）')),
      );
    }
  }

  void _fillOpenAI() {
    setState(() {
      _providerIdCtrl.text = 'openai';
      _baseUrlCtrl.text = 'https://api.openai.com/v1';
      _modelCtrl.text = 'gpt-4o';
      _temperature = 0.7;
    });
  }

  void _copyApiKey() {
    Clipboard.setData(ClipboardData(text: _apiKeyCtrl.text));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('API Key 已复制')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('供应商设置'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _SummaryCard(
            providerIdController: _providerIdCtrl,
            baseUrlController: _baseUrlCtrl,
            onFillDefault: _fillOpenAI,
          ),
          const SizedBox(height: 20),
          _ApiCard(
            baseUrlController: _baseUrlCtrl,
            apiKeyController: _apiKeyCtrl,
            obscureApiKey: _obscureApiKey,
            onToggleObscure: () => setState(() {
              _obscureApiKey = !_obscureApiKey;
            }),
            onCopy: _copyApiKey,
          ),
          const SizedBox(height: 20),
          _ModelCard(
            modelController: _modelCtrl,
            temperature: _temperature,
            onTemperatureChanged: (value) => setState(() => _temperature = value),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _testConnection,
                        icon: const Icon(Icons.bolt_outlined, size: 18),
                        label: const Text('测试连接'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          _modelCtrl.text = 'gpt-4o-mini';
                          setState(() => _temperature = 0.6);
                        },
                        icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                        label: const Text('使用轻量模型'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _providerIdCtrl.clear();
                            _baseUrlCtrl.clear();
                            _modelCtrl.clear();
                            _apiKeyCtrl.clear();
                            _temperature = 0.7;
                          });
                        },
                        icon: const Icon(Icons.restore_outlined, size: 18),
                        label: const Text('重置配置'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '提示：保存只会更新本机配置，不会上传至服务器。建议不要在公共设备保存敏感密钥。',
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
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final TextEditingController providerIdController;
  final TextEditingController baseUrlController;
  final VoidCallback onFillDefault;

  const _SummaryCard({
    required this.providerIdController,
    required this.baseUrlController,
    required this.onFillDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark ? Tokens.blueDark20 : Tokens.blue10,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.cloud_outlined,
                      color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '供应商信息',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '配置 API 供应商的基本信息。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Tokens.textSecondaryDark
                              : Tokens.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onFillDefault,
                  child: const Text('使用默认'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Provider ID', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            TextField(
              controller: providerIdController,
              decoration: InputDecoration(
                hintText: 'openai',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Base URL', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            TextField(
              controller: baseUrlController,
              decoration: InputDecoration(
                hintText: 'https://api.openai.com/v1',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiCard extends StatelessWidget {
  final TextEditingController baseUrlController;
  final TextEditingController apiKeyController;
  final bool obscureApiKey;
  final VoidCallback onToggleObscure;
  final VoidCallback onCopy;

  const _ApiCard({
    required this.baseUrlController,
    required this.apiKeyController,
    required this.obscureApiKey,
    required this.onToggleObscure,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '认证信息',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'API Key 将仅保存在本地设备；可随时复制或替换。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Tokens.textSecondaryDark
                    : Tokens.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              obscureText: obscureApiKey,
              decoration: InputDecoration(
                hintText: 'sk-xxxxxxxx',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        obscureApiKey ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                      ),
                      onPressed: onToggleObscure,
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 20),
                      onPressed: onCopy,
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

class _ModelCard extends StatelessWidget {
  final TextEditingController modelController;
  final double temperature;
  final ValueChanged<double> onTemperatureChanged;

  const _ModelCard({
    required this.modelController,
    required this.temperature,
    required this.onTemperatureChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模型配置',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '选择默认模型并调节温度（随机性）。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Tokens.textSecondaryDark
                    : Tokens.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: modelController,
              decoration: InputDecoration(
                hintText: 'gpt-4o',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temperature',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  temperature.toStringAsFixed(2),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            Slider(
              value: temperature.clamp(0.0, 2.0),
              min: 0,
              max: 2,
              divisions: 20,
              label: temperature.toStringAsFixed(2),
              onChanged: onTemperatureChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('严谨'),
                Text('平衡'),
                Text('创意'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
