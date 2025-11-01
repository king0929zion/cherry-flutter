# Cherry Flutter 复刻计划（AGENTS 文档）

## 目标与范围

- 目标：用 Flutter 完全复刻 `G:\Cherry-Studio\cherry-studio-app` 的 UI 与交互逻辑，达到“像素级一致”的外观与行为（颜色、间距、圆角、尺寸、字体、图标、动画、手势、状态反馈等全部一致）。
- 范围：
  - 导航与路由（抽屉/分组栈/欢迎页/设置子页等）
  - 聊天（消息列表、Markdown 渲染、流式输出、取消、重新生成、长按操作、翻译、附件图片/文件块）
  - 主题与配色（明暗模式、主题 Token 对齐）
  - 助手（列表、详情、市场占位）、模型/供应商设置
  - Web 搜索与工具调用（命令式“/search …”已提供基础能力）
  - MCP 服务器管理（占位与配置管理）
  - 数据层与备份导入（Hive JSON 导入导出）
  - 构建与发布（GitHub Actions：每次推送自动构建 Android APK）

## 当前完成进度（截至最新提交）

- 工程与 CI
  - 完成 Flutter 工程骨架与 GitHub Actions，仅构建 Android APK（web 构建已移除）。
  - 依赖：riverpod v3、go_router、hive、http、flutter_markdown、file_picker、flutter_localizations 等。
  - 新增项目文档：README.md（完整的项目说明、架构介绍、使用指南）。

- 核心功能
  - 导航结构（Welcome/Drawer：Home/Assistant/MCP；Home 栈含 Chat/Topic/Settings 及子路由）。
  - 聊天：
    - LLM 流式输出（OpenAI chat/completions SSE），支持取消；生成完成后智能命名主题。
    - Markdown 渲染，长按消息：翻译/复制/重新生成/删除。
    - 附件：图片/文件选择与预览（块存储）。
    - 翻译块：中/英互译并在消息下方渲染。
  - 设置：
    - 供应商设置（Base URL/Model/API Key/Temperature）。
    - 通用设置（明暗模式、语言切换、中英、本地 JSON 备份/导入）。
    - 网页搜索设置（可配置 endpoint 模板）。
  - MCP：服务器管理页（增删与持久化，协议集成留待后续）。
  - i18n：基础中/英切换（Flutter 本地化管线）。

- UI/主题（✅ 像素级还原完成）
  - **主题 Token 系统**（✅ 完成）：
    - 完整移植 Tailwind 配置中的所有颜色定义到 `lib/theme/tokens.dart`
    - 包含所有颜色变体：purple、orange、blue、pink、red、gray、yellow、green（含明暗模式）
    - 特殊颜色：textDelete、textLink、borderColor、背景色系列、边框色等
    - 主题配置文件 `app_theme.dart` 包含完整的组件样式定义
  
  - **AppDrawer 侧边栏**（✅ 完成）：
    - 完全复刻原项目布局：菜单项分组、近期主题列表、底部用户信息
    - 精确间距：px-2.5、gap-1.5、gap-2.5 等完全对齐
    - 新组件：MenuTabContent、TopicItem（含头像、时间格式化、长按菜单）
    - 分割线位置和样式完全一致
  
  - **ChatHeader 聊天头部**（✅ 完成）：
    - 三栏布局：左侧菜单按钮 + 中间助手选择器 + 右侧新建主题按钮
    - 高度 44px（h-11），内边距 px-3.5
    - 中间区域：两行文本（助手名称 + 主题名称），可点击展开助手选择器
    - 底部边框分隔线
  
  - **MessageBubble 消息气泡**（✅ 完成）：
    - 用户消息：右对齐，绿色背景（green-10 + border green-20），左圆+右上圆+右下小圆
    - 助手消息：左对齐，透明背景，完全圆角（rounded-2xl）
    - 完整 Markdown 样式：代码块、引用块、表格、链接等
    - 代码块带背景色和边框，行高 1.6
  
  - **MessageInput 输入框**（✅ 完成）：
    - 外层容器：顶部圆角（16px），带向上阴影（offset 0, -4）
    - 三层结构：文件预览 + 文本输入 + 工具栏
    - 文本框：最小高度 96px，最大 200px，透明边框
    - 工具栏：左侧按钮组（附件、思考、提及、MCP）+ 右侧发送/暂停按钮
    - 发送/暂停按钮带动画切换（200ms scale + fade）
    - 底部安全区适配

