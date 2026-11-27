# Shepherd 产品规划与 macOS 原生体验规范

> **文档归属**：Shepherd 方案计划书 · 第三部分（产品与 UX 规划）  
> **关联文档**：上游代码审计见 [`docs/01-orca-audit.md`](./01-orca-audit.md)；系统架构与技术路线见 [`docs/02-architecture.md`](./02-architecture.md)；工程落地与里程碑见 [`docs/04-roadmap-and-engineering.md`](./04-roadmap-and-engineering.md)  
> **范围说明**：本文档定义 Shepherd 的产品定位、相对 `stablyai/orca` 的功能裁剪边界、两项关键产品决策专题、macOS 原生信息架构与交互规范，以及可量化的验收标准。多模型本地路由与额度容灾网关能力**不在本期范围**，仅列为远期演进扩展点。  
> **修订状态**：修订版 v3（2026-11-26）。v2：更新了竞品信息与差异化表述，修正了审批与信任门控的承诺范围，性能指标统一标注为未实测目标。v3：对话只保留 Native Chat，终端抽屉移出规划（3.1 专题 A）；Claude 的权限档位、仓库信任门与备用路径按 [`docs/02-architecture.md`](./02-architecture.md) §3.1.4 定稿；Agent 接入按 provider 组织（§3.1.5）。v4（2026-11-27）：进程清理改为每个 Agent 一个看守进程加进程树标记（[`docs/02-architecture.md`](./02-architecture.md) §3.3.3），相应更新了验收清单与环境变量表述。

---

## 1. 产品定位与竞品差异化矩阵

### 1.1 一句话定位

**Shepherd 是专属于 macOS 开发者的极简、原生、跨厂商多 Agent 指挥台（Agent Command Center）。**

它不做“再造一个 IDE”，也不做大而全的 Electron 桌面工作台，而是彻底剥离重型外围模块，把全部产品打磨集中在开发者多 Agent 并发协作的 **80% 核心闭环**上：

> **Git Worktree 隔离并发 × Native Chat 结构化主交互 × 原生 Diff/PR 快速审查 × 外部主力 IDE 无缝接力**

### 1.2 目标用户画像与核心痛点

| 维度 | 核心用户（Primary Persona） | 次要用户（Secondary Persona） |
| :--- | :--- | :--- |
| **角色特征** | 高频使用 Claude Code + Codex 双持（及部分 ACP 长尾 Agent）的资深全栈 / 基础设施 / 独立 macOS 开发者 | 需要并行推进多项需求、重构与 Bugfix 的 Tech Lead / Staff Engineer |
| **日常工作方式** | 同时推进 2–5 个独立任务；已有顺手的主力编辑器（Cursor / Zed / VS Code / Neovim）；偏爱键盘流与低干扰环境 | 把调研、单测、模块拆分派给多个隔离代理并行执行，自己专注架构把关、权限审批与 PR 审查 |
| **核心痛点** | 1. **工作区碰撞**：多个代理改同一目录导致 Git 状态混乱与文件覆盖。<br>2. **Electron 臃肿**：重型全能工作台常驻占用 1–2GB+ 内存，塞满内嵌浏览器、内置编辑器、看板等用不上的功能。<br>3. **多终端失焦**：纯终端多开（tmux / iTerm）缺乏结构化审批、变更摘要与图形 Diff 闭环，切窗口成本高。<br>4. **厂商锁定**：Claude Code Desktop 与 Codex App 各自圈地，无法按任务特长自由混排模型与代理。 | 1. **注意力过载**：难以一眼识别哪个后台代理卡在权限确认、哪个已完成待审、哪个报错中断。<br>2. **环境污染担忧**：不希望编排工具偷偷往 `~/.claude` 或项目仓库注入私有 Skill/脚本，破坏团队规范或平白消耗 Token 额度。 |

### 1.3 产品原则与非目标（Non-Goals）

- **做减法而非全家桶**：只做好“派活—监控审批—审 Diff—提 PR—清 Worktree”这一条主链路，代码精修永远交给用户已有的主力 IDE。
- **macOS 原生优先（锁定纯 Swift 6 原生内核）**：深度利用 macOS 原生窗口管理、菜单栏、系统通知、明暗材质与快捷键肌肉记忆；基于 [`docs/01-orca-audit.md`](./01-orca-audit.md) 的硬事实审计，彻底放弃 Electron 与重型 Node Sidecar（避免 122.6 MB Node 运行时包体税与多进程内存膨胀），直接采用纯 Swift 6 原生内核。
- **零侵入、零锁定、零闭源 SDK 依赖（BYOA）**：尊重用户本机已有的 Claude Code / Codex / ACP CLI 与认证环境；**绝不打包受 Anthropic 商业条款约束的闭源 `@anthropic-ai/claude-agent-sdk`**，不残留任何 `ORCA_*` / `CLAUDE_CODE_ENTRYPOINT=orca` 上游标识；默认不改写仓库文件、不向 Agent 注入私有提示词或全局 Skill。
- **明确非目标（Out-of-Scope / Defer）**：
  - 不内置浏览器、内置代码编辑器、项目看板、移动端中继或远程 SSH/Docker 编排。
  - **多模型本地路由与额度容灾网关留待后续阶段**：本期仅保持子进程环境变量注入边界干净，不内置任何代理网关或协议转换层。

### 1.4 竞品差异化矩阵

