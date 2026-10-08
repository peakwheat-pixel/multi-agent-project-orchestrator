# Governance Drift

仅当 fingerprint/HEAD/规则文件变化或证据冲突时读取治理正文；未变则复用已核验摘要。
检查：逐 Task 重复授权、Owner 自审、Integration Verification 代 Review、DONE 仅靠文本、Prompt=已启动、Checkpoint 覆盖 Git、固定某 Agent 承担所有复杂任务。
允许修改时迁移到 Project Authorization、Executor Policy、Role Separation、Evidence Gate、Auto Continuation、Recovery。项目更高优先级规则冲突时标 `GOVERNANCE_CONFLICT`，不静默覆盖。