## 待办与路线图（UI 像素级还原优先）

1) 像素级 UI 还原
   - ✅ 主题 Token 细化与字体对齐（完整移植 Tailwind 所有颜色与组件样式）
   - ✅ Drawer 完整样式与布局（菜单项分组、近期主题列表、底部用户信息）
   - ✅ Chat Header（三栏布局、助手选择器、新建主题按钮）
   - ✅ Message 气泡（用户/助手消息样式、Markdown 完整渲染、代码块样式）
   - ✅ MessageInput（工具栏、发送/暂停动画切换、文件预览、安全区适配）
   - ⏳ 设置子页结构与卡片样式（分组、标题、说明、开关/输入控件的一致风格）
   - ⏳ 助手列表与详情页 UI 完整复刻
   - ⏳ 主题列表页面样式优化

2) 功能与交互
   - 助手市场与详情 UI 完整复刻；模型列表与选择器；错误提示与网络状态。
   - Web 搜索、工具调用的更贴近原项目的统一入口与回显视图。
   - MCP 客户端协议对接与可视化交互。
   - 性能优化（大列表、图片内存、流式稳定性与重试、错误提示/回退）。
   - 可访问性（语义/对比度/可触区域）。

3) 工程化
   - App 图标/启动图与原项目一致（导入 `src/assets/images` 中的素材并生成 Android 图标）。
   - 发布签名/渠道包（后续接入 keystore 与 Play 规范，当前为 unsigned APK artifact）。

## UI 还原规范（必须遵守）

- 不得私自改动色值、圆角、阴影、间距、字体、字号、图标尺寸与样式；若 Flutter 平台限制导致差异，必须在备注中注明并给出最接近实现。
- 组件间距、列表项高度、按钮大小与布局需与原项目保持一致（以原项目样式为准）。
- 动画与转场（滑动、淡入出、BottomSheet 展开）尽量贴近原体验；若需自定义曲线与时长，优先匹配原项目配置。

## 技术架构概览

- 路由：`go_router`（匹配原项目栈/抽屉结构）。
- 状态：`flutter_riverpod` v3（Notifier/NotifierProvider）。
- 数据：Hive（topics/messages/blocks/prefs），剪贴板 JSON 备份/导入。
- LLM：OpenAI Chat Completions（流式 SSE，HTTP 请求），可通过“供应商设置”修改 base/model/key/温度。
- UI：Material3，自定义 Token 对齐原 Tailwind 配置；`flutter_markdown` 渲染。
- 附件：`file_picker` 选择，Base64 存储在块中；图片使用 `Image.memory` 预览。
- CI/CD：GitHub Actions（Android APK，每次 push 自动构建并上传 artifact）。

## 构建与使用

- GitHub Actions
  - 仅 Android Job：自动安装 Flutter/Android SDK → 创建工程（若缺失）→ 注入 `src_flutter/lib` → `flutter pub get` → `flutter build apk --release` → 上传 `app-release.apk`。
- 运行前配置
  - 在应用内“设置 → 供应商”填入 OpenAI API Key/模型/URL 才能使用聊天。
  - `/search <关键词>` 可触发 DuckDuckGo 摘要搜索（可在“网页搜索设置”替换 endpoint 模板）。

## 注意事项与要求（来自用户的强约束）

- “UI 是最重要的”，必须 1:1 还原原项目视觉与交互；包括每个组件的样子、颜色、图标、边距与高度。
- 不得向仓库提交任何密钥与敏感信息（API Key、token、keystore 等）。
- 仅构建 Android APK（已在 CI 中生效）；如需恢复 Web 构建，请单独明确提出。
- 对于因平台差异导致无法完全一致的细节，需要在合并说明/提交消息中记录差异与替代方案。

## 已知风险/限制

- 平台差异：React Native + Tailwind 到 Flutter 的视觉与排版可能存在细微差异，需要不断微调 Token 与组件样式以达像素级一致。
- 第三方接口：LLM / Web 搜索 无法保证可用性与速率，需处理网络错误与限流。
- 附件存储：当前以 Hive + Base64 为主，超大文件会增大占用；后续可考虑文件系统持久化与缩略图方案。

## 贡献与提交约定