| 对比维度 | **Shepherd（本方案）** | **Orca** (`stablyai/orca`) | **Paradev**（原 Superset） | **Conductor**（Meta 收购） | **Emdash / Parallel Code** | **cmux** | **Claude Code / Codex Desktop** |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **核心定位** | macOS 原生极简多 Agent 指挥台 | 全功能开源跨平台 Electron ADE 战舰 | Mac 优先、偏团队与 Stacked PR 的编排台 | macOS 原生极简多 Agent 体验标杆（2026-11 被 Meta 收购，桌面端只更新到 2027 年初） | 轻量开源多代理并发工作台 | 基于 `libghostty` 的原生极客多代理终端 | 第一方厂商专属桌面端 |
| **技术栈与原生度** | **纯 Swift 6 原生（SwiftUI + AppKit）**，包体 ≤ 25 MB，冷启动 ≤ 400 ms | Electron 45 + Node v24.22.3（~370 万 LOC，重型全栈） | Electron / Web 混合，体量较重 | 原生 macOS，体验极佳 | 多为 Electron / Web 壳 | **原生 Swift/AppKit + `libghostty`**，性能极致 | Electron / 混合应用，跟随官方大客户端演进 |
| **主交互形态** | **只有 Native Chat**；需要 shell 时 `⌘⇧T` 跳系统终端 | Terminal + Native Chat + 编辑器 + 浏览器全套 | Terminal / Chat + 浏览器预览 + Diff | Native Chat 为主 + 简洁审查流 | 偏终端/面板并行视图 | GPU 终端窗格为主 + 侧栏通知环；2026-10 起有「Agent chat panes (beta)」 | 各自优化的 Native Chat / 面板 |
| **Git Worktree 隔离** | **核心一等公民**（支持 `shepherd.yaml` 并兼容 `orca.yaml` 与 SHA-256 脚本门控） | 完整支持（`orca.yaml` `worktree.sharedDirectories` + 信任哈希） | 完整支持，强 Stacked PR 流水线 | 完整支持，开箱即用 | 支持基础 Worktree 隔离 | 依赖外部脚本 / CLI 自行管理 | 支持内置 Worktree（绑定各自生态） |
| **跨厂商 BYOA** | **一等支持**（Claude Code + Codex + ACP，零闭源 SDK；每个 Agent 的接入是可独立维护的 provider） | 一等支持（Claude / Codex / 19 种 ACP），但依赖闭源 Claude SDK | 支持多 CLI Agent | 支持多代理；被 Meta 收购后进入停更倒计时 | 支持主流 CLI 代理 | 任意终端 CLI 均可运行 | **单一厂商锁定**（各自只跑自家代理） |
| **图形化 Diff & PR** | **原生轻量 Diff Inspector + 一键 Commit/PR** | 完整内置（基于 Web/Monaco） | 完整内置（偏团队协作） | 简洁好用的原生 Diff/PR | 基础 Diff 查看 | 已有 Diff 查看器（已阅跟踪、文件过滤）与评审评论相关命令；更新日志中未见应用内创建 PR | 支持（绑死自家体系） |
| **开源与可控性** | **MIT 开源可控、无遥测、零侵入、合规边界清晰** | MIT 开源，但代码库庞大且内置商业条款 SDK | 开源，逐步走向团队商业化功能 | **闭源**（被 Meta 收购，Conductor Cloud 已关停，桌面端 2027 年初停止更新） | 开源但产品成熟度与原生质感有限 | 开源，聚焦终端极客路线 | **闭源第一方** |
| **与 Shepherd 边界** | — | Shepherd 的协议活字典与裁剪参照系，仅提取 <5% 核心协议能力原生重构 | Shepherd 不做团队云同步与重型 Stacked PR 平台 | Shepherd 对标其原生极简质感，但保持开源、跨厂商与本地可控；它的停更窗口是 Shepherd 最直接的时间机会 | Shepherd 强调 macOS 原生渲染与结构化 Chat/审批体验 | cmux 已补上 Diff 与 Chat 面板，「有无图形 Diff」不再是差异点；Shepherd 的差异在跨厂商待处理列表与带上下文的审批 | Shepherd 打破单厂商锁定，让 Claude 与 Codex 同台协同 |

> **v2 差异化重述**（竞品信息查证于 2026-11-26，来源见 [`docs/01-orca-audit.md`](./01-orca-audit.md) §7.5）：
>
> - **原有的两个差异点已经过时**：矩阵曾把「有图形 Diff」「有结构化 Chat」当作相对 cmux 的差异点，这两条在 2026 年下半年已不成立。
> - **更站得住的差异化是三件事**：跨厂商的统一待处理列表（谁在等我）、带上下文的审批（看清再放行）、审批结果与代码变更之间的关联（放行之后改了什么）。
> - **Conductor 停更是有截止时间的窗口**：它的桌面端 2027 年初停止更新，这应当影响 MVP 范围的取舍。是否兼容 Conductor 的仓库配置以降低迁移成本，列为待评估项。

---

## 2. 功能裁剪矩阵（Keep / Trim / Cut / Defer）

针对 `stablyai/orca` 的全量功能面，Shepherd 采用严格的“四分法”裁剪纪律：**每一项保留的能力都必须直接服务于多 Worktree 并发编码与审查主链路**。

> **优先级定义**：
> - **MVP**：首版必须完整闭环，缺一不可。
> - **P1**：首版上线后紧随迭代，补齐高频进阶场景。
> - **P2**：架构预留扩展点，待核心体验稳定后按需评估。
> - **Out-of-Scope**：明确不做，防止产品重新膨胀为第二个重型 IDE。

