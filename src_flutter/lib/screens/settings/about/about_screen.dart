import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/tokens.dart';
import '../../../widgets/settings_group.dart';

/// AboutScreen - 关于页面
/// 像素级还原原项目UI和布局
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // 版本号 - 可以从 pubspec.yaml 读取或硬编码
  static const String _version = '1.0.0';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'), // TODO: i18n
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.code, size: 24),
            onPressed: () => _openUrl('https://github.com/CherryHQ/cherry-studio-app'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo 和描述
          SettingsGroup(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo - 70x70, 圆角 41px
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Tokens.brand,
                        borderRadius: BorderRadius.circular(41),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // gap-4
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4), // py-1
                          
                          // 标题 - 22px, bold
                          const Text(
                            'Cherry Studio',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 5), // gap-[5px]
                          
                          // 描述 - text-sm, secondary color
                          Text(
                            'AI 桌面客户端，支持多平台多模型', // TODO: i18n
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark 
                                ? Tokens.textSecondaryDark 
                                : Tokens.textSecondaryLight,
                            ),
                          ),
                          
                          const SizedBox(height: 5),
                          
                          // 版本标签 - green badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, // px-2
                              vertical: 2, // py-0.5
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Tokens.greenDark10 : Tokens.green10,
                              border: Border.all(
                                color: isDark ? Tokens.greenDark20 : Tokens.green20,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(25.37),
                            ),
                            child: Text(
                              'v$_version',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Tokens.greenDark100 : Tokens.green100,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24), // gap-6

          // 链接列表
          SettingsGroup(
            children: [
              _buildLinkItem(
                icon: Icons.article_outlined,
                title: '更新日志', // TODO: i18n
                onTap: () => _openUrl('https://github.com/CherryHQ/cherry-studio-app/releases/'),
                isDark: isDark,
              ),
              _buildDivider(theme),
              _buildLinkItem(
                icon: Icons.public,
                title: '官方网站', // TODO: i18n
                onTap: () => _openUrl('https://www.cherry-ai.com/'),
                isDark: isDark,
              ),
              _buildDivider(theme),
              _buildLinkItem(
                icon: Icons.bug_report_outlined,
                title: '问题反馈', // TODO: i18n
                onTap: () => _openUrl('https://github.com/CherryHQ/cherry-studio-app/issues/'),
                isDark: isDark,
              ),
              _buildDivider(theme),
              _buildLinkItem(
                icon: Icons.copyright_outlined,
                title: '开源协议', // TODO: i18n
                onTap: () => _openUrl('https://github.com/CherryHQ/cherry-studio/blob/main/LICENSE/'),
                isDark: isDark,
              ),
              _buildDivider(theme),
              _buildLinkItem(
                icon: Icons.email_outlined,
                title: '联系我们', // TODO: i18n
                onTap: () => _openUrl('https://docs.cherry-ai.com/contact-us/questions/'),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10), // gap-[10px] 或 gap-3 (12px)
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_outward, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 46, // icon 20 + gap 10 + padding 16
      color: theme.dividerColor,
    );
  }
}
