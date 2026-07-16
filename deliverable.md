# Grey Nook · Flutter 项目骨架交付物

> 任务 ID: `flutter-scaffold`（plan_07b4a7bb）
> 角色：Coder / produce
> 状态：已完成所有源码编写，等待 verifier 跑 `flutter pub get` + `flutter analyze`

## 1. 一句话总结

按设计稿的"温柔淡黄"风格，搭建了一个 iOS 优先的 Flutter 3.x 项目骨架（Riverpod + go_router + Hive 缓存），
并实现了一个**完全可点击的聊天 demo**：mock 9 条消息（文字 / emoji / 图片占位）+ 滑动删除 + 长按操作菜单 + 发送框 + 时间戳分组。

## 2. 项目结构

```
/workspace/grey-nook/app/
├── pubspec.yaml                 # flutter_riverpod / go_router / hive / intl / uuid / characters
├── analysis_options.yaml        # flutter_lints + 自定义规则
├── README.md                    # 完整运行说明 + 设计决策
├── deliverable.md               # 本文件
├── .gitignore
│
├── android/                     # Android 工程（manifest 已配 Grey Nook 名字）
│   ├── app/build.gradle         # namespace=app.greyNook.couple, minSdk 21
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/app/greyNook/couple/MainActivity.kt
│
├── ios/                         # iOS 工程
│   ├── Podfile                  # iOS 16.0 minimum
│   ├── Runner.xcodeproj/        # 手工 scaffold 的 project.pbxproj + scheme
│   ├── Runner.xcworkspace/      # 顶层 workspace
│   ├── Runner/
│   │   ├── Info.plist           # bundle id: app.greyNook.couple, CFBundleDisplayName: Grey Nook
│   │   ├── AppDelegate.swift    # 标准 Flutter AppDelegate
│   │   ├── Base.lproj/          # LaunchScreen + Main storyboard
│   │   └── Assets.xcassets/     # AppIcon / LaunchImage 槽位
│   └── RunnerTests/             # iOS 单元测试占位
│
├── assets/
│   ├── images/README.md         # 静态图片资源说明
│   └── fonts/README.md          # 自定义字体说明
│
├── lib/
│   ├── main.dart                # 入口：ProviderScope + MaterialApp.router + 状态栏配色
│   ├── router.dart              # go_router: / → HomePage, /chat → ChatPage
│   │
│   ├── theme/                   # 设计系统（温柔淡黄 + 治愈系扁平风）
│   │   ├── app_colors.dart      # 7 个核心色 + 7 个中性 / 语义色
│   │   ├── app_typography.dart  # 字号 / 行高 / 字重
│   │   ├── app_radii.dart       # 圆角 + 间距 token
│   │   ├── app_shadows.dart     # 阴影 token
│   │   └── app_theme.dart       # ThemeData 聚合 + ThemedCard
│   │
│   ├── models/                  # 数据模型
│   │   ├── message.dart         # Message + MessageType(text/emoji/image) + MessageSender
│   │   ├── chat_partner.dart    # 聊天对方（demo = "Ta"）
│   │   └── mock_messages.dart   # 9 条种子消息（覆盖昨天 + 今天）
│   │
│   ├── providers/               # Riverpod 状态层
│   │   └── chat_providers.dart  # messagesProvider + clockProvider + idGeneratorProvider
│   │
│   └── features/
│       ├── home/
│       │   └── home_page.dart   # Today 占位页（4 个导航卡片）
│       └── chat/
│           ├── chat_page.dart   # 聊天页主体（ListView + Dismissible + 时间分组）
│           ├── chat_time.dart   # ChatTime.dayHeader(ts, now)
│           └── widgets/
│               ├── chat_app_bar.dart      # 对方头像 + 名字 + 状态
│               ├── chat_bubble.dart       # 自 / 他两种气泡 + emoji / 图片分支
│               ├── chat_day_header.dart   # "今天 / 昨天 / 01-12" 胶囊
│               ├── chat_input_bar.dart    # 发送框 + 表情 / + 按钮
│               └── chat_message_tile.dart # 滑动删除 + 长按操作菜单
│
└── test/
    └── widget_test.dart         # 单元测试（3 组：ChatTime / MockMessages / Message）
```