| 功能模块 | Orca 现状对应 | Shepherd 决策 | 优先级 | 设计说明与替代方案 |
| :--- | :--- | :--- | :--- | :--- |
| **Git Worktree 隔离生命周期** | Worktree 创建、切换、分支管理、孤儿清理 | **Keep** | `MVP` | 核心地基：自动派生独立分支与 Worktree 目录，支持同步 Base 分支状态、安全删除检查（未提交改动二次确认）与孤儿 Worktree 清理。 |
| **项目初始化配置（`shepherd.yaml`）** | `orca.yaml`（`worktree.sharedDirectories`、`scripts.setup`/`archive`、`setupAgentStartupPolicy`）+ Repo 级设置 `symlinkPaths` + SHA-256 脚本信任门控 | **Keep（原生对齐）** | `MVP` | 优先读取 `shepherd.yaml`，**向后兼容读取现有 `orca.yaml`**。运行时合并 Repo 级本地 `symlinkPaths` 与 YAML 的 `worktree.sharedDirectories`（后者经 `git check-ignore` 强制校验仅允许共享已存在且被忽略的目录，防受控文件误软链）；支持 `scripts.setup`/`scripts.archive` 与 **入口信任门控弹窗（命令文本 SHA-256）**；忽略 VM 配方（`environmentRecipes`）等外围字段。 |
| **Native Chat 主对话流（Codex & Claude Code）** | Codex `app-server` + Claude Native Chat（绑定闭源 SDK） | **Keep（去闭源 SDK 重构）** | `MVP` | **一等公民**：Codex 直连 `codex app-server` stdio NDJSON；Claude Code 直接驱动用户本机 `claude` CLI 的 `stream-json` 双向控制协议（**零 `@anthropic-ai/claude-agent-sdk` 依赖**，彻底规避商业条款红线）。完整支持流式文本、可折叠 Thinking、工具调用卡片、内联权限审批条、问题作答卡与表单填写卡（v2 新增，见 4.2）、Turn 变更摘要卡、消息排队与中断。 |
| **长尾 Agent 接入（ACP Client）** | `src/main/acp/*`（JSON-RPC 2.0，19 种 CLI） | **Keep（分层）** | `MVP`（标准流）<br>`P1`（多方言扩展） | MVP 实现标准 JSON-RPC 2.0 over stdio NDJSON 通用协议基础流（文本/工具/权限请求），确保不锁死在两家厂商；P1 逐步补齐主流长尾 Agent 方言适配。**v3**：ACP 客户端同时是外部 provider 的宿主，用户可以手动添加一个说 ACP 的 Agent 作为 provider；Claude 的备用路径 `claude-acp` 也经它接入，所以 MVP 的基础流不可削减（[`docs/02-architecture.md`](./02-architecture.md) §3.1.5）。 |
| **原生 Diff 审查与一键 Commit / PR** | 变更面板 + Diff Viewer + PR 创建 | **Keep（原生重构）** | `MVP` | 按需展开的原生 Diff Inspector：支持文件树、Unified / Split 视图、逐文件与逐 Hunk 审阅/丢弃、一键 Commit（可 AI 草拟或手改）及调用 `gh` / GitHub API 一键创建并查看 PR。 |
| **macOS 系统通知与菜单栏状态徽章** | 桌面通知 + 窗口内角标 | **Keep（原生增强）** | `MVP` | 原生 `MenuBarExtra` 图标随最高优先状态变色/角标；`UNUserNotificationCenter` 精准推送「待审批 / 已完成 / 报错」三类事件，点击直达对应会话审批条。 |
| **外部主力 IDE / 工具一键跳转** | 内置编辑器为主，辅以 Open in... | **Keep（升级为主路径）** | `MVP` | 一键在 **Cursor / Zed / VS Code / Xcode / Finder / 系统默认终端** 中打开当前 Worktree 目录，并支持从 Diff 行号精准跳转到外部 IDE 对应文件与行。 |
| **本地会话持久化与检索** | `node:sqlite` 多库分域落盘 | **Keep（原生精简）** | `MVP`（持久化）<br>`P1`（全文搜索） | 原生 `GRDB.swift`（SQLite WAL）存储 Repo、Worktree、Session 元数据、脚本信任哈希与 Transcript 缓存，支持重启恢复；P1 基于 FTS5 补齐跨会话全文检索。 |
| **内嵌终端** | 全功能多标签/分屏终端 + POSIX `curl` Hook / OSC 7501 | **Cut（v3）** | `Out-of-Scope` | 原定 P1 的 `⌘J` 终端抽屉移出规划。对话只有 Native Chat 一种形态；需要 shell 时用 `⌘⇧T` 跳系统终端（MVP）。理由与代价见 3.1 专题 A。 |
| **本地 `shepherd` CLI 工具** | `orca` 全套 CLI 控制指令 | **Trim** | `P1` | 仅保留面向**人类开发者**的轻量快捷指令（如 `shepherd open .`、`shepherd new "fix auth"`），不作为 Agent 强制控制通道注入。 |
| **内置 Monaco 代码编辑器** | 内嵌完整编辑器 Tab | **Cut** | `Out-of-Scope` | **第一刀砍掉**：绝不在编排器里维护低配编辑器。轻量审阅用原生只读 Diff Inspector，深度手改一键 `⌘O` 交给 Cursor / Zed / VS Code。 |
| **内嵌 Chromium 浏览器 & Design Mode** | 内置浏览器窗格、DOM 选中标注 | **Cut** | `Out-of-Scope` | **第一刀砍掉**：移除了整套 Chromium 渲染进程与内存黑洞。预览本地服务直接点击端口链接在系统默认浏览器打开。 |
| **Mobile Companion 与 E2E Relay** | 手机端远程监控 + 端到端加密中继 | **Cut** | `Out-of-Scope` | **第一刀砍掉**：消除常驻公网中继、设备配对安全面与移动端维护成本。 |
| **远程 SSH / Docker / 云节点管理** | 远程主机与容器化 Worktree 调度 | **Cut** | `Out-of-Scope` | **第一刀砍掉**：Shepherd 专注本机 macOS 极致轻快体验，远程开发交由 IDE Remote 或专门工具承担。 |
| **Linear / Jira / GitHub 全套看板** | 内置 Issue 看板与状态流转视图 | **Cut** | `Out-of-Scope` | **第一刀砍掉**：不把指挥台变成项目管理软件。远期（P2）最多允许粘贴 Issue URL 自动抓取描述作为任务上下文，绝不建看板界面。 |
| **复杂 DAG 可视化编排器** | 多阶段节点连线与依赖图执行 | **Cut** | `Out-of-Scope` | **第一刀砍掉**：避免过度抽象与低频“画流程图编程”；日常任务通过清晰的多 Worktree 列表即可直觉管理。 |
| **定时自动化任务（Cron / Schedules）** | 定时拉起 Agent 执行后台任务 | **Cut** | `Out-of-Scope` | **第一刀砍掉**：定时无人值守任务属于 CI/GitHub Actions 或系统 `launchd` 范畴，留在桌面 App 中反而增加后台常驻复杂度与额度误耗风险。 |
| **Agent 自驱派活模式（Opt-in）** | 默认注入 `orchestration` + `orca-cli` Skill | **Defer** | `P2` | MVP 坚持零注入（详见 3.2 专题 B）；P2 作为显式 Opt-in 开关，以会话级轻量本地 MCP Server 形态引入。 |
| **团队云同步 / 多人协作会话** | 团队配置与云端工作区共享 | **Defer** | `P2` | 本期 100% 本地优先（Local-First），零账号登录、零云端依赖。 |
| **多模型本地路由与额度容灾网关** | （无原生内置，属外部网关能力） | **Defer** | `P2` | **本期明确忽略**：仅在进程启动层保持环境变量注入干净，留待后续阶段按需对接外部本地代理或网关方案。 |

---

## 3. 关键产品决策专题

### 3.1 专题 A：只做 Native Chat，不内嵌终端（v3 改写）

> **v3 决定**：对话只有 Native Chat 一种形态。原方案的「90% Native Chat + 10% `⌘J` 终端抽屉」取消，终端不再承担 Claude 的接入或备用职责。架构侧的说明见 [`docs/02-architecture.md`](./02-architecture.md) §2.4 与 §3.1.4。

#### 原方案保留终端的四个理由，现在各自怎么处理

| 原先的理由 | 现在的处理 | 留下的代价 |
| :--- | :--- | :--- |
| **Claude 订阅额度消耗与用量政策**：非交互路径可能比交互式 TUI 更费额度；Anthropic 曾宣布把 `claude -p` 用量移出订阅额度，2026 年 6 月暂停，未给恢复时间（[`docs/01-orca-audit.md`](./01-orca-audit.md) §7.5） | 接受该风险。会话头部显示登录与计费来源；M0 实测真实消耗，替换掉原稿无出处的「1.8×–3×+」；政策恢复时的出路在产品之外：改用 API Key，或经外部网关换模型与账号 | 产品内没有对冲手段。政策恢复后，订阅登录的 Claude 会话会按新规则计费 |
| **TUI 专属斜杠命令**：`/btw`、`/recap`、`/usage`、`/login`、`/doctor` 等在 `stream-json` 模式下无法直通 | 只支持无头模式下可用的部分，清单由 M0 列出；高频操作（压缩上下文、切换模型、中断、重试）做成 Native Chat 的原生按钮与 `/` 补全；用量从结果帧与限流事件读取 | `/btw` 这类 TUI 专属交互在 Shepherd 里没有 |
| **需要真实终端的交互式命令**：首次登录、`git rebase -i`、带 2FA 的脚本、本地 Dev Server、REPL | `⌘⇧T` 在用户的默认终端里打开当前 Worktree；登录由用户事先在自己的终端里完成，Shepherd 检测到未登录时给出提示 | 这些操作发生在 Shepherd 之外，侧栏看不到它们的状态 |
| **启动参数、自定义 Wrapper 与多账号切换** | 会话环境与用户终端一致（v4：只多一个用于进程清理的标记变量），不清理 `CLAUDE_CONFIG_DIR` 等变量；设置页可指定二进制路径；账号管理不在范围内 | 想临时换账号或试验 CLI 参数，需要到系统终端里做 |

#### 这个决定换来什么

- **一种交互形态**。不需要在 Native Chat 与 TUI 之间做会话互斥、状态同步和转录回填。
- **少一个依赖和一个模块**。不引入终端引擎，不维护 PTY 容器池与终端 Hook。
- **备用路径留在 Native Chat 内**。Claude 的备用是外部 provider `claude-acp`：界面不变，底层换成用户自行安装的 ACP 适配器，切换后新开会话。

