# Cherry Flutter - Cherry Studio 移动端应用

这是一个使用 Flutter 完全复刻 [Cherry Studio](https://github.com/Cherry-Studio/cherry-studio-app) 的移动端应用项目。目标是达到与原项目"像素级一致"的 UI 外观与交互体验。

## 📋 项目概述

Cherry Flutter 是 Cherry Studio 的 Flutter 版本,专注于 Android 平台,提供与原 React Native 版本完全一致的用户体验。

### 核心功能

- ✨ **AI 对话** - 支持流式输出、消息翻译、重新生成、长按操作
- 🎨 **主题系统** - 完整的明暗模式切换,颜色系统完全对齐原项目
- 📝 **Markdown 渲染** - 支持代码高亮、表格等完整 Markdown 语法
- 📎 **附件支持** - 图片、文件的选择与预览
- 🤖 **助手管理** - 助手列表、详情、市场占位
- 🔧 **灵活配置** - 供应商设置、模型选择、温度调节
- 🔍 **Web 搜索** - 支持命令式搜索 `/search <关键词>`
- 🔌 **MCP 服务器** - MCP 服务器管理与配置
- 💾 **数据管理** - 支持 JSON 格式的备份与导入
- 🌐 **国际化** - 中英文双语支持

## 🏗️ 技术架构

### 核心技术栈

- **框架**: Flutter 3.x
- **状态管理**: flutter_riverpod v3 (Notifier/NotifierProvider)
- **路由**: go_router (匹配原项目的抽屉/栈结构)
- **本地存储**: Hive (topics/messages/blocks/prefs)
- **UI**: Material3 + 自定义主题 Token
- **Markdown**: flutter_markdown
- **附件**: file_picker + Base64 存储
- **国际化**: flutter_localizations

### 项目结构

```
src_flutter/lib/
├── main.dart                 # 应用入口
├── app_router.dart          # 路由配置
├── theme/                   # 主题系统
│   ├── app_theme.dart      # 主题构建
│   └── tokens.dart         # 颜色 Token(对齐 Tailwind)
├── models/                  # 数据模型
│   ├── topic.dart
│   ├── message.dart
│   ├── block.dart
│   ├── assistant.dart
│   └── attachment.dart
├── providers/               # Riverpod 状态管理
│   ├── app_state.dart
│   ├── theme.dart
│   ├── locale.dart
│   ├── streaming.dart
│   ├── provider_settings.dart
│   ├── mcp_settings.dart
│   └── web_search_settings.dart
├── services/                # 业务逻辑服务
│   ├── llm_service.dart    # LLM 流式调用
│   ├── message_service.dart
│   ├── block_service.dart
│   ├── assistant_service.dart
│   ├── prefs_service.dart
│   └── topic_service.dart
├── screens/                 # 页面
│   ├── welcome/            # 欢迎页
│   ├── home/               # 主页(聊天)
│   ├── topic/              # 主题列表
│   ├── assistant/          # 助手管理
│   ├── mcp/                # MCP 服务器
│   └── settings/           # 设置页面
├── widgets/                 # 公共组件
└── data/                    # 数据层
    └── boxes.dart          # Hive Box 初始化
```

## 🚀 快速开始

### 前置要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code (推荐安装 Flutter 插件)

### 安装依赖

```bash
cd src_flutter
flutter pub get
```

### 运行应用

```bash
# 查看可用设备
flutter devices

# 在指定设备运行
flutter run -d <device>

# Debug 模式运行
flutter run

# Release 模式运行
flutter run --release
```

### 构建 APK

```bash
# 构建 Release APK
flutter build apk --release

# APK 输出路径
# src_flutter/build/app/outputs/flutter-apk/app-release.apk
```

## ⚙️ 配置说明

### 初次使用

1. 启动应用后,进入 **设置 → 供应商设置**
2. 填写以下信息:
   - **Base URL**: OpenAI API 地址(或兼容的 API 服务)
   - **Model**: 模型名称(如 `gpt-3.5-turbo`)
   - **API Key**: 你的 API 密钥
   - **Temperature**: 温度参数(0-2,默认 0.7)

### Web 搜索

在聊天中使用 `/search <关键词>` 可触发 DuckDuckGo 搜索。

可在 **设置 → 网页搜索设置** 中自定义搜索 endpoint 模板。

### 数据备份

- **导出**: 设置 → 通用设置 → 备份数据
- **导入**: 设置 → 通用设置 → 导入数据

备份格式为 JSON,包含所有主题、消息、助手配置等。

## 🎨 UI 设计规范

本项目严格遵循原 Cherry Studio 的 UI 设计,确保像素级一致:

- ✅ 颜色值完全对齐 Tailwind 配置
- ✅ 圆角、阴影、间距、字体保持一致
- ✅ 组件布局与原项目完全相同
- ✅ 动画与转场效果尽可能匹配

### 主题 Token

所有颜色定义在 `lib/theme/tokens.dart`,直接映射自原项目的 `tailwind.config.js`。

## 🔧 开发指南

### 代码规范

- 使用 `flutter_riverpod` 进行状态管理
- 所有页面组件放在 `screens/` 目录
- 通用组件放在 `widgets/` 目录
- 业务逻辑封装在 `services/` 目录
- 遵循 Flutter 官方代码风格指南

### 添加新功能

1. 在 `models/` 中定义数据模型
2. 在 `services/` 中实现业务逻辑
3. 在 `providers/` 中创建状态管理
4. 在 `screens/` 中实现 UI
5. 在 `app_router.dart` 中添加路由

## 📦 CI/CD

项目使用 GitHub Actions 自动构建:

- **触发**: 每次 push 到仓库
- **流程**: 安装 Flutter → 依赖 → 构建 APK
- **产物**: `app-release.apk` (自动上传为 artifact)

## ⚠️ 注意事项

- **安全**: 不要提交 API Key、密钥等敏感信息到仓库
- **平台**: 当前仅支持 Android,Web 构建已移除
- **差异**: 因平台限制导致的 UI 差异会在提交信息中注明

## 📝 开发进度

详见 [AGENTS.md](./AGENTS.md) 文件。

### 已完成

- ✅ Flutter 工程骨架与 CI/CD
- ✅ 核心路由与导航结构
- ✅ 聊天流式输出与 Markdown 渲染
- ✅ 消息长按操作(翻译/复制/重新生成/删除)
- ✅ 附件选择与预览
- ✅ 供应商设置与通用设置
- ✅ MCP 服务器管理基础
- ✅ 中英文国际化

### 进行中

- 🚧 Drawer UI 像素级还原
- 🚧 Chat Header 完整样式
- 🚧 Message 气泡样式优化
- 🚧 MessageInput 按钮布局与动效

### 待完成

- ⏳ 助手市场与详情页面
- ⏳ 模型列表选择器
- ⏳ 工具调用 UI
- ⏳ 性能优化(大列表、图片内存)
- ⏳ App 图标与启动图

## 🤝 贡献指南

1. 创建功能分支
2. 开发并自测通过
3. 提交时注明功能变化与平台差异
4. 合并主干前确保构建通过

## 📄 许可证

与原项目保持一致。

## 🔗 相关链接

- [原项目 - Cherry Studio](https://github.com/Cherry-Studio/cherry-studio-app)
- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev)

---

**注**: 本项目处于活跃开发中,UI 和功能持续完善以达到与原项目完全一致。
