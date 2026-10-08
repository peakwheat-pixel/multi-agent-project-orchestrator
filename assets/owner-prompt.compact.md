OWNER {{TASK_ID}}
Repo/worktree: {{REPO_WORKTREE}}
Base: {{BASE_HEAD}}
Contract: {{TASK_PATH}}
执行 Contract，仅修改 Write Scope；保护未知改动；完成后返回 Delivery HEAD、changed files、test summary/evidence path、risk。中断返回 checkpoint。你不是 Independent Reviewer。