#### 用户会感知到的限制

- 不能在 Shepherd 里把一个会话切到原版 TUI 再切回来。用户在系统终端里运行的 `claude` 是独立会话，Shepherd 不跟踪。
- `claude-acp` 需要用户自己安装 Node ≥ 22 与适配器，并且同样受用量政策影响。

---

### 3.2 专题 B：是否注入 Shepherd / Orca Skill？

经上游审计证实，Orca 采用「轻量 Stub + 按需拉取 Guide」两级架构：安装时会向用户的 `~/.agents/skills`、`~/.claude/skills`、`~/.codex/skills` 写入 `orca-cli`（45 KB Guide）与 `orchestration`（9.7 KB Guide + 7 篇参考文档）两个 Skill Stub，教 Agent 调用 CLI 去创建 Worktree、派发子代理、读取其他会话。即便采用了 Stub 懒加载，**默认往用户全局 Agent 配置目录写文件依然违背极简与零污染原则**；对 Shepherd 而言，是否注入 Skill 直接决定了产品的边界感与可信度。

#### 两种产品模式的本质区分

| 维度 | **模式 1：人肉多开指挥台模式（MVP 默认）** | **模式 2：Agent 自驱派活模式（P2 · Opt-in）** |
| :--- | :--- | :--- |
| **控制权归属** | **人类是唯一指挥官**（Shepherd = 牧羊人），主动决定开几个 Worktree、用 Claude 还是 Codex、何时审批与合并。 | 允许主 Agent 提出拆分计划，向 Shepherd 申请派生子 Worktree 或跨代理移交任务（如 Claude 编码 → Codex 审查）。 |
| **注入策略** | **零注入、零污染**：绝不向 `~/.claude/`、`~/.codex/`、目标 Git 仓库或 System Prompt 偷偷追加任何 `SKILL.md`、`CLAUDE.md` 或隐蔽工具。 | **显式开关（Opt-in）**：需用户在设置或单次会话中主动开启，强制配置并发配额上限（如默认最多派生 3 个子 Worktree）与人类审批门控。 |
| **核心优势** | 1. **零 Token 税**：不白白吃掉宝贵的上下文与订阅额度。<br>2. **零行为漂移**：与用户自建 Skills、项目 `CLAUDE.md` 100% 无冲突。<br>3. **零失控套娃**：杜绝 Agent 擅自裂变子任务烧光额度。 | 适合超大规模重构、并行探索多套方案或自动化“写-审”接力的高阶用户。 |

#### 未来开启“Agent 自驱派活模式”时的技术与 UX 选型：Skill + CLI vs 本地轻量 MCP Server

当 P2 引入 Opt-in 自驱模式时，不应照搬 Orca 的「写 Skill + 调 Shell CLI」做法，而应优先采用 **会话级动态挂载的本地轻量 MCP Server**。核心取舍如下：

| 对比维度 | **方案一：注入 Skill + Shell CLI**（Orca 做法） | **方案二：会话级本地轻量 MCP Server**（Shepherd P2 推荐） |
| :--- | :--- | :--- |
| **磁盘与配置污染** | 易在全局 Skill 目录或项目路径留下残留文件，卸载或关闭开关难以彻底干净。 | **零磁盘残留**：仅在用户开启该会话的开关时，通过进程启动参数动态挂载本地 stdio/Socket MCP Server；关闭开关即彻底消失。 |
| **跨 Agent 通用性** | 需针对 Claude / Codex / ACP 分别维护不同 Skill 发现路径与提示词格式。 | **天然跨厂商标准**：Claude Code、Codex 与 ACP 均原生支持 MCP 工具协议，一套 Schema 通吃。 |
| **参数可靠性与错误率** | 依赖模型拼装 Shell 参数与解析标准输出，偶发转义错误、flag 幻觉或输出截断。 | JSON Schema 强类型校验，入参出参结构化，显著降低调错概率。 |
| **权限审批与安全拦截** | 混杂在通用 `Bash` 工具调用中，Shepherd 难以精准区分普通命令与“派活指令”。 | **一等审批拦截**：如 `shepherd_spawn_worktree` 等工具可由 Shepherd 渲染专属富交互审批卡（直接预览目标分支、选用 Agent 与 Prompt），一键批准或微调后再执行。 |
| **Token 成本控制** | 大段 Markdown Skill 文档常驻或高频读取，占上下文。 | 仅暴露 3–4 个极简核心 Tool（`list_worktrees` / `spawn_task` / `read_diff_summary`），Schema 精炼可控。 |

> **专题 B 最终决策**：
> 1. **MVP 坚决默认不注入任何 Skill 或 MCP 工具**，全面恪守“零注入、零污染、零额外 Token 税”的人肉多开指挥台定位。
> 2. **P2 按需提供 Opt-in「允许 Agent 协作派活」开关**，底层通过**会话级动态挂载的本地轻量 MCP Server** 实现，且所有派生动作默认经过人类审批确认；`shepherd` CLI 仅保留给人类开发者在外部终端手动调用。

---

## 4. macOS 原生信息架构与交互规范

### 4.1 布局架构与 ASCII 线框图

Shepherd 采用 **“默认极简双栏 + 按需展开右侧 Diff Inspector”** 的渐进式空间布局（遵循 macOS `NSSplitViewController` 原生体验，支持流畅折叠与宽度记忆）。

#### 视图 A：日常开发态（默认双栏 · Diff 收起）

```text
+---------------------------------------------------------------------------------------------------+
| o o o   Shepherd           [ Repo: api-server / feat/oauth-pkce ]   [Cmd+O Cursor v] [Diff 3] [>_]|
+---------------------------+-----------------------------------------------------------------------+
| REPOS & WORKTREES   [Src] |  Claude Code · Sonnet   ·   Branch: feat/oauth-pkce   ·  +142 -28     |
| Filter: All | NeedMe (1)  |-----------------------------------------------------------------------|
|                           |                                                                       |
| v api-server              |  You                                                                  |
|   * feat/oauth-pkce  [C]  |  把 OAuth 登录流程切到 PKCE，并补齐 callback 异常单测。               |
|     Running · 1m 20s      |                                                                       |
|   ! fix/rate-limit   [X]  |  > Thought for 6.2s  (点击展开推理过程)                               |
|     Needs Approval!       |                                                                       |
|   v chore/sql-index  [C]  |  +- Tool Group: Read 4 files ----------------------------------- > -+ |
|     Done · +38 -4 · PR#84 |  |  auth/oauth.go, auth/pkce.go, routes.go, auth_test.go            | |
|                           |  +------------------------------------------------------------------+ |
| v shepherd-mac            |                                                                       |
|   o feat/diff-split  [A]  |  +- Edit: auth/oauth.go (+86 -19) --------------------- [Open Diff] + |
|     Idle · Clean          |  |  实现 generateCodeVerifier() 与 S256 challenge 校验逻辑          | |
|                           |  +------------------------------------------------------------------+ |
|                           |                                                                       |
|                           |  += [!] APPROVAL REQUIRED · Shell Command ==========================+ |
|                           |  |  go test ./internal/auth/... -v -race                            | |
|                           |  |  [ Allow Once (Cmd+Ret) ] [ Allow Session ] [ Deny ] [+ 附原因]  | |
|                           |  +==================================================================+ |
|                           |                                                                       |
|                           |-----------------------------------------------------------------------|
|                           |  @file 引用 · 拖拽图片/日志 · 输入下一条指令（运行中可排队）...       |
|---------------------------|                                           [ Claude v ]  [ Stop / Ret ]|
| [ + New Worktree (Cmd+N) ]|                                                                       |
+---------------------------+-----------------------------------------------------------------------+
图例: * 绿脉动(运行中)  ! 琥珀高亮(待审批)  v 蓝/绿勾(已完成未读)  x 红(报错)  o 灰(空闲)
      [C] Claude Code   [X] Codex          [A] ACP Agent
```

