import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher_string.dart';

import '../theme/tokens.dart';

/// Markdown 渲染组件，复刻 Cherry Studio 的段落、列表与代码块样式。
class CherryMarkdown extends StatelessWidget {
  const CherryMarkdown({
    super.key,
    required this.data,
    this.isUserBubble = false,
  });

  final String data;
  final bool isUserBubble;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? Tokens.textPrimaryDark : Tokens.textPrimaryLight;
    final secondaryColor =
        isDark ? Tokens.textSecondaryDark : Tokens.textSecondaryLight;

    final styleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      blockSpacing: 18,
      p: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 16,
        height: 1.56,
        color: textColor,
      ),
      h1: theme.textTheme.headlineSmall?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      h4: theme.textTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      h5: theme.textTheme.titleSmall?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      h6: theme.textTheme.titleSmall?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      code: TextStyle(
        backgroundColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.04),
        color: Tokens.brand,
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        height: 1.4,
      ),
      codeblockPadding: EdgeInsets.zero,
      codeblockDecoration: const BoxDecoration(),
      blockquotePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      blockquoteDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2D30) : const Color(0xFFF7F6F3),
        border: Border(
          left: BorderSide(
            color: Tokens.brand,
            width: 3,
          ),
        ),
      ),
      blockquote: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 16,
        height: 1.56,
        fontStyle: FontStyle.italic,
        color: secondaryColor,
      ),
      strong: const TextStyle(fontWeight: FontWeight.w700),
      em: const TextStyle(fontStyle: FontStyle.italic),
      a: const TextStyle(
        color: Tokens.textLink,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w600,
      ),
      listBullet: TextStyle(
        fontSize: 16,
        color: textColor,
      ),
      tableBorder: TableBorder.all(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
      ),
      tableHead: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      tableBody: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
      ),
    );

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: styleSheet,
      extensionSet: md.ExtensionSet.gitHubWeb,
      builders: {
        'pre': _CodeBlockBuilder(
          context,
          isDark: isDark,
        ),
      },
      onTapLink: (text, href, title) => _handleLinkTap(context, href),
    );
  }
}

void _handleLinkTap(BuildContext context, String? href) {
  if (href == null) return;
  final uri = Uri.tryParse(href);
  if (uri == null) return;

  unawaited(
    launchUrlString(
      uri.toString(),
      mode: LaunchMode.externalApplication,
    ).then((opened) {
      if (opened || !context.mounted) return;
      _showMessage(context, '无法打开链接');
    }).catchError((_) {
      if (!context.mounted) return;
      _showMessage(context, '无法打开链接');
    }),
  );
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message)),
    );
}

class _CodeBlockBuilder extends MarkdownElementBuilder {
  _CodeBlockBuilder(this.context, {required this.isDark});

  final BuildContext context;
  final bool isDark;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag != 'pre') return null;

    final codeElement = element.children?.firstWhere(
      (child) => child is md.Element && child.tag == 'code',
      orElse: () => null,
    );
    if (codeElement is! md.Element) return null;

    final classAttr = codeElement.attributes['class'] ?? '';
    final language = _normalizeLanguage(classAttr);
    final codeContent = codeElement.textContent.trimRight();

    return _CherryCodeBlock(
      code: codeContent,
      language: language,
      isDark: isDark,
      onCopy: (value) async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!context.mounted) return;
        _showMessage(context, '代码已复制');
      },
    );
  }

  @override
  bool get isBlockElement => true;
}

class _CherryCodeBlock extends StatelessWidget {
  const _CherryCodeBlock({
    required this.code,
    required String? language,
    required this.isDark,
    required this.onCopy,
  }) : _language = language;

  final String code;
  final String? _language;
  final bool isDark;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final normalized = _language ?? 'text';
    final displayLang = normalized.toUpperCase();
    final assetPath = _codeLanguageAsset(normalized);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);
    final headerBackground =
        isDark ? const Color(0xFF1E2126) : const Color(0xFFF2F4F5);
    final bodyBackground =
        isDark ? const Color(0xFF202327) : const Color(0xFFF7F6F3);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: bodyBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerBackground,
              border: Border(
                bottom: BorderSide(color: borderColor),
              ),
            ),
            child: Row(
              children: [
                if (assetPath != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      assetPath,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                Text(
                  displayLang,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Tokens.textPrimaryDark
                            : Tokens.textPrimaryLight,
                      ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => onCopy(code),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: isDark
                          ? Tokens.textPrimaryDark
                          : Tokens.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: bodyBackground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _codeLanguageAsset(String language) {
  return _codeLanguageAssets[language];
}

String? _normalizeLanguage(String? raw) {
  if (raw == null || raw.isEmpty) return null;

  var value = raw.toLowerCase().trim();
  value = value.replaceAll('language-', '');
  if (value.isEmpty) return null;

  switch (value) {
    case 'js':
    case 'jsx':
    case 'javascript':
    case 'node':
      return 'javascript';
    case 'ts':
    case 'tsx':
    case 'typescript':
      return 'typescript';
    case 'c++':
    case 'cpp':
      return 'cpp';
    case 'c#':
    case 'csharp':
      return 'csharp';
    case 'py':
    case 'python':
      return 'python';
    case 'java':
      return 'java';
    case 'go':
    case 'golang':
      return 'go';
    case 'css':
      return 'css';
    case 'rust':
    case 'rs':
      return 'rust';
    case 'c':
      return 'c';
    default:
      return value;
  }
}

const Map<String, String> _codeLanguageAssets = {
  'javascript': 'assets/images/code_language_icons/Javascript.png',
  'typescript': 'assets/images/code_language_icons/Typescript.png',
  'c': 'assets/images/code_language_icons/C.png',
  'cpp': 'assets/images/code_language_icons/Cplusplus.png',
  'csharp': 'assets/images/code_language_icons/Csharp.png',
  'css': 'assets/images/code_language_icons/Css.png',
  'go': 'assets/images/code_language_icons/Go.png',
  'java': 'assets/images/code_language_icons/Java.png',
  'python': 'assets/images/code_language_icons/Python.png',
  'rust': 'assets/images/code_language_icons/Rust.png',
};
