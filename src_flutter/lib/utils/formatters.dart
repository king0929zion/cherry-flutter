/// Formatters - 格式化工具类
/// 提供各种数据格式化功能

import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// 格式化时间戳为相对时间（今天、昨天等）
  static String formatRelativeTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      // 今天
      return DateFormat('HH:mm').format(date);
    } else if (diff.inDays == 1) {
      // 昨天
      return '昨天 ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays < 7) {
      // 本周
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      // 本月
      return '${(diff.inDays / 7).floor()}周前';
    } else if (diff.inDays < 365) {
      // 今年
      return DateFormat('MM-dd').format(date);
    } else {
      // 更早
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  /// 格式化时间戳为完整时间
  static String formatFullTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 格式化数字（添加千位分隔符）
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  /// 截断文本并添加省略号
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// 格式化消息数量（1k, 1m等）
  static String formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}m';
    }
  }

  /// 格式化百分比
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// 高亮搜索文本
  static String highlightSearch(String text, String query) {
    if (query.isEmpty) return text;
    // 简单实现，可以扩展为更复杂的高亮逻辑
    return text.replaceAll(
      RegExp(query, caseSensitive: false),
      '**$query**',
    );
  }
}