#### 视图 B：代码审查三栏态（`⌘⇧D` 展开右侧 Diff Inspector）

```text
+--------------------+-------------------------------------+----------------------------------------+
| REPOS & WORKTREES  | NATIVE CHAT                         | DIFF INSPECTOR     [Unified|Split] [X] |
|                    |                                     | Base: main v  Filter: 3 files (+142-28)|
| v api-server       |  [ok] 已完成 PKCE 改造并通过全部    |----------------------------------------|
|  * feat/oauth-pkce |       12 项竞态测试。               | v internal/auth/                       |
|  ! fix/rate-limit  |                                     |   M  oauth.go                +86  -19  |
|  v chore/sql-index |  +- Turn Summary ----------------+  |   A  pkce.go                 +41   -0  |
|                    |  | 3 files changed  +142 -28     |  |   M  oauth_test.go           +15   -9  |
|                    |  | Elapsed 48s · Est. 18.4k tok  |  |----------------------------------------|
|                    |  | [ Diff Cmd+Sh+D ] [ Cmd+O ]   |  | internal/auth/oauth.go     [Open Line] |
|                    |  +-------------------------------+  | @@ -42,6 +42,11 @@  [Stage]  [Discard] |
|                    |                                     |  42  func HandleCallback(w, r) {       |
|                    |                                     |  43 - token, err := exchange(code)     |
|                    |                                     |  44 + verifier := loadVerifier(r)      |
|                    |                                     |  45 + token, err := exchangePKCE(...)  |
|                    |                                     |  46   if err != nil { return err }     |
|                    |                                     |----------------------------------------|
|                    |-------------------------------------| Commit: feat(auth): enforce OAuth PKCE |
| [ + New (Cmd+N) ]  |  输入跟进指令...             [ Ret ]| [ Commit ]   [ Create PR (Cmd+Sh+P) ]  |
+--------------------+-------------------------------------+----------------------------------------+
```

### 4.2 各区域组件交互规范

1. **左侧：Repo & Worktree 状态树（Sidebar）**
   - **视觉降噪与状态优先**：默认按 Repository 分组，支持顶部一键切至 `NeedMe` 视图（仅置顶「待审批」与「报错」项，方便高并发时瞬间清零阻塞）。
   - **五态指示点规范**：
     - `Running`（绿色呼吸点）：代理正在推理或执行工具，副标题显示已运行计时或当前动作摘要（如 `Running tests...`）。
     - `Needs Approval`（琥珀色高亮徽章 + 左侧竖条）：最高优先级，永不折叠隐藏。v2：该状态同时覆盖等待作答与等待填表，界面文案建议统一为「等你处理」。
     - `Completed`（蓝色未读圆点，点击查看后转中性绿勾）：Turn 完成且有未查看产出。
     - `Error`（红色警示点）：进程异常退出、触发额度上限 `429` 或初始化脚本失败，点击直接展示可操作恢复建议（重试 / 换一个 provider 新开会话 / `⌘⇧T` 到系统终端排障）。
     - `Idle`（浅灰空心圆）：安静待命。
   - **上下文右键菜单**：在 Cursor/Zed/VS Code 打开、在 Finder 中显示、复制 Worktree 路径、同步 Base 分支、归档并清理 Worktree。

2. **中间：Native Chat 主对话流**
   - **可折叠 Thinking 区块**：生成期间展示单行动态摘要（支持随时展开看完整思考流），该步结束后自动折起为紧凑一行（`Thought for Xs`），避免刷屏遮挡结论与代码。
   - **结构化工具调用卡片**：
     - 自动归并连续的只读操作（如连续 `Read` / `Grep` / `Glob` 聚合成 `Explored 5 files` 折叠条）。
     - 写操作（`Edit` / `Write`）与终端命令（`Bash`）独立展示卡片，带文件路径可点击直跳右侧 Diff，或带退出码与输出预览（超 15 行默认折叠，支持一键展开/复制）。
   - **内联权限审批条（Inline Approval Bar）**：
     - 显眼琥珀边框 + 操作语义分类标签（如 `Shell Command`、`Write Outside Worktree`、`Git Push`）。
     - 提供 `Allow Once (⌘↩)`、`Allow for Session`（同类低风险操作本会话免扰）、`Deny (⌘⌫)` 三个动作；点 `Deny` 或展开输入框可附带一句纠正指令（如“改跑单测不要跑全量集成测试”），代理收到拒绝理由后直接调整策略而非盲目中止。
   - **问题作答卡与表单填写卡（v2 新增）**：
     - 不是所有「等你」的请求都是审批。Agent 提问（如「选哪种迁移策略」）时显示问答卡，用户选择选项或输入文字后回传答案。
     - MCP 工具要求结构化输入时显示表单卡，按请求给出的字段渲染。
     - 这两类与权限确认一起进入同一个待处理列表和 `⌘⇧A` 跳转序列，但各自保留原始语义，不能压成「允许 / 拒绝」（[`docs/02-architecture.md`](./02-architecture.md) §3.1.1）。
   - **如实标注审批覆盖范围（v2 新增）**：审批条只会出现在 Agent 实际发来请求的操作上，用户在 Agent 自己的配置里放行过的操作不会经过 Shepherd。权限档位的说明文字要写明这一点，界面只提供经过验证能够兑现的档位（[`docs/02-architecture.md`](./02-architecture.md) §3.3.4）。
   - **Claude 的权限档位（v3 定稿）**：沿用我的 Claude 设置（默认）、询问、自动接受编辑、计划模式、完全放行，与 Claude 的原生权限模式一一对应；「完全放行」每个会话单独确认；首版不提供「每次询问」（[`docs/02-architecture.md`](./02-architecture.md) §3.1.4）。
   - **会话头部（v3 新增）**：始终显示当前 provider、登录方式与计费来源、实际生效的权限模式；本机 CLI 版本超出已测试范围时在这里提示。用户不必打开终端就能知道这个会话用的是哪个账号、按什么规则放行。
   - **文件变更摘要卡（Turn Summary Card）**：每轮对话结束汇总本轮触碰文件数、总增删行、耗时、Token/用量估算（视后端可用字段），附带 `Review Diff` 与 `Open in IDE` 快捷按钮。
   - **消息队列（Follow-up Queue）**：当代理仍在运行时，用户依然可以在底部输入框输入并提交下一条补充要求，自动进入待发送队列并可随时编辑或取消。

