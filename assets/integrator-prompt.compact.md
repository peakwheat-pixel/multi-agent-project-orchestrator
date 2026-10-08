INTEGRATE {{TASK_ID}}
Contract: {{TASK_PATH}} | Delivery: {{DELIVERY_HEAD}} | Review: {{REVIEW_REF}}
核验 Gate（HEAD/独立 Review/测试/依赖/target/worktree/conflict）；满足则集成并验证。返回 integration HEAD、verification summary、unlocked tasks；不满足只报缺失项。
