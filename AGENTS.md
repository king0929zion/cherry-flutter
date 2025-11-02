# Cherry Flutter 复刻计划（AGENTS）

## 🎯 项目目标

- 使用 Flutter 完整复刻 Cherry Studio 的移动端 UI 与交互，做到“像素级一致”。
- 所有颜色、间距、圆角、字体、动效、手势与状态反馈与原项目保持一致；如遇技术限制需在文档中注明。
- 只针对 Android 平台，构建与交付通过 GitHub Actions 自动化完成。

## ✅ 当前完成进度

- **架构与工程**
  - Flutter 工程 + GitHub Actions 全自动构建（Android APK）。
  - 文档体系完善：《README.md》《AGENTS.md》实时更新。
  - 依赖：riverpod v3、go_router、hive、http、flutter_markdown、file_picker 等。
- **核心功能**
  - 导航结构：Welcome / Drawer / ShellRoute / 页面子路由。
  - 聊天体验：流式输出、Markdown 渲染、长按动作、附件处理、翻译块。
  - 主题管理：搜索、时间分组、卡片化展示、重命名 / 删除、当前主题高亮。
  - 助手体系：列表、详情、角色绑定、助手市场（网格卡片 + BottomSheet + 导入流程）。
  - 供应商 & 模型：卡片化设置、温度滑块、快捷操作、连接测试。
  - 通用设置：主题模式、语言切换、数据导出/导入、危险操作提示。
  - MCP 管理：服务增删、持久化（交互暂为基础形态）。
  - 国际化：中英双语切换。
- **主题 & UI**
  - 完整迁移 Tailwind Token 至 `tokens.dart`，支持明暗模式。
  - AppShell、ChatHeader、MessageBubble、MessageInput 均与原版匹配。
  - 助手市场、设置模块、主题列表等页面实现卡片化布局与动效。

## 📌 待办与路线图

1. **像素级 UI 收尾**
   - 模型选择器 + 模型管理面板。
   - 工具调用工作流与结果回显 UI。
   - 剩余页面（如关于、MCP 详情）的动效和细节微调。
2. **交互与功能**
   - 助手市场的推荐/搜索排序优化，分页体验。
   - 流式消息的错误处理与断点续传。
   - 供应商配置的高级校验 & 错误提示。
3. **工程 & 体验**
   - 国际化文案全覆盖（含错误提示）。
   - App 图标 / 启动页资源（对齐原版）。
   - 更细粒度的性能优化（长列表、图片缓存等）。

## ⚠️ 风险与注意事项

- 涉及 API Key 等敏感信息均只保存在本地 Hive，不可提交仓库。
- 因平台差异导致的无法复刻项需在 PR/文档中说明。
- 任何 UI 改动必须与原版对齐后再合并。

## 🆕 最新更新记录

### 2025-11-02 助手市场与设置 UI 升级 ✅
- 完成助手市场网格卡片、搜索、详情 BottomSheet 的 Flutter 复刻。
- 引入内置助手数据资产（中/英）并接入导入与聊天流程。
- 供应商 / 通用 / 数据管理页面升级为卡片化布局，加入温度滑块、快捷操作与安全提示。
- 更新 GitHub Actions 自动复制 `src_flutter/assets` 并注入 `pubspec.yaml`，保证构建一致性。

### 2025-11-02 聊天 Markdown & 气泡细节复刻 ✅
- 调整 MessageBubble 结构与圆角，重现原版绿色填充、边框与投影。
- 新增 CherryMarkdown 组件，定制代码块工具栏、引用块与链接行为，Markdown 样式与原项目一致。
- 引入原项目代码语言图标并更新 CI，确保 GitHub Actions 构建时自动声明资产路径。

### 2025-11-02 构建修复 🔧
- 修复 MessageBubble 缺失闭合、上下文菜单类位置导致的编译报错。
- 调整 CherryMarkdown 代码块构建器覆写方式，兼容 flutter_markdown 0.7.7+1 的 API。
