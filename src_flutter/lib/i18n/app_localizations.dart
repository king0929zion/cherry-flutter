import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // 通用
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get done => _localizedValues[locale.languageCode]!['done']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get copy => _localizedValues[locale.languageCode]!['copy']!;
  String get translate => _localizedValues[locale.languageCode]!['translate']!;
  String get regenerate => _localizedValues[locale.languageCode]!['regenerate']!;

  // 设置
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get generalSettings => _localizedValues[locale.languageCode]!['generalSettings']!;
  String get assistantSettings => _localizedValues[locale.languageCode]!['assistantSettings']!;
  String get providerSettings => _localizedValues[locale.languageCode]!['providerSettings']!;
  String get modelSettings => _localizedValues[locale.languageCode]!['modelSettings']!;
  String get dataSourceSettings => _localizedValues[locale.languageCode]!['dataSourceSettings']!;
  String get webSearchSettings => _localizedValues[locale.languageCode]!['webSearchSettings']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get personalSettings => _localizedValues[locale.languageCode]!['personalSettings']!;

  // 供应商设置
  String get providerInfo => _localizedValues[locale.languageCode]!['providerInfo']!;
  String get authenticationInfo => _localizedValues[locale.languageCode]!['authenticationInfo']!;
  String get modelConfig => _localizedValues[locale.languageCode]!['modelConfig']!;
  String get quickActions => _localizedValues[locale.languageCode]!['quickActions']!;
  String get testConnection => _localizedValues[locale.languageCode]!['testConnection']!;
  String get useDefault => _localizedValues[locale.languageCode]!['useDefault']!;
  String get useLightweightModel => _localizedValues[locale.languageCode]!['useLightweightModel']!;
  String get resetConfig => _localizedValues[locale.languageCode]!['resetConfig']!;
  String get providerId => _localizedValues[locale.languageCode]!['providerId']!;
  String get baseUrl => _localizedValues[locale.languageCode]!['baseUrl']!;
  String get apiKey => _localizedValues[locale.languageCode]!['apiKey']!;
  String get temperature => _localizedValues[locale.languageCode]!['temperature']!;
  String get model => _localizedValues[locale.languageCode]!['model']!;
  String get settingsSaved => _localizedValues[locale.languageCode]!['settingsSaved']!;

  // 模型管理
  String get currentModel => _localizedValues[locale.languageCode]!['currentModel']!;
  String get availableModels => _localizedValues[locale.languageCode]!['availableModels']!;
  String get customModels => _localizedValues[locale.languageCode]!['customModels']!;
  String get addCustomModel => _localizedValues[locale.languageCode]!['addCustomModel']!;
  String get noAvailableModels => _localizedValues[locale.languageCode]!['noAvailableModels']!;
  String get noCustomModels => _localizedValues[locale.languageCode]!['noCustomModels']!;
  String get selectModel => _localizedValues[locale.languageCode]!['selectModel']!;
  String get modelAdded => _localizedValues[locale.languageCode]!['modelAdded']!;
  String get modelUpdated => _localizedValues[locale.languageCode]!['modelUpdated']!;
  String get modelDeleted => _localizedValues[locale.languageCode]!['modelDeleted']!;
  String get switchModel => _localizedValues[locale.languageCode]!['switchModel']!;
  String get contextLength => _localizedValues[locale.languageCode]!['contextLength']!;
  String get maxOutput => _localizedValues[locale.languageCode]!['maxOutput']!;
  String get inputPrice => _localizedValues[locale.languageCode]!['inputPrice']!;
  String get outputPrice => _localizedValues[locale.languageCode]!['outputPrice']!;
  String get capabilities => _localizedValues[locale.languageCode]!['capabilities']!;
  String get availability => _localizedValues[locale.languageCode]!['availability']!;
  String get pricing => _localizedValues[locale.languageCode]!['pricing']!;

  // MCP
  String get mcpServers => _localizedValues[locale.languageCode]!['mcpServers']!;
  String get addServer => _localizedValues[locale.languageCode]!['addServer']!;
  String get editServer => _localizedValues[locale.languageCode]!['editServer']!;
  String get serverName => _localizedValues[locale.languageCode]!['serverName']!;
  String get description => _localizedValues[locale.languageCode]!['description']!;
  String get serverType => _localizedValues[locale.languageCode]!['serverType']!;
  String get headers => _localizedValues[locale.languageCode]!['headers']!;
  String get timeout => _localizedValues[locale.languageCode]!['timeout']!;
  String get isActive => _localizedValues[locale.languageCode]!['isActive']!;
  String get testConnectionSuccess => _localizedValues[locale.languageCode]!['testConnectionSuccess']!;
  String get testConnectionFailed => _localizedValues[locale.languageCode]!['testConnectionFailed']!;
  String get serverDeleted => _localizedValues[locale.languageCode]!['serverDeleted']!;
  String get serverCreated => _localizedValues[locale.languageCode]!['serverCreated']!;
  String get serverUpdated => _localizedValues[locale.languageCode]!['serverUpdated']!;
  String get mcpMarket => _localizedValues[locale.languageCode]!['mcpMarket']!;
  String get recommendedServers => _localizedValues[locale.languageCode]!['recommendedServers']!;
  String get serverCategories => _localizedValues[locale.languageCode]!['serverCategories']!;
  String get install => _localizedValues[locale.languageCode]!['install']!;

  // 工具调用
  String get pending => _localizedValues[locale.languageCode]!['pending']!;
  String get inProgress => _localizedValues[locale.languageCode]!['inProgress']!;
  String get completed => _localizedValues[locale.languageCode]!['completed']!;
  String get failed => _localizedValues[locale.languageCode]!['failed']!;
  String get arguments => _localizedValues[locale.languageCode]!['arguments']!;
  String get response => _localizedValues[locale.languageCode]!['response']!;
  String get errorInfo => _localizedValues[locale.languageCode]!['errorInfo']!;
  String get createdAt => _localizedValues[locale.languageCode]!['createdAt']!;
  String get completedAt => _localizedValues[locale.languageCode]!['completedAt']!;

  // 聊天
  String get newTopic => _localizedValues[locale.languageCode]!['newTopic']!;
  String get selectAssistant => _localizedValues[locale.languageCode]!['selectAssistant']!;
  String get myAssistants => _localizedValues[locale.languageCode]!['myAssistants']!;
  String get recentTopics => _localizedValues[locale.languageCode]!['recentTopics']!;
  String get noTopics => _localizedValues[locale.languageCode]!['noTopics']!;
  String get generating => _localizedValues[locale.languageCode]!['generating']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get copied => _localizedValues[locale.languageCode]!['copied']!;

  // 助手
  String get myAssistant => _localizedValues[locale.languageCode]!['myAssistant']!;
  String get assistantDetails => _localizedValues[locale.languageCode]!['assistantDetails']!;
  String get assistantMarket => _localizedValues[locale.languageCode]!['assistantMarket']!;
  String get defaultAssistant => _localizedValues[locale.languageCode]!['defaultAssistant']!;
  String get quickAssistant => _localizedValues[locale.languageCode]!['quickAssistant']!;
  String get translateAssistant => _localizedValues[locale.languageCode]!['translateAssistant']!;

  // 关于
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get updateLog => _localizedValues[locale.languageCode]!['updateLog']!;
  String get officialWebsite => _localizedValues[locale.languageCode]!['officialWebsite']!;
  String get issueFeedback => _localizedValues[locale.languageCode]!['issueFeedback']!;
  String get openSourceLicense => _localizedValues[locale.languageCode]!['openSourceLicense']!;
  String get contactUs => _localizedValues[locale.languageCode]!['contactUs']!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // 通用
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',
      'confirm': 'Confirm',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'close': 'Close',
      'copy': 'Copy',
      'translate': 'Translate',
      'regenerate': 'Regenerate',

      // 设置
      'settings': 'Settings',
      'generalSettings': 'General Settings',
      'assistantSettings': 'Assistant Settings',
      'providerSettings': 'Provider Settings',
      'modelSettings': 'Model Settings',
      'dataSourceSettings': 'Data Source Settings',
      'webSearchSettings': 'Web Search Settings',
      'about': 'About',
      'personalSettings': 'Personal Settings',

      // 供应商设置
      'providerInfo': 'Provider Information',
      'authenticationInfo': 'Authentication Information',
      'modelConfig': 'Model Configuration',
      'quickActions': 'Quick Actions',
      'testConnection': 'Test Connection',
      'useDefault': 'Use Default',
      'useLightweightModel': 'Use Lightweight Model',
      'resetConfig': 'Reset Configuration',
      'providerId': 'Provider ID',
      'baseUrl': 'Base URL',
      'apiKey': 'API Key',
      'temperature': 'Temperature',
      'model': 'Model',
      'settingsSaved': 'Settings saved',

      // 模型管理
      'currentModel': 'Current Model',
      'availableModels': 'Available Models',
      'customModels': 'Custom Models',
      'addCustomModel': 'Add Custom Model',
      'noAvailableModels': 'No available models',
      'noCustomModels': 'No custom models',
      'selectModel': 'Select Model',
      'modelAdded': 'Model added',
      'modelUpdated': 'Model updated',
      'modelDeleted': 'Model deleted',
      'switchModel': 'Switch Model',
      'contextLength': 'Context Length',
      'maxOutput': 'Max Output',
      'inputPrice': 'Input Price',
      'outputPrice': 'Output Price',
      'capabilities': 'Capabilities',
      'availability': 'Availability',
      'pricing': 'Pricing',

      // MCP
      'mcpServers': 'MCP Servers',
      'addServer': 'Add Server',
      'editServer': 'Edit Server',
      'serverName': 'Server Name',
      'description': 'Description',
      'serverType': 'Server Type',
      'headers': 'Headers',
      'timeout': 'Timeout',
      'isActive': 'Active',
      'testConnectionSuccess': 'Connection successful',
      'testConnectionFailed': 'Connection failed',
      'serverDeleted': 'Server deleted',
      'serverCreated': 'Server created',
      'serverUpdated': 'Server updated',
      'mcpMarket': 'MCP Market',
      'recommendedServers': 'Recommended Servers',
      'serverCategories': 'Server Categories',
      'install': 'Install',

      // 工具调用
      'pending': 'Pending',
      'inProgress': 'In Progress',
      'completed': 'Completed',
      'failed': 'Failed',
      'arguments': 'Arguments',
      'response': 'Response',
      'errorInfo': 'Error Info',
      'createdAt': 'Created At',
      'completedAt': 'Completed At',

      // 聊天
      'newTopic': 'New Topic',
      'selectAssistant': 'Select Assistant',
      'myAssistants': 'My Assistants',
      'recentTopics': 'Recent Topics',
      'noTopics': 'No topics',
      'generating': 'Generating...',
      'cancel': 'Cancel',
      'copied': 'Copied',

      // 助手
      'myAssistant': 'My Assistant',
      'assistantDetails': 'Assistant Details',
      'assistantMarket': 'Assistant Market',
      'defaultAssistant': 'Default Assistant',
      'quickAssistant': 'Quick Assistant',
      'translateAssistant': 'Translate Assistant',

      // 关于
      'version': 'Version',
      'updateLog': 'Update Log',
      'officialWebsite': 'Official Website',
      'issueFeedback': 'Issue Feedback',
      'openSourceLicense': 'Open Source License',
      'contactUs': 'Contact Us',
    },
    'zh': {
      // 通用
      'ok': '确定',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'edit': '编辑',
      'add': '添加',
      'search': '搜索',
      'loading': '加载中...',
      'error': '错误',
      'success': '成功',
      'retry': '重试',
      'confirm': '确认',
      'back': '返回',
      'next': '下一步',
      'done': '完成',
      'close': '关闭',
      'copy': '复制',
      'translate': '翻译',
      'regenerate': '重新生成',

      // 设置
      'settings': '设置',
      'generalSettings': '通用设置',
      'assistantSettings': '助手设置',
      'providerSettings': '供应商设置',
      'modelSettings': '模型管理',
      'dataSourceSettings': '数据管理',
      'webSearchSettings': '网页搜索',
      'about': '关于',
      'personalSettings': '个人资料',

      // 供应商设置
      'providerInfo': '供应商信息',
      'authenticationInfo': '认证信息',
      'modelConfig': '模型配置',
      'quickActions': '快捷操作',
      'testConnection': '测试连接',
      'useDefault': '使用默认',
      'useLightweightModel': '使用轻量模型',
      'resetConfig': '重置配置',
      'providerId': '供应商 ID',
      'baseUrl': '基础 URL',
      'apiKey': 'API 密钥',
      'temperature': '温度',
      'model': '模型',
      'settingsSaved': '设置已保存',

      // 模型管理
      'currentModel': '当前模型',
      'availableModels': '可用模型',
      'customModels': '自定义模型',
      'addCustomModel': '添加自定义模型',
      'noAvailableModels': '暂无可用模型',
      'noCustomModels': '暂无自定义模型',
      'selectModel': '选择模型',
      'modelAdded': '模型已添加',
      'modelUpdated': '模型已更新',
      'modelDeleted': '模型已删除',
      'switchModel': '更换模型',
      'contextLength': '上下文长度',
      'maxOutput': '最大输出',
      'inputPrice': '输入价格',
      'outputPrice': '输出价格',
      'capabilities': '功能特性',
      'availability': '可用状态',
      'pricing': '定价信息',

      // MCP
      'mcpServers': 'MCP 服务器',
      'addServer': '添加服务器',
      'editServer': '编辑服务器',
      'serverName': '服务器名称',
      'description': '描述',
      'serverType': '服务器类型',
      'headers': '请求头',
      'timeout': '超时时间',
      'isActive': '启用状态',
      'testConnectionSuccess': '连接成功',
      'testConnectionFailed': '连接失败',
      'serverDeleted': '服务器已删除',
      'serverCreated': '服务器已创建',
      'serverUpdated': '服务器已更新',
      'mcpMarket': 'MCP 市场',
      'recommendedServers': '推荐服务器',
      'serverCategories': '服务器分类',
      'install': '安装',

      // 工具调用
      'pending': '等待中',
      'inProgress': '执行中',
      'completed': '已完成',
      'failed': '执行失败',
      'arguments': '参数',
      'response': '响应结果',
      'errorInfo': '错误信息',
      'createdAt': '创建时间',
      'completedAt': '完成时间',

      // 聊天
      'newTopic': '新建主题',
      'selectAssistant': '选择助手',
      'myAssistants': '我的助手',
      'recentTopics': '最近主题',
      'noTopics': '暂无主题',
      'generating': '正在生成...',
      'cancel': '取消',
      'copied': '已复制',

      // 助手
      'myAssistant': '我的助手',
      'assistantDetails': '助手详情',
      'assistantMarket': '助手市场',
      'defaultAssistant': '默认助手',
      'quickAssistant': '快速助手',
      'translateAssistant': '翻译助手',

      // 关于
      'version': '版本',
      'updateLog': '更新日志',
      'officialWebsite': '官方网站',
      'issueFeedback': '问题反馈',
      'openSourceLicense': '开源协议',
      'contactUs': '联系我们',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations._localizedValues.containsKey(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}