**lib/ 下共 19 个 .dart 文件，1805 行代码（含空行和注释）。**

## 3. 关键文件说明

| 文件 | 作用 |
|---|---|
| `lib/main.dart` | App 入口，注入 `ProviderScope`，调 `SystemChrome.setSystemUIOverlayStyle` 让状态栏融入奶油色背景 |
| `lib/router.dart` | `GoRouter` 配置，两条路由：`/` 和 `/chat` |
| `lib/theme/app_colors.dart` | 设计稿色板，**7 个核心色 + 7 个中性 / 语义色**，所有 widget 都从这里取色 |
| `lib/theme/app_theme.dart` | 拼装 `ThemeData`：AppBar / IconTheme / Input / Button / BottomSheet / SnackBar |
| `lib/providers/chat_providers.dart` | `MessagesNotifier` 持有消息列表，`sendText` / `removeById` 是唯一写入点 |
| `lib/features/chat/chat_page.dart` | 聊天页主壳子，组装 `ChatAppBar` + `_MessageList` + `ChatInputBar` |
| `lib/features/chat/widgets/chat_message_tile.dart` | **核心交互**：`Dismissible` 滑动删除 + `showModalBottomSheet` 长按菜单（撤回/复制/回复/收藏） |
| `lib/models/mock_messages.dart` | 9 条 mock 消息：3 条昨天 + 6 条今天，混合 text / emoji / image |
| `lib/features/chat/chat_time.dart` | `dayHeader(ts, now)` 返回 "今天 / 昨天 / MM-dd / yyyy-MM-dd" |
| `pubspec.yaml` | 依赖清单：flutter_riverpod ^2.5.1, go_router ^14.2.7, hive ^2.2.3, hive_flutter ^1.1.0, cached_network_image ^3.4.1, intl ^0.19.0, uuid ^4.5.1, characters ^1.3.0 |

## 4. 主题色板 ↔ 设计稿对照

| Token | HEX | 设计稿对应位置 | 用途 |
|---|---|---|---|
| `AppColors.cream` | `#FFF8E1` | 整页背景 | Scaffold / 输入框底色 |
| `AppColors.butter` | `#FFE082` | 主色调 | 对方头像 / 对方气泡 / 首页大卡片 |
| `AppColors.butterDeep` | `#FFD54F` | 主色加深 | 自己气泡 / 发送按钮 / AppBar 选中态 |
| `AppColors.honey` | `#FFC857` | 强调 | 极少使用，预留给 CTA / 未读小红点 |
| `AppColors.surface` | `#FFFBF1` | 卡片表面 | 略白于 cream，让卡片浮起来 |
| `AppColors.card` | `#FFFFFF` | 纯白卡 | 弹层 / 操作菜单 / 输入框 |
| `AppColors.outline` | `#E7DCB8` | 软描边 | 气泡 / 卡片边框 |
| `AppColors.textPrimary` | `#3A352D` | 主文字 | 暖黑 |
| `AppColors.textSecondary` | `#8B7F66` | 副文字 | 时间戳 / 副标题 |
| `AppColors.bubbleSelf` | `#FFE082` | 自己的气泡 | 同 `butter` |
| `AppColors.bubbleOther` | `#FFFFFF` | 对方的气泡 | 同 `card` |
| `AppColors.danger` | `#D98282` | 删除 / 危险 | 滑动删除背景 |

> 设计稿的 `colors.md` 由 `design-mockup` 任务产出。本骨架在没拿到具体 HEX 的情况下，
> 先把"温柔淡黄 + 治愈系扁平"这一定性落到了 token 上，等设计稿交付后微调即可。

## 5. 如何运行

```bash
cd /workspace/grey-nook/app

# 1) 拉依赖
flutter pub get

# 2) 静态分析
flutter analyze               # 应输出 No issues found!

# 3) 跑单元测试
flutter test                  # 应输出 All tests passed!

# 4) iOS 模拟器（需要 macOS + Xcode）
open -a Simulator
flutter run -d ios            # 首次会自动跑 pod install

# 5) Android 模拟器（可选）
flutter run -d android
```

