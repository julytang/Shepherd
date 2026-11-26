# Shepherd 设计稿

UI 与交互的原型和设计稿，依据 `docs/` 中的方案计划书（重点是 `docs/03-product-and-ux.md`）制作。

- **在线画布**：https://claude.ai/artifact/KnjeFEpaynZSXeS2v7c2Yq（默认私有，需要在页面的 Share 菜单里共享后，其他人才能打开）
- **本目录**：画布文件的同步副本。`project/canvas.json` 是索引，每个 `*.dc.html` 是一张画板。

## 设计依据

- **设计系统**：Notion Analysis。颜色、字体（Inter）、间距、圆角、阴影都用它的 token，安装记录在 `canvas.json` 的 `designSystems` 中，画布上的 token 副本在 `project/ds/notionanalysis/`。
- **材质与规范**：Apple HIG 与 Liquid Glass。玻璃只用于导航层（侧栏、工具栏、输入框、弹层、Sheet、Tab 栏），内容层保持纸面和 surface 白。
- **深色外观**：设计系统没有深色主题。深色值是按同一套暖灰推导的提议值，见「设计规范」页的颜色表；确认后应回写到设计系统。
- **iPhone Duo**：依据 Apple HIG「Designing for iPhone Duo」（https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo ），代码侧参考 Xcode 的 app-resizability skill，并在 iPhone Duo 模拟器（iOS 27.2）上核对。外屏和内屏横向时，工具栏、标签栏、导航按钮都移到摄像头一侧的竖条里；分屏时两个 App 各自把控件放在外侧。要点整理在用户级 skill `iphone-duo-design` 里。

## 画板

| 页面 | 画板 | 说明 |
| :--- | :--- | :--- |
| Mac | `Main.dc.html` | 主窗口可交互原型：会话切换、审批 / 拒绝附原因、问题作答、权限档位、Diff Inspector、新建 Worktree；Tweaks 可切换深色、降低透明度、增强对比度 |
| Mac | `MacTrustGate.dc.html` | 仓库信任门 + setup 脚本 SHA-256 信任 |
| Mac | `MacCreatePR.dc.html` | 提交并创建 PR |
| Mac | `MacArchive.dc.html` | 归档并清理 Worktree（脏文件提醒） |
| Mac | `MacMenuBar.dc.html` | 菜单栏 Popover 与系统通知 |
| Mac | `MainDark.dc.html` | 主窗口深色 |
| iPad | `iPadWorkspace.dc.html` / `iPadWorkspaceDark.dc.html` | 三栏工作区可交互原型（浅色 / 深色） |
| iPad | `iPadReview.dc.html` | 竖屏审查 Diff 与创建 PR（深色） |
| iPhone | `iPhoneFlow.dc.html` / `iPhoneFlowDark.dc.html` | 等你处理 → 审批 → Diff 可交互原型（浅色 / 深色） |
| iPhone | `iPhoneNewTask.dc.html` | 新建任务 Sheet（深色） |
| iPhone | `iPhoneLockScreen.dc.html` | 锁屏通知与实时活动 |
| iPhone Duo | `DuoOuter.dc.html` | 外屏（合上） |
| iPhone Duo | `DuoInner.dc.html` | 内屏（展开，深色） |
| iPhone Duo | `DuoHalfOpen.dc.html` | 半开书本姿态：左对话、右 Diff |
| iPhone Duo | `DuoSplit.dc.html` | 内屏分屏，变窄后回到单栏，控件在各自外侧 |
| 设计规范 | `Foundations.dc.html` | 两层结构、颜色与深色、五种状态、字体、玻璃材质、核心组件、四端适配 |

## 待拍板

- `docs/03` 把 Mobile Companion 与 E2E Relay 列为 Cut。iPad、iPhone、iPhone Duo 这几组稿按「连到 Mac 的 Companion」设计（Agent 仍在 Mac 本机执行），是否把它改回范围、用什么方式连接，需要决定。
- 设计系统没有红色与深色主题：「出错」暂用 accent-pink，深色值为提议值。
