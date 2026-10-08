# Changelog

## v2.2 Lean（2026-10-08 首次公开发布）

以"最小上下文 + 无单点编排器"为目标的重构版本。

### 核心

- **Lean 上下文预算**：SKILL.md 只保留硬约束、路由与预算规则（< 7000 字符）；references 按事件懒加载，STATUS 默认不读 reference，REFRESH 只刷新受影响 Task 子图。
- **编排器故障转移**：默认 `codex → zcode → qoder → antigravity`；主 Orchestrator 不可用时按 `ORCHESTRATOR_UNAVAILABLE → FAILOVER → FAST_RECOVERY → RECOVERY → ACTIVE` 自动接管，恢复后按 `primary_at_safe_boundary` 回切。
- **证据优先级**固化：`Live Git > committed governance > Task > Delivery/Review/Verification > Status/Plan > Snapshot/Checkpoint > chat`；冲突标 `STATE_CONFLICT`，未知标 `UNKNOWN / NOT_VERIFIED / NOT_ASSIGNED`。
- **角色隔离**：`Owner != Independent Reviewer` 硬约束；Integration Verification 不能替代 Independent Review。

### 结构

- Task Contract 最小化（READY 前仅 16 个必填字段，按需扩展）。
- Snapshot 只存 ID/state/HEAD；Rolling Checkpoint 只在状态边界更新。
- 自动 dispatch 只传 Task 路径 + HEAD；人工外部投递才展开完整 Prompt。
- Executor 策略：`BALANCED / ZCODE_HEAVY / QUALITY_FIRST / COST_SAVER / CONTINUITY_FIRST / CUSTOM`。

### 工具

- `scripts/validate-skill.ps1`：结构与关键概念校验（含 SKILL 长度上限 7000 字符）。
- `scripts/install-skill.ps1`：安全安装，默认备份旧版本。
- `scripts/audit-git-repo.ps1 / .sh`：跨平台轻量 Git 审计。

### 其他

- 新增面向 GitHub 的 README、MIT LICENSE、CHANGELOG。
