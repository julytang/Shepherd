# Shepherd

iOS 与 macOS 客户端的原生 SwiftUI monorepo。最低支持 iOS 17、macOS 14，本地共享包使用 Swift 6。

```text
Shepherd/
├── Shepherd.xcworkspace       # Xcode 统一入口
├── Apps/
│   ├── iOS/                  # Xcode 向导创建的 Shepherd.xcodeproj 与 Shepherd 源码
│   └── macOS/                # Xcode 向导创建的 Shepherd.xcodeproj 与 Shepherd 源码
├── Packages/
│   └── ShepherdKit/          # 两端共用的本地 Swift Package
├── Design/                   # 设计原稿、原型与导出资源
└── script/
    └── build_and_run.sh      # macOS 本地构建与运行
```

## 在 Xcode 中打开

打开 `Shepherd.xcworkspace`，选择 `Shepherd-iOS` 或 `Shepherd-macOS` scheme，
再选择模拟器或 My Mac 运行。共享包已通过相对路径关联，无需手动添加依赖、
安装第三方工程生成器或执行依赖安装命令。`.xcodeproj`、共享 scheme 和 workspace 都应提交。

两端的 Project、Target 和 Product Name 都是 `Shepherd`，共享 Scheme 分别命名为
`Shepherd-iOS` 和 `Shepherd-macOS`。两个工程均由本机 Xcode 27 的 App 创建向导生成，
保留原生工程结构、Assets 目录及文件系统同步分组；仅补充本地共享包依赖与共享 Scheme。
最低版本沿用 iOS 17 / macOS 14。

Bundle ID 分别为 `com.julytang.ios.Shepherd` 和 `com.julytang.macos.Shepherd`。
向导保留了当前 Xcode 所选的 Team。真机运行、归档和分发前，请在对应 target 的
Signing & Capabilities 核对 Team 和 Bundle ID。当前未配置分发证书、推送能力或 App 图标内容。

## 代码边界

- `Apps` 保留各平台入口、导航、窗口生命周期、权限和平台专属界面。
- `ShepherdKit` 放实际共用的模型、业务逻辑、服务和 SwiftUI 组件。
  当前只有一个共享欢迎组件，用来验证两个 App 都能链接并使用共享库。
- App 依赖共享包，共享包不依赖任何 App。先维护一个包，有真实需求再拆模块。
- `Design` 只存设计输入，不参与 App 编译；资源落地方式见目录内 README。

两个 App 使用 Xcode 原生的文件系统同步分组，`Apps/iOS/Shepherd` 和
`Apps/macOS/Shepherd` 下新增的源码会自动纳入相应 target。
共享包中 `Sources/ShepherdKit` 下新增的 Swift 文件由 SwiftPM 自动识别。

## 命令行

如果 `xcode-select -p` 指向 Command Line Tools，先在当前终端执行：

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```

```sh
# 列出 workspace 的 scheme
xcodebuild -list -workspace Shepherd.xcworkspace

# 单独构建共享库
swift build --package-path Packages/ShepherdKit

# 构建 iOS 模拟器版本
xcodebuild -workspace Shepherd.xcworkspace -scheme Shepherd-iOS \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build

# 构建并运行 macOS 客户端（本地临时签名）
./script/build_and_run.sh
```

macOS 脚本也支持 `--verify` 检查进程、`--debug` 进入 LLDB、`--logs` 和
`--telemetry` 查看应用日志。Codex 的 Run 操作调用同一脚本。

构建输出和个人 Xcode 设置已被 Git 忽略。当前骨架未添加业务测试，
后续添加业务逻辑时将相应测试放入共享包的 `Tests`，平台行为测试放入各 App 工程。