3. **右侧：按需切换的 Diff Inspector（`⌘⇧D`）**
   - **双基线对比切换**：一键在 `Uncommitted Changes`（当前未提交改动）与 `Branch vs Base`（相对 `main` 的全部提交，用于最终 PR 审查）间切换。
   - **逐文件 / 逐 Hunk 轻量操作**：支持 Unified 与 Side-by-Side Split 两种视图；每个文件与每个 Hunk 支持标记「已审阅（Reviewed）」勾选状态、局部 `Stage Hunk` 或 `Discard Hunk`（撤销代理改偏的局部片段），以及点击行号直接跳转到外部 IDE 对应精确行。
   - **提交与 PR 闭环**：底部内嵌紧凑操作区，一键基于当前 Diff 自动生成规范 Commit Message / PR 标题与正文（支持直接编辑），点击即调用本地 `git` 与 `gh` CLI 推送并创建 PR；创建后自动关联 PR 链接与 CI Checks 状态摘要。

### 4.3 核心用户旅程（End-to-End Flows）

```mermaid
flowchart LR
    S1["1. 创建与派发 (⌘N)"] --> S2["2. 并发监控与审批 (⌘⇧A)"]
    S2 --> S3["3. 审查与外部精修 (⌘⇧D / ⌘O)"]
    S3 --> S4["4. 提交 PR 与清理 Worktree"]
    S3 -.->|"需继续修改 / 追问"| S2
```

#### 旅程 1：创建 Worktree 并派发任务（目标：15 秒内发出第一条指令）
1. 用户按下 `⌘N`（或点击左侧 `+ New Worktree`），弹出居中轻量化创建面板（Spotlight 风格）。
2. 选择目标 Repository（默认上次使用仓库）与 Base Branch（默认 `main`）。
3. 选择 provider（默认记住上次偏好：Claude Code / Codex / 已添加的外部 provider）、模型预设与权限档位。
4. 直接输入任务 Prompt；Shepherd 自动异步生成短小规范的分支名（如 `feat/oauth-pkce`，支持随时手改）。
5. 回车确认 → 立即切换至新建会话页面并后台执行 `git worktree add`：
   - **共享目录安全软链**：合并 Repo 级本地设置 `symlinkPaths` 与 `shepherd.yaml` / `orca.yaml` 中的 `worktree.sharedDirectories`。对 YAML 声明的 `sharedDirectories` 强制执行 `git check-ignore` 校验——**仅放行已存在且被 `.gitignore` 忽略的目录**（适合共享的是与分支无关的大型缓存；各分支依赖不同的 `node_modules` 不适合共享，见 [`docs/02-architecture.md`](./02-architecture.md) §3.2.2）；软链建好后把对应路径写入 `.git/info/exclude`，避免软链本身出现在 `git status` 里；若命中受 Git 追踪的路径则安全跳过并在顶部提示条展示可审计警告，绝不破坏受控文件。
   - **仓库信任门（v3 新增）**：仓库第一次加入 Shepherd 时确认一次。弹窗说明该仓库的项目级 Agent 配置（hooks、MCP 配置）会在会话启动时直接生效，Agent 自己不会再问。确认按仓库记录，对它的所有 Worktree 生效，不写入 Agent 的配置文件。它与下面的脚本信任共用一个 Sheet、分开记录（[`docs/02-architecture.md`](./02-architecture.md) §3.1.4）。
   - **初始化脚本 SHA-256 信任门控弹窗（Trust Gate Sheet）**：若仓库配置包含 `scripts.setup`，执行前对规范化命令文本计算 **SHA-256 哈希**并与本地已信任哈希集合（按仓库与脚本类型保留多版本历史已信任记录，避免多分支来回切换时反复弹窗）比对：
     - *哈希已信任*：静默执行，按 `setupAgentStartupPolicy`（`start-immediately` 或 `wait-for-setup`）决定 Agent 启动时机，零弹窗阻塞；
     - *首次遇到或命令文本被修改*：暂停脚本执行并弹出 macOS 原生 Sheet 信任确认框——展示配置文件路径（`shepherd.yaml` / `orca.yaml`）、完整脚本文本与 SHA-256 指纹摘要（变更时标明“脚本已与上次信任版本不同”），提供 **`信任此仓库执行此入口`**、**`跳过脚本继续创建`**、**`取消`** 三个明确按钮。
     - *v2 边界说明*：弹窗展示并哈希的是 YAML 里的命令文本。命令调用的仓库内脚本或包管理器钩子内容变化时不会重新弹窗。弹窗文案要直说这一点，不把它描述成对恶意分支的防护（[`docs/02-architecture.md`](./02-architecture.md) §3.2.3）。
   - 初始化就绪后自动投递首轮 Prompt 开始流式执行。

#### 旅程 2：多任务并发监控与权限审批
1. 用户同时启动 3–4 个 Worktree（例如 Claude 做核心接口、Codex 写单测、另一个 Claude 查性能问题），随后切去 Cursor 或浏览器工作。
2. 当 `fix/rate-limit` 的代理请求执行敏感命令（如修改配置或运行数据库迁移）时：
   - 菜单栏 Shepherd 图标立刻切换为琥珀待办状态并显示角标 `1`；
   - macOS 系统通知滑出，展示 `[api-server · fix/rate-limit] 等待批准: go test ...`；
   - 侧边栏该行置顶/高亮待审批态。
3. 用户点击系统通知（或在应用内按 `⌘⇧A` 跳转下一个待审批项）→ Shepherd 拉起前台并自动滚动聚焦到对应内联审批条。
4. 用户快速扫视命令与上下文，按 `⌘↩` 批准或 `⌘⌫` 拒绝（可选附一句反馈）→ 代理瞬间恢复运行；若有下一条待审批项，状态栏提示按 `⌘⇧A` 连续处理。

#### 旅程 3：审查 Diff 与外部 IDE 精修接力
1. 某 Worktree 任务完成，状态转蓝并触发柔和的系统完成通知。
2. 用户切入该会话，先读 Turn Summary，按 `⌘⇧D` 滑出右侧 Diff Inspector，快速浏览文件树与改动 Hunk。
3. 发现 90% 代码很扎实，但其中一处边界条件更适合自己顺手微调：
   - 方式 A：若改动极小，直接在对话流中追问一句，或对局部错误 Hunk 点 `Discard Hunk`。
   - 方式 B：按 `⌘O`（或点击 Diff 行旁的 `Open Line ↗`），零延迟在 **Cursor / Zed / VS Code** 中直接打开该 Worktree 目录与精确行号。
4. 用户在外部 IDE 编辑保存后切回 Shepherd，文件系统监听器自动刷新 Diff Inspector 与变更行数统计，无需手动刷新。

