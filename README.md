# Cherry Flutter – Cherry Studio 移动端复刻

Cherry Flutter 旨在使用 Flutter 1:1 复刻 [Cherry Studio](https://github.com/Cherry-Studio/cherry-studio-app) 的移动端体验，覆盖从主题色、排版到交互细节的完整还原。项目专注 Android 平台，并通过 GitHub Actions 自动构建 APK。

## 🌟 核心功能

- **聊天体验**：流式输出、Markdown 渲染、长按菜单（翻译 / 复制 / 重新生成 / 删除）、附件选择与预览。
- **助手体系**：自定义助手管理、角色绑定（默认 / 快速 / 翻译）、助手市场（网格卡片 + BottomSheet 详情 + 导入使用）。
- **供应商与模型**：配置 Base URL / 模型 / API Key / 温度，包含快捷操作与连接测试入口。
- **通用设置**：主题模式（系统 / 浅色 / 深色）、语言切换（中 / 英）、数据导入导出。
- **主题列表**：搜索、时间分组、当前会话高亮、重命名与删除操作。
- **MCP 管理**：基础的服务增删与持久化。
- **国际化**：Flutter 本地化管线实现中英双语。

## 🧱 技术栈

- **框架**：Flutter 3.x
- **状态管理**：flutter_riverpod v3（Notifier/NotifierProvider）
- **路由**：go_router（ShellRoute + Drawer）
- **本地存储**：Hive（topics / messages / blocks / prefs）
- **UI**：Material 3 + 自定义 Tokens（完全对齐原项目）
- **Markdown**：flutter_markdown
- **附件**：file_picker + Base64 存储

## 📁 项目结构

```
src_flutter/
├── assets/data/assistants-*.json   # 内置助手数据（中/英）
├── lib/
│   ├── app_router.dart             # 路由配置
│   ├── data/boxes.dart             # Hive Box 管理
│   ├── models/                     # 数据模型
│   ├── providers/                  # Riverpod Provider
│   ├── screens/                    # 页面模块
│   ├── services/                   # 业务逻辑
│   ├── theme/                      # 主题 / Tokens
│   └── widgets/                    # 通用组件
└── main.dart
```

## 🚀 快速开始

```bash
cd src_flutter
flutter pub get
flutter run            # Debug 运行
flutter build apk      # Release 构建
```

> 📌 项目默认只构建 Android，如需 Web / iOS 请手动调整配置。

## ⚙️ 首次配置

1. 启动应用 → **设置 → 供应商设置**。
2. 填写 Base URL / Model / API Key / Temperature（默认 0.7）。
3. 可在 **助手市场** 直接导入内置助手。
4. **通用设置 → 数据导出** 可备份当前会话，导入会覆盖所有数据。

## 🎨 UI 设计规范

- 组件尺寸、圆角、阴影、字重与行高均对齐原 Tailwind 配置。
- 色值全部来自 `lib/theme/tokens.dart`，区分明暗模式。
- 动画与过渡尽量保持与 React Native 版本一致。
- 列表和卡片遵循 12/16 间距网格，按钮遵循 44px 可点区域。

## 🛠️ 开发指南

1. 数据模型放在 `models/`，业务逻辑放在 `services/`。
2. 所有状态通过 Riverpod Provider 管理，避免直接依赖单例。
3. 公共 UI 组件统一沉淀在 `widgets/`，带有语义命名。
4. 新页面请同时补充路由、导航及文档说明。
5. 推送前执行 `flutter analyze` 和必要的集成测试（当前环境未附带）。

## 📈 开发进度

### 已完成

- Flutter 工程骨架与 CI/CD
- 抽屉导航(AppShell) 与聊天头部
- 聊天流式输出与 Markdown 渲染
- 消息长按操作（翻译 / 复制 / 重新生成 / 删除）
- 附件选择与预览
- 供应商设置、通用设置与数据备份（卡片化 UI + 快捷操作）
- MCP 服务器管理基础
- 中英文国际化
- 助手角色绑定（默认 / 快速 / 翻译）
- 助手市场 UI（网格卡片 + 详情 BottomSheet + 导入流程）
- 主题列表卡片化、搜索、分组、重命名 / 删除

### 进行中

- 模型选择器与模型管理面板
- 工具调用链路与回显界面
- 长列表性能优化（消息 / 附件）

### 待完成

- 完成剩余国际化文案
- 应用图标与启动页资源
- 更丰富的供应商校验与错误提示

## 📦 CI/CD

- GitHub Actions 自动构建 Android APK，并上传 `android-apk` Artifact。
- Workflow 会自动复制 `src_flutter/assets` 并注入 `pubspec.yaml`。

## 🤝 贡献指南

1. 新建功能分支，开发完成后提交 Pull Request。
2. 在 PR 中简述改动内容、风险与测试结果。
3. 发现 UI 细节与原版不一致，请附上截图对比。

## 📄 许可

根据原项目许可协议保持一致。

## 🔗 相关链接

- [Cherry Studio（原仓库）](https://github.com/Cherry-Studio/cherry-studio-app)
- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev)
