# Shepherd

**专属于 macOS 开发者的极简、原生、跨厂商多 AI 编程代理指挥台（Agent Command Center）。**

> **目标平台与协议**：macOS 27.0+ · **仅 Apple Silicon (`arm64`)**（不支持 Intel Mac）· **MIT License** · Companion（v5）：iOS / iPadOS 27.0+

Shepherd 汲取开源 [`stablyai/orca`](https://github.com/stablyai/orca) 的多 Agent 协议实践与 Git Worktree 隔离理念，彻底剥离 Electron 臃肿与重型外围功能，以 **100% 纯 Swift 6（SwiftUI + AppKit）** 原生重构，聚焦多 Agent 并发开发的 80% 核心闭环：

> **Git Worktree 隔离并发 × Native Chat 结构化主交互 × 原生 Diff/PR 审查 × 外部主力 IDE 无缝接力**

---

## 核心设计理念

- **做减法而非全家桶**：只做好“派活 → 监控审批 → 审 Diff → 提 PR → 清 Worktree”主链路。绝不内置低配代码编辑器，深度修改一键 `⌘O` 交给你的主力 IDE（Cursor / Zed / VS Code / Xcode）。
- **真 macOS 原生轻快体感**：基于 Swift 6 严格并发、SwiftUI + AppKit 虚拟化 Diff 渲染、`MenuBarExtra` 状态徽章与 `UNUserNotificationCenter` 降噪通知，告别 Electron 与 Node Sidecar 的内存和包体负担。
- **跨厂商 BYOA（Bring Your Own Agent）**：打破第一方桌面端锁定，在同一指挥台下自由混排 **Claude Code**、**Codex** 与 **ACP 协议长尾 Agent**，直接复用本机已登录 CLI，**零闭源商业 SDK 捆绑**。
- **Agent 接入可独立维护（provider 分层）**：每个 Agent 的接入是一个 provider。内置 provider（Codex、Claude 直连、ACP 客户端）是各自独立的 Swift 包，核心只依赖一份契约；外部 provider 是用户手动添加的 ACP Agent，Shepherd 不捆绑、不代为安装。
- **默认零注入、零污染、安全可控**：MVP 默认不向 `~/.claude`、`~/.codex` 或项目仓库写入任何私有 Skill；兼容 `orca.yaml` / `shepherd.yaml` 的同时强制执行 **`git check-ignore` 软链校验**、**脚本入口 SHA-256 信任确认**与**进程组孤儿清场加后代进程跟踪**。
- **只做 Native Chat，不内嵌终端**：对话只有结构化 Native Chat 一种形态；Claude 的备用路径是另一个 provider，不经过终端。需要 shell 时 `⌘⇧T` 跳到你自己的系统终端。

---

## 核心目标指标（macOS 27.0+ · 仅 Apple Silicon `arm64`）

> 以下均为设计目标，尚未实测；M0 起逐项用实测替换。

| 指标 | 验收目标（纯 Swift 6 原生） |
| :--- | :--- |
| **冷启动可交互时间（TTI）** | ≤ 400 ms |
| **空闲常驻内存** | ≤ 80 MB（目标 45–75 MB） |
| **5 并发活跃 Worktree 内存**（不含本机 Agent CLI） | ≤ 220 MB · 稳定 60/120fps |
| **50 文件 / 2,000 行 Diff 首帧渲染** | ≤ 150 ms |
| **签名公证 `.dmg` 安装包体积** | ≤ 25 MB（目标 12–22 MB） |
| **审批通知端到端延迟** | ≤ 300 ms |

---

## 方案计划书导航

> **建议阅读入口**：先看 **[方案计划书总纲 (`docs/PROPOSAL.md`)](./docs/PROPOSAL.md)**，一篇掌握全部核心决策、硬数据、里程碑与 M0 待裁决项；再按需深入四份专题文档。

| 文档 | 内容摘要 | 适合读者 |
| :--- | :--- | :--- |
| **[`docs/PROPOSAL.md`](./docs/PROPOSAL.md)** | **方案计划书总纲**：Executive Summary、竞品与裁剪总览、路线 C1 锁定依据、产品安全取舍、M0–M4 路线图、合规清单、已拍板立项决策与 M0 待裁决项、v2 / v3 修订记录（§8） | 决策者 / 全体研发 |
| **[`docs/01-orca-audit.md`](./docs/01-orca-audit.md)** | **上游代码审计报告**：`stablyai/orca`（v1.4.214 / ~370 万 LOC）License 与闭源 SDK 合规审计、Electron 0 耦合真相与 `orcad` 包体/裁剪硬代价、Codex/Claude/ACP 协议与 `orca.yaml` 实况；v2 新增评审补充查证与复现方式（§7），v3 新增 Magpie 插件结构查证（§7.6） | 架构师 / 合规评审 |
| **[`docs/02-architecture.md`](./docs/02-architecture.md)** | **macOS 原生系统架构设计**：路线 A/B/C1 五维对比与锁定裁决、SwiftUI+AppKit 分层、Actor 33ms 节流、三大 Agent 协议映射、`WorktreeManager` 状态机、Direct Distribution & `shepherd-reaper`、GRDB 存储；v3 新增 Claude Code 接入对齐结论（§3.1.4）与 provider 分层（§3.1.5） | 系统架构师 / Swift 工程师 |
| **[`docs/03-product-and-ux.md`](./docs/03-product-and-ux.md)** | **产品规划与 macOS 体验规范**：目标画像、四分法裁剪矩阵、只做 Native Chat 与 Skill 零注入两个专题、双栏/三栏 ASCII 线框图、核心用户旅程、快捷键与量化验收标准 | 产品经理 / 设计师 / 研发 |
| **[`docs/04-roadmap-and-engineering.md`](./docs/04-roadmap-and-engineering.md)** | **工程落地路线图与测试体系**：10 个工程模块目录结构（8 个 SwiftPM 库 + App + Reaper）、无 `--deep` 签名公证与 Sparkle 2 CI/CD、M0–M4 任务与门禁、5 层测试金字塔、R1–R16 风险登记册 | 研发负责人 / 工程团队 |

---

## 当前状态与明确非目标（Non-Goals）

- **当前状态**：`Phase 0 · 方案计划书修订版 v5（2026-11-27）`（**MIT License** / **仅 Apple Silicon `arm64`** / 不内嵌终端 / 开发期占位 Bundle ID，首次公测前定稿）。路线 C1 保留；**Claude Code 接入方案已对齐，Agent 接入改为 provider 分层**，下一步是 **M0 验证 Spike**。仓库已有工程骨架（v5）：`Shepherd.xcworkspace`、`Apps/`（macOS、iOS 两个项目）、`Packages/`（10 个 Swift 包）、`Server/`（Node 中继与推送网关），都只是可构建的空壳，没有业务代码；修订记录见 [`docs/PROPOSAL.md`](./docs/PROPOSAL.md) §8。
- **明确非目标（Out-of-Scope / Defer）**：
  - **不包含模型路由与额度容灾网关（如 Magpie 类能力）**：本期专注本地多 Agent 编排体验本身，仅在底层预留干净的子进程环境变量注入边界，留待后续阶段按需对接。
  - **不做**：Intel Mac 兼容、内嵌 Chromium 浏览器与 Design Mode、内置 Monaco 代码编辑器、远程 SSH / Docker 节点、Linear / Jira / GitHub 项目看板、复杂 DAG 可视化编排器、定时自动化任务、内嵌终端、以及 Mac App Store 沙箱分发。
  - **v5 改回范围**：Mobile Companion（iPhone、iPad、iPhone Duo）列为 P1。Agent 仍只在 Mac 本机执行；Companion 经自建中继连接，内容端到端加密（[`docs/02-architecture.md`](./docs/02-architecture.md) §3.5）。