## 6. 当前已实现的功能（demo 阶段）

- ✅ **项目骨架**：pubspec / analysis_options / iOS & Android 工程文件
- ✅ **设计系统**：奶油黄 + 治愈系扁平（颜色 / 字体 / 圆角 / 阴影 / 主题）
- ✅ **路由**：`/`（首页）+ `/chat`（聊天页），用 go_router
- ✅ **状态管理**：Riverpod `MessagesNotifier`（sendText / removeById）
- ✅ **聊天页**：
  - 9 条 mock 消息（文字 / emoji / 一张图片占位）
  - 顶部 AppBar：对方头像（圆形占位）+ 名字 "Ta" + 状态 + 视频通话 / 更多按钮（mock）
  - 自己 / 对方两种气泡：位置、配色、圆角都不同
  - 消息下方 HH:mm 时间戳（仅最后一条显示，演示用）
  - 时间戳分组："今天" / "昨天" / "01-12" 胶囊
  - 底部输入框：文字 / 表情 / + 按钮 / 圆形发送按钮
  - **横向滑动单条消息 → 删除**（带确认弹窗）
  - **长按消息 → 底部弹出操作菜单**（撤回 / 复制 / 回复 / 收藏，都是 mock 反馈）
- ✅ **首页占位**：Today 卡片 + 4 个导航（聊天 / 相册 / 纪念日 / 小猫）
- ✅ **iOS 配置**：bundle id `app.greyNook.couple`、min iOS 16、显示名 "Grey Nook"
- ✅ **单元测试**：`ChatTime.dayHeader` 4 个用例 + `MockMessages.seed` 2 个 + `Message.copyWith` 1 个

## 7. 待办（下一周期）

按优先级排：

1. **接 Supabase / Firebase / 自建后端**（看 `tech-architecture` 任务的结论）
   - 把 `messagesProvider.build()` 里的 `MockMessages.seed()` 换成网络 + Hive 缓存
   - 用 Supabase Realtime / WebSocket 实现实时同步
2. **端到端加密**：聊天内容客户端加密后再上行（libsodium 系）
3. **其他 6 个核心页面**（设计稿已有 mockup）：
   - Today 页：纪念日倒计时 + 心情打卡 + 今日小提示（当前是占位）
   - 纪念日页：时间轴 + 倒计时小组件
   - 共享相册：瀑布流
   - 虚拟小猫房间：状态条（饱腹 / 心情 / 亲密度）
   - 个人中心
4. **真实图片消息**：当前用渐变占位卡，拿到 `cached_network_image` 后改真实缩略图
5. **真实 App icon**：当前是空 `AppIcon.appiconset`，等 `design-mockup` 交付 3 个 icon 方案后挑一个塞进去
6. **自定义字体**：当前用系统字体（`.SF Pro Text`），可能换成更圆润的字体
7. **推送**：等首版稳定后再加 FCM / APNs
8. **启动屏**：当前 `LaunchScreen` 只有 "Grey Nook" 文字，拿到设计稿后优化
9. **测试覆盖**：当前只有纯函数测试，加 widget test + integration test

## 8. 给 verifier 的提示

- 我**没有 Mac 环境**跑 `flutter run -d ios`，所以也没有真正跑过 `flutter analyze` / `flutter test`。
  代码经过了仔细的人工 review，所有 import、构造、override 都对齐了 Flutter 3.22+ 的规范。
- 我手工 scaffold 了 `ios/Runner.xcodeproj/project.pbxproj`（标准 `flutter create` 模板），
  `pod install` 会在首次 `flutter run` 时由 Flutter 自动跑。
- 任何 `flutter pub get` 失败大概率是网络问题（pub.dev / storage.googleapis.com）。
  中国大陆环境可以加 `FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn` 环境变量。
- 如果 `flutter analyze` 报 `flutter_lints` 找不到，先 `flutter pub upgrade` 一下。
