import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WelcomeTitle - 打字机效果的欢迎标题
class WelcomeTitle extends ConsumerStatefulWidget {
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final int speed; // 打字速度（毫秒）

  const WelcomeTitle({
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.speed = 60,
  });

  @override
  ConsumerState<WelcomeTitle> createState() => _WelcomeTitleState();
}

class _WelcomeTitleState extends ConsumerState<WelcomeTitle> {
  final List<String> _messages = ['欢迎使用 Cherry Studio', 'Welcome to Cherry Studio'];
  int _messageIndex = 0;
  int _charIndex = 0;
  String _displayedText = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _timer?.cancel();
    _messageIndex = 0;
    _charIndex = 0;
    _displayedText = '';
    _typeNextChar();
  }

  void _typeNextChar() {
    if (_messageIndex >= _messages.length) {
      // 循环：清空并重新开始
      _messageIndex = 0;
      _charIndex = 0;
      _displayedText = '';
      _timer = Timer(Duration(milliseconds: widget.speed * 5), _typeNextChar);
      return;
    }

    final currentMessage = _messages[_messageIndex];
    if (_charIndex >= currentMessage.length) {
      // 当前消息完成，等待后清空并切换到下一个
      _timer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _displayedText = '';
            _charIndex = 0;
            _messageIndex++;
          });
          _typeNextChar();
        }
      });
      return;
    }

    if (mounted) {
      setState(() {
        _displayedText = currentMessage.substring(0, _charIndex + 1);
        _charIndex++;
      });
      _timer = Timer(Duration(milliseconds: widget.speed), _typeNextChar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      _displayedText,
      style: TextStyle(
        fontSize: widget.fontSize ?? 30,
        fontWeight: widget.fontWeight ?? FontWeight.bold,
        color: widget.color ?? theme.textTheme.titleLarge?.color,
      ),
    );
  }
}

