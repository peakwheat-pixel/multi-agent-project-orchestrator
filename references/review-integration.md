# Review & Integration

## Independent Review
Reviewer 必须独立且未参与被审实现/修复。Review 绑定 `Task ID + frozen Delivery HEAD + acceptance/tests/evidence`。
允许结论：`APPROVED | CHANGES_REQUESTED | NOT_VERIFIED | BLOCKED_BY_MISSING_EVIDENCE`。
Review 先看 commit/diff 与相关测试；不要全库扫描。需要修复则回 Owner，产生新 Delivery HEAD 后重审。

## Integration Gate
仅核验：Contract 可定位；Delivery HEAD 可读；Reviewed HEAD 匹配；Reviewer 独立；Review 准入；必要测试/证据新鲜；依赖满足；目标 HEAD/worktree 安全；无未解 STATE_CONFLICT。
通过：`GATE_READY → INTEGRATING → INTEGRATED → VERIFYING → DONE`。
Integration Verification 只验证集成结果，不替代 Independent Review。
失败进入 `INTEGRATION_BLOCKED`，不得为过 Gate 偷改冻结交付。
