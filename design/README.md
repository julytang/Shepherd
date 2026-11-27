# Shepherd 设计稿

UI 与交互的原型和设计稿，依据 `docs/` 中的方案计划书（重点是 `docs/03-product-and-ux.md`）制作。

- **在线画布**：https://claude.ai/artifact/KnjeFEpaynZSXeS2v7c2Yq（默认私有，需要在页面的 Share 菜单里共享后，其他人才能打开）
- **本目录**：画布文件的同步副本。`project/canvas.json` 是索引，每个 `*.dc.html` 是一张画板。

## 设计依据

- **设计系统**：Notion Analysis。颜色、字体（Inter）、间距、圆角、阴影都用它的 token，安装记录在 `canvas.json` 的 `designSystems` 中，画布上的 token 副本在 `project/ds/notionanalysis/`。
- **材质与规范**：Apple HIG 与 Liquid Glass。玻璃只用于导航层（侧栏、工具栏、输入框、弹层、Sheet、Tab 栏），内容层保持纸面和 surface 白。
- **深色外观**：设计系统没有深色主题。深色值是按同一套暖灰推导的提议值，见「设计规范」页的颜色表；确认后应回写到设计系统。
- **iPhone Duo**：依据 Apple HIG「Designing for iPhone Duo」（https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo ），代码侧参考 Xcode 的 app-resizability skill，并在 iPhone Duo 模拟器（iOS 27.2）上核对。外屏和内屏横向时，工具栏、标签栏、导航按钮都移到摄像头一侧的竖条里；分屏时两个 App 各自把控件放在外侧。规范原文用 Xcode 的文档搜索（DocumentationSearch）查。

## 画板

| 页面 | 画板 | 说明 |
| :--- | :--- | :--- |
| Mac | `Main.dc.html` | 主窗口可交互原型：会话切换、审批 / 拒绝附原因、问题作答、权限档位、Diff Inspector、新建 Worktree；Tweaks 可切换深色、降低透明度、增强对比度 |
| Mac | `MacTrustGate.dc.html` | 仓库信任门 + setup 脚本 SHA-256 信任 |
| Mac | `MacCreatePR.dc.html` | 提交并创建 PR |
| Mac | `MacArchive.dc.html` | 归档并清理 Worktree（脏文件提醒） |
| Mac | `MacMenuBar.dc.html` | 菜单栏 Popover 与系统通知 |
| Mac | `MainDark.dc.html` | 主窗口深色 |
| Mac | `MacSettings.dc.html` | 设置 › 设备可交互原型：已绑定设备与解绑、绑定新设备 Sheet（二维码 → 核对验证码 → 完成）、中继选择、这台 Mac 的密钥指纹 |
| Mac | `MacPairingQR.dc.html` / `MacPairingVerify.dc.html` | 绑定 Sheet 的两个步骤：二维码、核对 6 位验证码 |
| Mac | `MacPairingExpired.dc.html` / `MacPairingRejected.dc.html` / `MacPairingRelayDown.dc.html` | 绑定异常：二维码过期、选了「不是这台设备」、连不上中继 |
| iPad | `iPadWorkspace.dc.html` / `iPadWorkspaceDark.dc.html` | 三栏工作区可交互原型（浅色 / 深色） |
| iPad | `iPadReview.dc.html` | 竖屏审查 Diff 与创建 PR（深色） |
| iPad | `iPadPairing.dc.html` | 未绑定首页 |
| iPhone | `iPhoneFlow.dc.html` / `iPhoneFlowDark.dc.html` | 等你处理 → 审批 → Diff 可交互原型（浅色 / 深色） |
| iPhone | `iPhoneNewTask.dc.html` | 新建任务 Sheet（深色） |
| iPhone | `iPhoneLockScreen.dc.html` | 锁屏通知与实时活动 |
| iPhone | `iPhonePairing.dc.html` | 绑定 Mac 可交互原型：未绑定 → 扫码 → 核对验证码 → 已连接；Tweaks 可切换步骤 |
| iPhone | `iPhonePairingScan.dc.html` / `iPhonePairingVerify.dc.html` / `iPhonePairingSettings.dc.html` | 扫描二维码、核对验证码、设置 › 已连接的 Mac（含解绑和通知开关） |
| iPhone | `iPhonePairingDenied.dc.html` / `iPhonePairingExpired.dc.html` / `iPhonePairingRelayDown.dc.html` / `iPhonePairingRejected.dc.html` / `iPhonePairingRevoked.dc.html` | 绑定异常：相机权限被拒、扫到过期的二维码、连不上中继、Mac 没有确认、已被 Mac 解绑。iPad 与 iPhone Duo 用同一套状态 |
| iPhone Duo | `DuoOuter.dc.html` | 外屏（合上） |
| iPhone Duo | `DuoInner.dc.html` | 内屏（展开，深色） |
| iPhone Duo | `DuoHalfOpen.dc.html` | 半开书本姿态：左对话、右 Diff |
| iPhone Duo | `DuoSplit.dc.html` | 内屏分屏，变窄后回到单栏，控件在各自外侧 |
| iPhone Duo | `DuoPairing.dc.html` | 外屏未绑定：竖条里只有摄像头和状态栏 |
| 设计规范 | `Foundations.dc.html` | 两层结构、颜色与深色、五种状态、字体、玻璃材质、核心组件、四端适配 |

## 待补

- **绑定后的连接状态没有画**：Mac 睡眠或离线、中继中断后自动重连时，手机上怎么显示，还没有单独画。邀请令牌的时限和尝试次数上限未定（`docs/02-architecture.md` §3.5.7）。
- **设计系统没有红色与深色主题**：「出错」暂用 accent-pink，深色值为提议值。
- **系统版本**：最低 macOS 27、iOS / iPadOS 27，直接使用 Liquid Glass，没有回退样式。