#### 旅程 4：一键提交 PR 并安全清理 Worktree
1. Diff 审阅无误后，用户按 `⌘⇧P`（或点击 Diff Inspector 底部 `Create PR`）。
2. 弹出紧凑确认条：可选择一键提交当前未暂存改动（默认预填规范 Commit Message），确认 PR 标题、摘要与 Draft/Ready 状态。
3. 确认后自动执行 `git commit` → `git push -u origin <branch>` → `gh pr create`，成功后在对话流插入可点击的 PR 卡片，侧边栏同步展示 `PR #84`。
4. PR 合并后（或决定放弃该探索分支时），用户在侧边栏点击「Archive & Clean Worktree」：
   - Shepherd 自动检查是否存在未提交/未推送改动或未跟踪风险文件（有脏文件则强提醒并列出文件清单，防误删）；
   - 若配置了 `scripts.archive`，同样执行入口信任校验（命令文本的 SHA-256 哈希未被信任则弹 Sheet 确认），且若归档脚本返回非零退出码则自动阻断删除并提示原因；
   - 确认后安全执行 `git worktree remove`、可选删除本地已合并分支，并在后台优雅终止该 Worktree 关联的残余进程；
   - 历史对话与元数据转入归档区只读保留，保持活跃列表永远干净清爽。

---

### 4.4 macOS 原生质感细节（HIG 对齐）

1. **菜单栏状态徽章与 Popover（`MenuBarExtra`）**
   - **极简动态图标**：遵循 macOS Monochrome 模板图标规范；空闲为简约轮廓，有代理运行中显示微动效指示点，有待审批项时显示高辨识度琥珀状态点与数字（如 `● 2`）。
   - **点击 Popover**：宽度 ~320pt，按优先级分为「需立即处理（待审批 / 报错）」「运行中」「近期已完成」三组；鼠标悬停显示简短命令或摘要，点击任意条目立刻激活主窗口并直达目标 Worktree，无需在 Dock 与多桌面间翻找窗口。
   - **安全原则**：不在极窄的菜单栏 Popover 中直接提供高危命令的“盲批”按钮，一律点击跳入主窗口看清上下文后再 `⌘↩` 确认，防止误触。

2. **macOS 原生系统通知（`UNUserNotificationCenter`）**
   - **严控信噪比**：仅对三类事件推送通知——① 需要权限审批（高优）、② Turn 执行完成（常规，可配置静默）、③ 运行错误/限流中断（高优）。
   - **智能抑制**：当用户正聚焦在主窗口且当前选中的就是该 Worktree 时，自动抑制系统弹窗，避免重复打扰；用户可在设置中按类型独立开关提示音。
   - **深链接直达**：通知携带 `worktree_id` + `approval_id`，点击通知直接激活对应 macOS Space 中的窗口并滚动定位到目标卡片。

3. **全局与窗口键盘快捷键体系**

