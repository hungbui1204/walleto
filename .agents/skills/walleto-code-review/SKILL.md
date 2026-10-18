---
name: walleto-code-review
description: Review a Walleto Flutter diff, commit, pull request, or completed coding task for concrete regressions and violations of project rules. Use for explicit code review and the final self-review of an implementation; standalone reviews are read-only.
---

# Walleto code review

Review the change against its intended behavior and the repository's own rules. Read `CLAUDE.md`, `AGENTS.md`, and the relevant parts of `CODING_RULES.md` first. Repository instructions take precedence over this skill and external sources.

## Scope and evidence

1. Establish what is being reviewed: a user-specified PR or commit range, the current working tree, or the implementation just completed. Read the task or `docs/requirements/` when relevant. Include untracked files that belong to the requested change; leave unrelated user files alone.
2. Inspect the diff and the code needed to trace changed behavior: callers, use cases, repository methods, mappers, BLoCs, views, configuration, and corresponding tests. For a navigable screen, trace `AppRouter` → `AppRouteInfo` → `AppRouteInfoMapper`; for an overlay, trace `AppPopupInfo` and its mapper. For a PR, use `gh pr view` and `gh pr diff`; do not post a review or comment unless the user asks.
3. Prioritize incorrect money amounts or transactions, data loss, auth/privacy exposure, crashes, async races, lifecycle errors, broken navigation, and missing regression coverage. For changed UI, inspect its actual loading/empty/error branches, light/dark palette use, text scaling, keyboard/layout behavior, semantics and reachable tap targets when relevant; do not demand a full accessibility audit for an unrelated diff. Check project conventions where the changed code makes them relevant. Use `walleto-bloc-check` for a substantial BLoC or layer change and `walleto-security-review` for a security-sensitive change.
4. Run applicable read-only checks permitted by `AGENTS.md`, such as `make analyze` and `make testing`, when their result can validate a claim. Distinguish an unrun check from a passing one. Review generated output only as context; never edit generated files during a review.

## Challenge the review

Before reporting an issue, verify the failure path against guards, callers, package versions, tests, and Flutter behavior. Report problems introduced or exposed by the change, with a tight location in changed code. Do not fill the report with praise, style preferences, hypothetical rewrites, or unrelated legacy defects. Deduplicate overlapping findings.

For each finding give severity, `path:line`, the triggering condition, user or delivery impact, supporting evidence, and a proportionate fix. Order findings by severity. If there are no actionable findings, say so and mention meaningful verification gaps.

## Permissions

A standalone Review Agent is read-only: no edits, codegen, commit, push, PR review submission, approval, or merge. During an authorized coding task, the Code Agent may use this skill for self-review and fix findings within the original task scope, then rerun focused checks.

## Sources adapted for Walleto

- [Flutter Code Review](https://github.com/thienqo/flutter-skills/blob/main/skills/flutter-code-review/SKILL.md)
- [Code Review workflow in Flutter Agent Plugins](https://github.com/flutter/agent-plugins/blob/main/.agents/agents/reidbaker-agent/skills/code-review/SKILL.md)
