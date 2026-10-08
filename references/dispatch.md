# Dispatch

当前环境有真实 runtime/API 才能标 `IN_PROGRESS`。
无接口：`AWAITING_EXTERNAL_DISPATCH`，使用完整外部投递模板。

共享同一仓库时，Owner/Reviewer/Integrator Prompt 默认只传：`role, task_id, task_path, repo/worktree, base/delivery HEAD, scope, required action, return fields`；Agent 自行读取 Task Contract，避免重复内联。
只有目标 Agent 无法访问共享 Task 文件时才内联 Contract/Acceptance/Tests/Evidence。
收到外部返回后先核验 Git/HEAD/evidence，再更新状态；不直接相信自然语言“完成/PASS”。
