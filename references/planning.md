# Planning / Scheduling / Executor Policy

仅用于 PLAN、REBASELINE 或需要重新分配 Executor 时。

## 最小 Task Contract
READY 前只要求：`id,title,state,owner,reviewer,integrator,deps,write_scope,acceptance,tests,delivery_head,reviewed_head,review_decision,integration_target,integration_status,dispatch_state,profile`。
按需字段：blocked_by/read_scope/forbidden_scope/evidence/checkpoint/handoff/risk。不要为空字段制造长模板。

状态主链：
`PLANNED → READY → IN_PROGRESS → DELIVERED → IN_REVIEW → APPROVED → GATE_READY → INTEGRATING → VERIFYING → DONE`
外部不可调用：`AWAITING_EXTERNAL_DISPATCH`；失败/阻塞：`CHANGES_REQUESTED/BLOCKED/INTEGRATION_BLOCKED/HUMAN_REQUIRED/STATE_CONFLICT`。

## Task Graph
只保存/输出 Task ID、依赖、状态、Owner、Reviewer、Write Scope、Gate。远期未知用 `PLANNED_PLACEHOLDER`。Startup Order 与 Integration Order 分开；共享主线/Schema/协议或 Write Scope 冲突必须串行。默认 Single-Agent-First，仅真实独立且有收益时并行。

## Executor
硬过滤：能力 → 角色冲突 → Write Scope/worktree → 可用性。随后应用：
- `BALANCED`：上下文连续性与能力优先；heavy 提高 `heavy_task_executor` 权重；再考虑成本/迁移代价。
- `ZCODE_HEAVY`：heavy/repository-wide/bulk 优先 ZCode。
- `QUALITY_FIRST`：能力适配优先。
- `COST_SAVER`：满足能力后优先低成本/额度充足者。
- `CONTINUITY_FIRST`：优先已有上下文的合格 Agent。
- `CUSTOM`：按项目映射。

默认 `heavy_task_executor=zcode`，非硬绑定。无需常规输出评分/候选列表；仅非默认选择、冲突或用户询问时解释。

Orchestrator 与 Executor 分开配置；Orchestrator failover 不改变 Executor policy。Task 的 integrator 在 GATE_READY 前绑定到当前合格 Integrator，禁止依赖模板里写死的 Agent。

## 刷新
Delivery、Review、Integration、Verification、Checkpoint、Blocker/Dependency/Main HEAD 变化后只重算受影响子图、queues、critical path、next task/executor/reviewer/gate。
