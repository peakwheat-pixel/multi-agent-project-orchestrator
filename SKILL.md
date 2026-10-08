---
name: multi-agent-project-orchestrator
description: 以最小上下文基于 Git 证据重建多 Agent 项目状态、维护 Task Graph、分配 Owner/Reviewer、控制 Review/Integration Gate 并持续接力；支持编排器故障转移。默认 BALANCED，重任务优先 ZCode。
---

# Multi-Agent Project Orchestrator — Lean

目标：**证据优先、按需读取、差量刷新、自动接力、无单点编排器**。不要把整个治理仓库塞入上下文。

## 默认策略
`primary_orchestrator=codex · fallback=zcode,qoder,antigravity · return_policy=primary_at_safe_boundary · strategy=balanced · heavy_task_executor=zcode`
均可由项目配置或用户覆盖；Task 分配优先级：`用户本 Task 指定 > Task policy > 项目 policy > 默认`。

## 硬约束
- 事实优先级：`Live Git > committed governance > Task > Delivery/Review/Verification > Status/Plan > Snapshot/Checkpoint > chat`。
- 冲突标 `STATE_CONFLICT`；未知标 `UNKNOWN/NOT_VERIFIED/NOT_ASSIGNED`，禁止猜测。
- `Owner != Independent Reviewer`；Integration Verification 不能替代 Independent Review。
- Snapshot/Checkpoint 仅缓存；恢复先核验 Live Git。
- 不伪造 Agent、测试、Review、PASS/DONE；不擅自 reset/clean/stash/覆盖未知改动。

## 上下文预算（必须执行）
1. **禁止预加载全部 references/assets。** 仅按当前动作读取；通常最多 1 个 reference，REBASELINE 有治理漂移时最多 2 个。
2. 先轻量 Git 扫描：root/branch/HEAD/status/worktree/recent commits；日志默认 ≤8 条。
3. 先 `diff --name-only`/Task ID/HEAD 定位影响面，再读相关文件或 diff；不全库通读。
4. Snapshot 新鲜且 governance fingerprint 未变时，不重读未变治理文档。
5. 测试只记录 `command + exit + 摘要 + evidence path`；仅失败/争议时展开日志。
6. 输出默认 **delta/ID/path/HEAD**；不重复粘贴 Contract、Graph、Prompt 或证据正文。
7. 能自动 dispatch 时只传 Task/Contract 路径与 HEAD；仅人工外部投递时展开完整 Prompt。
8. 信息不足时逐级扩展；恢复优先 `FAST_RECOVERY`，发现冲突才 REBASELINE。

## 模式
- `STATUS`：只读；轻量核验后输出当前/阻塞/Gate/下一步。**默认不读 reference。**
- `REFRESH`：只刷新事件影响的 Task 子图；影响范围不安全才升级 REBASELINE。
- `PLAN`：构建当前已知 DAG、Owner/Reviewer、顺序与 Gate；读 `references/planning.md`。
- `REBASELINE`：仅长期中断、多 Agent 漂移、Snapshot 失效或多重冲突时全量重建；读 `references/planning.md`，仅治理漂移再读 `references/governance.md`。

事件按需读取：Review/Integration → `references/review-integration.md`；中断、Orchestrator 不可用或接管 → `references/recovery.md`；外部 Agent → `references/dispatch.md`。无直接调用接口时使用 `AWAITING_EXTERNAL_DISPATCH`。

## 授权、接力与故障转移
用户明确要求推进/继续/重规划/执行项目时建立 `PROJECT_ORCHESTRATION_AUTHORIZATION`；“只规划/只读/先分析/暂不修改”则 `PLAN_ONLY`。

有授权且非 PLAN_ONLY：`Delivery → Review → Gate → Integration → Verify → REFRESH → 下一 READY Task` 自动继续。只有凭据/权限、不可逆操作、项目规定人工批准、重大未解冲突、需求取舍、越界或必须人工投递外部 Agent 时使用 `HUMAN_REQUIRED`。

当前 Orchestrator 不可用/额度耗尽时，不因其本身进入 HUMAN_REQUIRED：按 `fallback_order` 选择可用接管者，状态 `ORCHESTRATOR_UNAVAILABLE → ORCHESTRATOR_FAILOVER → ORCHESTRATOR_RECOVERY → ACTIVE`。接管者先 `FAST_RECOVERY`，只核验 Git、Active Task、Checkpoint/Snapshot 与相关 Delivery/Review；一致则续跑，冲突才 REBASELINE。主 Orchestrator 恢复后仅在 Task/Gate 安全边界按 `return_policy` 回切，不中途抢占。

为降低恢复成本，仅在**状态边界**维护最小 Rolling Checkpoint（如 Task start、Delivery、Review、Integration 前后、Done）；不要按工具调用频率写 Checkpoint。

## 输出
- STATUS：Repository@HEAD、Orchestrator、Active、Review/Integration、Blocked/Conflict、Next Task/Executor/Gate、Human（若有）。
- REFRESH：只报**变化 + 新阻塞/解锁 + 下一步**。
- PLAN/REBASELINE：Graph 用 ID/依赖/Owner/状态摘要，不内联完整 Contract。
- Task 完成：简报结果/HEAD/测试/Review/Integration/下一 Task；自动继续不回显完整下一 Prompt，人工投递才用 `assets/external-dispatch.template.md`。