- 分支：功能分支开发，合并主干前自测通过（运行 + 构建）。
- 提交信息：聚焦“为什么 + 行为变化”，标明 UI 差异或平台限制（如有）。
- CI：推送即触发 Android 构建，请避免无意义的频繁推送。

---

## 最新更新记录

### 2024-11-01 第三轮功能完善 + Bug修复

本次更新完成了所有核心功能并修复构建错误：

**🔧 Bug 修复（更新）**
- 修复构建错误：`CardTheme` -> `CardThemeData`
- 修复构建错误：`DialogTheme` -> `DialogThemeData`
- 修复 Assistant 模型缺少字段：添加 `emoji`, `description`, `tags`, `group`
- 严格对齐原项目的 Assistant 类型定义
- 所有代码通过编译测试

**1. 消息长按菜单** ✅
- 支持长按消息显示操作菜单
- 菜单项：复制、翻译、重新生成（仅助手消息）、删除
- BottomSheet 样式菜单
- 回调函数接口完整

**2. 图片预览和文件块** ✅
- `ImageBlock` 组件：Base64 图片显示
- 支持点击全屏预览（InteractiveViewer 缩放）
- `FileBlock` 组件：文件信息卡片
- 自动识别文件类型图标（PDF、DOC、XLS、ZIP 等）
- 文件大小自动格式化（B/KB/MB）
- 支持删除按钮

**3. 助手详情页面** ✅
- 完整的编辑界面：Emoji、名称、系统提示词
- Emoji 选择器：30+ 常用 Emoji，网格布局
- 卡片式布局，使用 `SettingsGroup` 组件
- 保存状态提示（加载中、成功、失败）
- 输入验证（名称不能为空）

**新增组件**
- `attachment_preview.dart`: `ImageBlock` + `FileBlock`

### 2024-11-01 第二轮 UI 优化完成

本次更新完成了设置、助手、主题列表页面的优化：

**1. 设置页面重构** (`SettingsGroup` 组件)
- 统一的卡片样式：圆角、阴影、分组
- `SettingsItem`: 设置项组件（图标、标题、副标题、箭头）
- `SettingsSectionTitle`: 分组标题
- `SettingsSwitchItem`: 带开关的设置项
- 完全对齐原项目布局和间距

**2. 助手列表页面** (`EmojiAvatar` 组件)
- 网格布局（2列），卡片展示
- `EmojiAvatar`: Emoji 头像组件（可配置大小、圆角、边框）
- 助手卡片：头像、名称、描述、标签
- 空状态提示和错误处理

**3. 主题列表页面**
- 搜索功能：实时过滤主题
- 时间分组：今天、昨天、本周、上周、上月、更早
- 使用 `TopicItem` 组件展示
- 删除确认对话框

**4. 新增组件**
- `SettingsGroup`: 设置分组容器
- `SettingsItem`: 设置项
- `SettingsSectionTitle`: 分组标题
- `EmojiAvatar`: Emoji 头像
  
### 2024-11-01 第一轮 UI 像素级还原完成

**1. 主题系统完善**
- 补全所有 Tailwind 颜色定义（88 个颜色 Token）
- 完整的明暗模式支持
- 统一的组件样式配置（按钮、卡片、输入框、对话框等）

**2. 核心组件重构**
- `AppDrawer`: 完全复刻侧边栏布局，包括菜单项、主题列表、用户信息
- `ChatHeader`: 三栏布局，助手选择器，精确间距
- `MessageBubble`: 用户/助手消息气泡，完整 Markdown 样式
- `MessageInput`: 工具栏、发送/暂停动画、文件预览

**3. 新增组件**
- `MenuTabContent`: 菜单标签内容组件
- `TopicItem`: 主题列表项（含头像、时间、长按菜单）

**4. 项目文档**
- 新增 `README.md`: 完整的项目说明、技术架构、使用指南
- 更新 `AGENTS.md`: 详细记录开发进度和规范

**待完成工作**：
- ✅ 消息长按菜单（翻译、复制、重新生成、删除）
- ✅ 图片预览和文件块显示
- ✅ 助手详情页面 UI
- ⏳ App 图标与启动图
- ⏳ MCP 服务器集成
- ⏳ 更多动画效果优化

---

如需继续开发，优先级建议：
1) 完成设置页面的卡片样式与布局统一
2) 助手市场/详情页面 UI 复刻
3) 主题列表页面的分组与时间显示优化
4) 导入正式图标与启动图