| 快捷键 | 作用域 | 功能说明 | 优先级 |
| :--- | :--- | :--- | :--- |
| `⌘K` | 应用内 | 唤起全局命令面板（模糊搜索并切换任意 Repo / Worktree / 动作 / 外部 IDE） | `MVP` |
| `⌘N` | 应用内 | 新建 Worktree 并派发新任务 | `MVP` |
| `⌘1` – `⌘9` | 应用内 | 快速切换侧边栏前 9 个活跃 Worktree 会话 | `MVP` |
| `⌘⇧A` | 应用内（可选全局热键） | 跳转至下一个「待审批 / 报错」Worktree 并聚焦审批条 | `MVP` |
| `⌘⇧D` | 当前会话 | 展开 / 收起右侧 Diff Inspector | `MVP` |
| `⌘O` | 当前会话 | 在默认外部 IDE（Cursor / Zed / VS Code）中打开当前 Worktree | `MVP` |
| `⌘⇧O` | 当前会话 | 弹出外部工具选择器（切换打开方式 / Finder / Xcode） | `MVP` |
| `⌘⇧T` | 当前会话 | 在系统默认终端（Ghostty / iTerm2 / Terminal）中打开当前 Worktree | `MVP` |
| `⌘↩` | 审批条 / 输入框 | 有聚焦审批条时批准当前操作（`Allow Once`）；在输入框时发送消息 | `MVP` |
| `⌘⌫` | 审批条 | 拒绝当前待审批操作（`Deny`） | `MVP` |
| `⌘.` | 当前会话 | 优雅中断当前正在生成的 Agent Turn | `MVP` |
| `⌘⇧P` | 当前会话 | 发起 Commit & Create PR 流程 | `MVP` |
| `⌘\` | 窗口 | 折叠 / 展开左侧 Repo & Worktree 侧边栏（专注模式） | `MVP` |
| `⌘,` | 应用内 | 打开 macOS 原生多标签设置窗口（General / Providers / External Apps / Shortcuts） | `MVP` |

4. **视觉质感、明暗主题与窗口记忆**
   - **外观与材质**：完整适配 macOS Light / Dark / System 自动切换；左侧栏采用系统原生 Vibrancy 半透明材质（`NSVisualEffectView`）；全面使用原生 SF Symbols 与系统动态字体（正文 SF Pro、代码与 Diff 采用 SF Mono 或用户自选等宽字体，支持 `⌘+` / `⌘-` 独立缩放字号）。
   - **无障碍与动效**：遵循 macOS `Reduce Motion` 与 `Increase Contrast` 设置，动画克制干脆（面板切换 ≤ 180ms）。
   - **状态记忆与安全退出**：精确持久化窗口尺寸、位置、侧边栏/Diff 栏宽度、上次打开的 Worktree、各仓库偏好的 Agent 与默认外部 IDE。当用户按 `⌘Q` 退出时，若仍有运行中的 Agent 子进程，弹出原生确认提示（“仍有 N 个代理任务运行中，退出将安全终止它们”），确认后由进程管理器经各 Agent 的看守进程回收其进程组、会话与带进程树标记的后代（覆盖范围见 [`docs/02-architecture.md`](./02-architecture.md) §3.3.3）。

---

## 5. 验收标准（UX & 性能目标）

为保证 Shepherd 真正兑现“比 Electron 轻量一个数量级、具备原生 macOS 丝滑手感”的产品承诺，制定以下可量化验收门槛。

> **路线锁定与口径说明**：基于 [`docs/01-orca-audit.md`](./01-orca-audit.md) 的上游源码实证（`orcad` 虽已 0 Electron 耦合，但锁定 Node v24.22.3 单二进制即 122.59 MB + 11 MB JS bundle + 25 子进程 + 1,202 深度捆绑 RPC + 闭源 Claude Agent SDK 商业条款风险），Shepherd **已最终锁定纯 Swift 6 原生内核路线（仅 Apple Silicon `arm64` · macOS 15.0+ · MIT 开源）**（详见 [`docs/02-architecture.md`](./02-architecture.md)）。下表直接以纯 Swift 6 原生交付标准作为唯一正式验收门禁。
>
> **v2 口径补充**：下表「目标」列是设计目标，尚未实测；「对比参考」列是估算，不是测量值。M0 起逐项用实测替换。

### 5.1 性能与资源占用指标

| 指标维度 | 衡量标准 | 正式验收目标（纯 Swift 6 原生） | 对比参考（Electron / Node Sidecar 基线） | 验证方式 |
| :--- | :--- | :--- | :--- | :--- |
| **冷启动可交互时间（TTI）** | 点击图标到主窗口与历史 Worktree 列表完全可交互 | **≤ 400 ms** | ~1,200 – 2,500 ms | Apple Silicon (M1+) 实机冷启动 10 次取 P95 |
| **热唤醒响应** | 菜单栏或通知点击拉起后台常驻窗口并聚焦目标会话 | **≤ 80 ms** | ~150 – 300 ms | 实机 Instruments / 日志打点 P95 |
| **空闲常驻内存** | 启动后无活跃代理（展示 5 个历史 Worktree） | **≤ 80 MB**（目标 45–75 MB） | 250 – 500 MB+（仅 `orcad` 多进程） | macOS Activity Monitor 物理占用（Phys Footprint） |
| **高并发常驻内存** | 同时运行 5 个活跃 Worktree（含长对话流与打开 Diff）*不含用户本机 Claude/Codex CLI 自身进程* | **≤ 220 MB** | 600 MB – 1.5 GB+ | 模拟 5 路高吞吐流式输出持续 15 分钟观测，且关闭会话后内存可回落无持续泄漏 |
| **整组进程占用（v2 新增 · 观测项）** | 同一场景下 Shepherd 加上它拉起的全部 Agent CLI 及其子进程的合计占用 | 不设门禁，随版本记录 | — | 同一次压测中一并采集。用户感受到的是整组占用，Shepherd 自身的 220 MB 只是其中一部分 |
| **空闲 CPU 占用** | 无活跃代理、窗口在后台 | **< 0.5%** | 1% – 3% | Instruments Time Profiler 连续采样 5 分钟 |
| **安装包体积** | 签名公证后的 `.dmg` 分发体积 | **≤ 25 MB**（目标 12–22 MB） | > 150 MB（未压缩口径；仅单架构 Node 24 二进制即 122.6 MB，其压缩后发行包约 26–51 MB） | Release 构建产物实测 |

### 5.2 并发交互与实时性指标

| 指标维度 | 衡量标准 | 目标值 | 验证方式 |
| :--- | :--- | :--- | :--- |
| **Worktree 切换延迟** | 侧边栏点击或 `⌘1-9` 切换不同 Worktree 会话到首屏渲染完成 | **≤ 50 ms** | 包含 200+ 条消息会话来回切换 P95 测量 |
| **多路流式渲染帧率** | 5 个 Worktree 并发输出 Token 时，前台会话滚动与展开折叠流畅度 | **稳定 60fps**（ProMotion 屏达 120fps，无主线程掉帧 > 16ms） | Instruments Core Animation / SwiftUI 渲染监测 |
| **大 Diff 渲染性能** | 展开 50 个变更文件、总计 2,000 行改动的 Diff Inspector 首帧可用时间 | **≤ 150 ms** | 构造标准测试仓库实测 |
| **Worktree 创建响应** | 确认新建到进入会话界面（不含用户自定义耗时 `scripts.setup`） | **≤ 500 ms** | 10 万行级别本地 Git 仓库实测 |
| **审批通知端到端延迟** | Agent 发出权限请求事件 → macOS 菜单栏变色 + 系统通知弹出 | **≤ 300 ms** | 集成测试打点（Runtime 事件时间戳至 `UNUserNotificationCenter` 回调） |
| **文件变更自动刷新延迟** | 在外部 IDE（Cursor/Zed）保存文件 → Shepherd Diff Inspector 自动刷新 | **≤ 500 ms** | `FSEvents` 监听端到端实测 |

### 5.3 产品体验与可靠性验收清单（MVP Definition of Done）

- [ ] **双代理一等闭环**：在同一仓库中同时开启至少 1 个 Claude Code Worktree 与 1 个 Codex Worktree 并行执行任务，互不干扰、无文件冲突、审批互不串台。
- [ ] **配置兼容与安全门控验证**：对已有 `orca.yaml`（含 `worktree.sharedDirectories` 与 `scripts.setup`/`scripts.archive`）的仓库，Shepherd 无需改造即可兼容运行；存在 `shepherd.yaml` 时优先读取 `shepherd.yaml`；`git check-ignore` 能准确拦截未忽略目录防止误软链；首次运行或命令文本变化时 100% 触发信任门控弹窗，切回历史已信任哈希分支不重复弹窗；弹窗文案如实说明不覆盖被调用脚本文件的内容变化；软链建立后 `git status` 不出现软链本身。
- [ ] **零污染与零闭源 SDK 合规审计**：在默认设置下完整运行一轮新建 Worktree → 对话 → 审批 → Diff → 清理全流程，确认对 `~/.claude`、`~/.codex` 与目标 Git 仓库零未声明 Skill/配置写入（已声明的写入包括 `.git/info/exclude`、Agent CLI 自己写的会话文件，以及向 Agent 环境加入的一个进程树标记变量）；同时扫描构建产物确认 **0 处闭源 `@anthropic-ai/claude-agent-sdk`**、**0 处 `ORCA_*` / `CLAUDE_CODE_ENTRYPOINT=orca` / `orca_desktop` 品牌标识残留**。
- [ ] **权限安全门控（v2 改写）**：凡是 Agent 发给 Shepherd 的权限请求，100% 暂停并弹出内联审批条；用户可 `Allow Once`、`Allow Session` 或 `Deny` 并附带文字纠正，拒绝后命令确实未被执行。界面提供的每个权限档位都经过逐驱动验证能够兑现，并写明哪些操作不经过 Shepherd。原「高危命令 100% 暂停」的说法撤回，因为 Shepherd 看不到 Agent 按自身配置直接放行的操作。
- [ ] **三类交互闭环（v2 新增）**：权限确认、问题作答、表单填写各自至少跑通一次真实请求，答案与表单内容能正确回传给 Agent。
- [ ] **外部 IDE 与 PR 闭环**：一键 `⌘O` 成功在 Cursor / Zed / VS Code 中打开对应 Worktree 目录，手改保存后 Diff 实时同步，最终可一键完成 Commit + GitHub PR 创建并安全清理 Worktree（含脏工作区防误删保护与 `scripts.archive` 失败阻断）。
- [ ] **进程清理（v4 改写）**：正常退出（`⌘Q`）或模拟 App 崩溃（`kill -9`）后，分四个场景验证：Agent 所在进程组与会话全部清空；真实 Agent 启动的长时间命令（自成进程组）被清理；被 launchd 收养、但带有进程树标记的后代被清理；经外部 provider 启动的 Agent 及其工具进程被清理。主动清空环境并脱离会话的后代不在覆盖范围内，验收报告需列出未覆盖的情形。
- [ ] **仓库信任门（v3 新增）**：仓库第一次加入时弹出确认，确认前不能在该仓库里启动 Agent 会话；确认后它的所有 Worktree 不再重复弹窗；Shepherd 不为此写入 `~/.claude.json`。
- [ ] **Claude 备用路径（v3 新增）**：`claude-direct` 不可用时，用户改用 `claude-acp` 新开会话可以完成同一任务；界面按能力声明隐藏该 provider 做不到的功能。
- [ ] **会话头部如实显示（v3 新增）**：登录方式与实际生效的权限模式同 Claude 自己报告的一致；环境里有 `ANTHROPIC_API_KEY` 时有一次提示。
- [ ] **全键盘可用**：不依赖鼠标，仅凭键盘快捷键（`⌘N` → 输入 → `⌘⇧A` → `⌘↩` → `⌘⇧D` → `⌘O` → `⌘⇧P`）即可走通完整核心工作流。
