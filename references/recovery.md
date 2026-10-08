# Recovery / Orchestrator Failover

Checkpoint 最小记录：`task,agent,orchestrator,worktree,branch,base_head,current_head,state,dirty_files,done,remaining,tests,next_action`。
只在状态边界更新 Rolling Checkpoint；避免按工具调用或细碎修改频繁写入。

## FAST_RECOVERY
默认恢复路径：轻量 Git 审计 → 核验 Active Task/对象存在 → 比对 Checkpoint/Snapshot → 核验相关 Delivery/Review/Contract → 续跑原 Task。
只读受影响对象；一致时禁止全库 REBASELINE。发现 HEAD/治理/Task/证据冲突且无法局部消解时才升级 REBASELINE。

`Live Git > Checkpoint/Snapshot`。未知改动标 `PRE_EXISTING_WORKTREE_CHANGE`；归属不明标 `OWNERSHIP_UNVERIFIED`。

## Orchestrator Failover
当前 Orchestrator 因额度、不可用或会话中断无法继续：
`ORCHESTRATOR_UNAVAILABLE → 按 fallback_order 选择可用者 → ORCHESTRATOR_FAILOVER → FAST_RECOVERY → ORCHESTRATOR_RECOVERY → ACTIVE`。
有可用 fallback 时不得仅因主 Orchestrator 不可用标 HUMAN_REQUIRED。无法自动调用 fallback 时按外部 dispatch 处理。

接管不豁免角色隔离：接管者若是 Owner，不能成为该 Delivery 的 Independent Reviewer。
主 Orchestrator 恢复时按 `return_policy` 在 Task/Gate 安全边界回切；不在 IN_PROGRESS/IN_REVIEW/INTEGRATING 中途抢占。

禁止自动 reset --hard、clean、stash、覆盖式 checkout 或删除未知 worktree。
