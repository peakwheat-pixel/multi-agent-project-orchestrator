# Multi-Agent Project Orchestrator

> Lean multi-agent project orchestration for coding agents: evidence-first Git state, independent review & integration gates, and automatic orchestrator failover — all with minimal context usage.

一个面向多 Agent 协作的**项目编排 Skill**：当你用 Codex / ZCode / Qoder / Antigravity 等多个 Coding Agent 共同开发同一个 Git 仓库时，它负责重建项目状态、维护任务图（Task Graph）、分配 Owner / Reviewer / Integrator、控制 Review 与 Integration Gate，并自动接力推进——任何一个编排器挂掉，其他 Agent 可以无缝接管。

![version](https://img.shields.io/badge/version-v2.2--lean-blue) ![license](https://img.shields.io/badge/license-MIT-green) ![platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

## 为什么需要它

多 Agent 协作开发常见的问题，这个 Skill 逐一给出约束：

| 痛点 | 本 Skill 的做法 |
| --- | --- |
| Agent 声称"完成了"，但没有证据 | 事实优先级以 **Live Git** 为最高，测试只记录 `command + exit + 摘要 + evidence path`，禁止伪造 PASS/DONE |
| 把整个治理仓库塞进上下文，token 爆炸 | **按需懒加载**：STATUS 不读 reference，REFRESH 只刷新受影响子图，输出默认 delta/ID/path/HEAD |
| 自己写的代码自己审 | 硬约束 **Owner ≠ Independent Reviewer**，Integration Verification 不能替代独立 Review |
| 主编排器（如 Codex）额度耗尽，项目卡死 | **自动故障转移**：按 fallback 顺序选择接管者，FAST_RECOVERY 核验后续跑，恢复后在安全边界回切 |
| 状态漂移、快照与真实仓库不一致 | 冲突标 `STATE_CONFLICT`，未知标 `UNKNOWN / NOT_VERIFIED`，恢复先核验 Live Git |

## 工作原理

### 事实优先级

```
Live Git > committed governance > Task > Delivery/Review/Verification > Status/Plan > Snapshot/Checkpoint > chat
```

Snapshot / Checkpoint 仅仅是缓存；恢复时永远先核验 Live Git。

### 四种模式

| 模式 | 触发场景 | 上下文开销 |
| --- | --- | --- |
| `STATUS` | 查看当前进度 / 阻塞 / Gate / 下一步 | 最低，默认不读 reference |
| `REFRESH` | 事件发生后刷新受影响的 Task 子图 | 只读变化部分 |
| `PLAN` | 构建任务 DAG、Owner/Reviewer、顺序与 Gate | 读 `references/planning.md` |
| `REBASELINE` | 长期中断、多 Agent 漂移、多重冲突时全量重建 | 按需读 planning + governance |

其他事件按需读取：Review/Integration → `references/review-integration.md`；中断/接管 → `references/recovery.md`；外部 Agent 投递 → `references/dispatch.md`。

### 任务状态主链

```
PLANNED → READY → IN_PROGRESS → DELIVERED → IN_REVIEW → APPROVED
        → GATE_READY → INTEGRATING → VERIFYING → DONE
```

异常与等待态：`AWAITING_EXTERNAL_DISPATCH`（无运行时接口的外部 Agent）、`CHANGES_REQUESTED`、`BLOCKED`、`INTEGRATION_BLOCKED`、`HUMAN_REQUIRED`、`STATE_CONFLICT`。

### 角色隔离

- **Owner** 执行 Task Contract，只改 Write Scope，交付 Delivery HEAD。
- **Independent Reviewer** 审查冻结的 Delivery HEAD（未参与实现），结论只能是 `APPROVED | CHANGES_REQUESTED | NOT_VERIFIED | BLOCKED_BY_MISSING_EVIDENCE`。
- **Integrator** 核验 Integration Gate（Reviewed HEAD 匹配、Reviewer 独立、依赖满足、目标 worktree 安全等）后集成并验证。

### 编排器故障转移

```
ORCHESTRATOR_UNAVAILABLE → 按 fallback_order 选择接管者 → ORCHESTRATOR_FAILOVER
                        → FAST_RECOVERY → ORCHESTRATOR_RECOVERY → ACTIVE
```

默认 `codex → zcode → qoder → antigravity`。有可用 fallback 时，**不**因主编排器不可用而进入 `HUMAN_REQUIRED`。主 Orchestrator 恢复后按 `return_policy=primary_at_safe_boundary` 在 Task/Gate 安全边界回切，不中途抢占。

## 目录结构

```
multi-agent-project-orchestrator/
├── SKILL.md                    # 入口：硬约束、路由、上下文预算（保持精简）
├── agents/openai.yaml          # Codex interface 定义（显式调用）
├── references/                 # 懒加载参考文档
│   ├── planning.md             # Task Contract / 状态机 / Task Graph / Executor 策略
│   ├── review-integration.md   # 独立 Review 与 Integration Gate 规则
│   ├── recovery.md             # FAST_RECOVERY / 编排器故障转移
│   ├── governance.md           # 治理漂移检测
│   └── dispatch.md             # Agent 调度与外部投递
├── assets/                     # 模板与紧凑角色 Prompt
│   ├── task-contract.template.yaml
│   ├── orchestration-snapshot.template.yaml   # 只存 ID/state/HEAD
│   ├── checkpoint.template.md
│   ├── status-output.template.md
│   ├── project-policy.default.yaml
│   ├── owner/reviewer/integrator-prompt.compact.md
│   └── external-dispatch.template.md
└── scripts/
    ├── install-skill.ps1       # 安装（默认 ~/.codex/skills/，可 -Destination 覆盖，先备份）
    ├── validate-skill.ps1      # 结构与关键概念校验
    └── audit-git-repo.ps1 / .sh  # 轻量 Git 审计（Windows / Unix）
```

## 安装

### 前置要求

- 一个支持 Agent Skills 的 Coding Agent CLI（Codex CLI / ZCode / Qoder / Antigravity 等）
- Git ≥ 2.x
- Windows 上使用 PowerShell 脚本；其他平台直接手动复制

### 方式一：安装脚本（Windows）

```powershell
git clone https://github.com/peakwheat-pixel/multi-agent-project-orchestrator.git
cd multi-agent-project-orchestrator
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\validate-skill.ps1        # 先校验结构完整性
.\scripts\install-skill.ps1         # 默认安装到 ~/.codex/skills/，自动备份旧版本
```

安装到其他 Agent 的目录：

```powershell
.\scripts\install-skill.ps1 -Destination "$HOME\.agents\skills\multi-agent-project-orchestrator"
```

### 方式二：手动安装（任意平台）

把本仓库放入你的 Agent 的 skills 目录即可：

| CLI | skills 目录 |
| --- | --- |
| Codex CLI | `~/.codex/skills/` |
| ZCode | `~/.agents/skills/` |
| Claude Code | `~/.claude/skills/` |

```bash
git clone https://github.com/peakwheat-pixel/multi-agent-project-orchestrator.git \
  ~/.agents/skills/multi-agent-project-orchestrator
```

## 快速开始

Skill 为显式调用（`allow_implicit_invocation: false`）。在你的项目仓库里直接对 Agent 说：

```
用 multi-agent-project-orchestrator 核验当前项目状态，输出 STATUS。
```

```
用 multi-agent-project-orchestrator 规划剩余工作：构建任务图，分配 Owner/Reviewer，标出 Gate。
```

```
继续推进项目：按 Gate 顺序执行下一批 READY 任务，Review 通过后集成。
```

- 包含"推进 / 继续 / 执行"等明确意图时，建立 `PROJECT_ORCHESTRATION_AUTHORIZATION`，自动接力到真实阻塞为止。
- "只规划 / 只读 / 先分析"则进入 `PLAN_ONLY`，不做任何修改。

## 配置

默认配置见 [`assets/project-policy.default.yaml`](assets/project-policy.default.yaml)，按项目复制修改即可，无需改 SKILL 核心规则：

```yaml
orchestration:
  primary: codex
  fallback_order: [zcode, qoder, antigravity]
  failover_policy: automatic
  return_policy: primary_at_safe_boundary
  recovery_mode: fast_then_rebaseline
executor_policy:
  heavy_task_executor: zcode
  strategy: balanced
```

**Executor 策略**（先过硬过滤：能力 → 角色冲突 → Write Scope → 可用性）：

| 策略 | 行为 |
| --- | --- |
| `BALANCED`（默认） | 上下文连续性与能力优先，heavy 任务提高 `heavy_task_executor` 权重 |
| `ZCODE_HEAVY` | heavy / 全仓库 / 批量任务优先 ZCode |
| `QUALITY_FIRST` | 能力适配优先 |
| `COST_SAVER` | 满足能力后优先低成本 / 额度充足者 |
| `CONTINUITY_FIRST` | 优先已有上下文的合格 Agent |
| `CUSTOM` | 按项目自定义映射 |

**分配优先级**：用户本 Task 指定 > Task policy > 项目 policy > 默认。

## 效率设计（上下文预算）

1. 禁止预加载全部 references/assets；按当前动作读取，通常最多 1 个 reference。
2. 先轻量 Git 扫描（root/branch/HEAD/status，日志 ≤8 条），`diff --name-only` 定位影响面再读文件。
3. Snapshot 只存 ID/state/HEAD，不复制 Contract、Prompt 或证据正文。
4. 自动 dispatch 只传 Task/Contract 路径与 HEAD；仅人工外部投递才展开完整 Prompt。
5. Rolling Checkpoint 只在状态边界（Task start、Delivery、Review、Integration 前后、Done）更新。

## 变更记录

见 [CHANGELOG.md](CHANGELOG.md)。

## License

[MIT](LICENSE)
