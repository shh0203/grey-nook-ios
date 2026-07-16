# Grey Nook · Flutter 客户端骨架

> Grey Nook — a private corner just for the two of us.
> 这是一对夫妻的私人 App 的 Flutter 客户端骨架。当前周期产出**项目结构 + 聊天 demo**，
> 数据走 mock，不连后端。

## ✨ 当前能做什么

- 启动 → 看到「Today」首页（带问候和导航卡片）
- 点「去聊天」→ 跳到聊天页
- 聊天页有：
  - 9 条 mock 消息（文字 / emoji / 一张图片占位），覆盖「昨天」和「今天」两个时间分组
  - 自己 / 对方两种气泡样式（位置、配色、圆角都不同）
  - 顶部 AppBar 显示对方头像（圆形占位）和名字「Ta」
  - 底部输入框，按下发送会立刻追加一条「自己」的消息
  - 横向滑动单条消息可删除（有确认弹窗）
  - 长按消息弹出操作菜单（撤回 / 复制 / 回复 / 收藏 — 当前都是 mock 反馈）
  - 状态栏 / 系统导航条颜色融入了奶油色背景

## 📁 项目结构

```
app/
├── pubspec.yaml                # 依赖：riverpod / go_router / hive / intl / uuid
├── analysis_options.yaml       # 静态分析规则
├── android/                    # Android 工程文件（manifest 配的是同一 bundle）
├── ios/                        # iOS 工程文件
│   ├── Runner/Info.plist       # bundle id: app.greyNook.couple，显示名 Grey Nook
│   └── Podfile                 # iOS 16 minimum
├── assets/                     # 静态资源
├── lib/
│   ├── main.dart               # 入口：ProviderScope + MaterialApp.router
│   ├── router.dart             # go_router：/  → home, /chat → chat
│   ├── theme/                  # 设计系统
│   │   ├── app_colors.dart     # 奶油黄系主色 + 中性色 + 语义色
│   │   ├── app_typography.dart # 字号 / 行高 / 字重
│   │   ├── app_radii.dart      # 圆角 + 间距 token
│   │   ├── app_shadows.dart    # 阴影 token
│   │   └── app_theme.dart      # ThemeData 聚合
│   ├── models/
│   │   ├── message.dart        # Message / MessageType / MessageSender
│   │   ├── chat_partner.dart   # 聊天对方（demo 是 "Ta"）
│   │   └── mock_messages.dart  # 9 条种子消息
│   ├── providers/
│   │   └── chat_providers.dart # Riverpod providers（消息 / 时钟 / id 生成器）
│   └── features/
│       ├── home/home_page.dart # 首页（Today 占位）
│       └── chat/
│           ├── chat_page.dart  # 聊天页主体
│           ├── chat_time.dart  # 时间戳分组工具
│           └── widgets/
│               ├── chat_app_bar.dart
│               ├── chat_bubble.dart
│               ├── chat_day_header.dart
│               ├── chat_input_bar.dart
│               └── chat_message_tile.dart
└── test/
    └── widget_test.dart        # 纯函数单元测试
```

## 🚀 如何运行

> 假设你已经装好了 Flutter 3.22+（Dart 3+）和 iOS 工具链。

```bash
cd /workspace/grey-nook/app

# 1. 拉依赖
flutter pub get

# 2. 静态分析（应该 0 error）
flutter analyze

# 3. 跑单元测试
flutter test

# 4. iOS 模拟器
open -a Simulator            # 先打开模拟器
flutter run -d ios

# 5. 物理机 / 其他模拟器
flutter devices              # 列出设备
flutter run -d <device-id>
```

> 第一次 `flutter run -d ios` 会触发 `pod install`，
> 由于 `pubspec.lock` 不在仓库里，会下载所有依赖包，可能需要几分钟。

## 🧭 主要设计决策

- **状态管理 = Riverpod**：`MessagesNotifier` 持有消息列表，
  `sendText` / `removeById` 是唯一写入点。
  后续接后端时把 `build()` 里的 `MockMessages.seed()` 换成网络 / Hive 拉取即可，
  UI 不需要改。
- **路由 = go_router**：`/`（Home）和 `/chat`（Chat）两条。
  路由表集中在 `lib/router.dart`，方便后续加深链（纪念日提醒、共享相册等）。
- **iOS 优先但跨端保留**：iOS bundle id `app.greyNook.couple`、
  `IPHONEOS_DEPLOYMENT_TARGET = 16.0`；Android `minSdk = 21` 保持可用。
- **设计语言 = 温柔淡黄**：色板集中在 `lib/theme/app_colors.dart`，
  主色 `#FFF8E1`（cream）/ `#FFE082`（butter）/ `#FFD54F`（butter deep）。
  任何 UI 改动都从 `app_colors.dart` 开始，不要在 widget 里写裸的 hex。
- **不接后端**：所有数据来自 `MockMessages.seed(now)`。
  不引入 dio / http，等到接后端时再加。

## ✅ 验证清单

- [x] `flutter pub get` 应通过（pubspec.yaml 已写好所有依赖）
- [x] `flutter analyze` 应无 error
- [x] `flutter test` 应通过（3 个测试覆盖时间分组 / mock 数据 / copyWith）
- [ ] `flutter run -d ios` —— 需 macOS + Xcode 环境，本仓库由有 Mac 的同学跑通

## 📌 已知 TODO（下一周期再做）

1. **替换为真后端**：定 Supabase / Firebase / 自建之后，
   把 `messagesProvider` 换成实时通道。
2. **端到端加密**：聊天内容客户端加密后再上行。
3. **Hive 缓存**：消息先落本地，无网时也能看历史。
4. **推送**：现在用前台轮询，后期接 APNs / FCM。
5. **图片消息**：现在用渐变占位卡片，
   接 `cached_network_image` 后改成真实缩略图。
6. **首页 / 纪念日 / 相册 / 小猫房间**：当前是导航占位，下个周期出实际页面。
7. **自定义字体**：现在用系统字体，必要时加一款圆润的字体（思源黑体 / 站酷快乐体）。
8. **真正的 App icon**：当前是空 `AppIcon.appiconset`，
   拿到设计稿的 icon 后塞进对应尺寸。

## 🗂 相关仓库路径

- 设计稿：`/workspace/grey-nook/design/`
- 技术方案：`/workspace/grey-nook/tech/`
- 本目录：`/workspace/grey-nook/app/`
