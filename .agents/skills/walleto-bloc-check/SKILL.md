---
name: walleto-bloc-check
description: Check a Walleto Flutter feature or diff that changes BLoC, use cases, repository mapping, or UI-to-domain boundaries. Use during implementation self-review or an explicit architecture/BLoC review; preserve Walleto's existing structure.
---

# Walleto BLoC and architecture check

Read `CLAUDE.md` and `CODING_RULES.md` §§1, 4–7, 10–12, and 15. Inspect the adjacent feature before evaluating a pattern. This skill checks the architecture already chosen by Walleto; it does not authorize a migration to package-per-feature modules, new repository interfaces, or a different state-management library.

Trace one changed user flow from the view to its BLoC, use case, `Repository` interface, `RepositoryImpl`, mapper/API, and back to the rendered state. Check only boundaries the change touches:

- `ui → domain ← data`: UI calls use cases through BLoC and never imports `data/` or invokes API/repository directly. Data models stay inside data; domain exposes entities.
- Walleto keeps one `Repository` interface unless the user explicitly requests a split. Public files use the project's barrels; DI follows existing `get_it`/`injectable` conventions.
- Async BLoC handlers use `runBlocCatching`; event registrations use `transformer: log()`. `BlocBuilder`, `BlocListener`, and `BlocConsumer` use the applicable `buildWhen`/`listenWhen`. Check that navigation and one-shot effects do not fire from rebuilds.
- State ownership, subscriptions, disposals, repeated events, and error/loading transitions behave correctly under retries and page disposal. Do not flag every local `setState` without a concrete bug or a Walleto rule violation.
- New or fixed logic has meaningful tests in the mirrored `test/` path: use case and BLoC behavior, plus mapper/service logic when present. Verify happy path and the relevant error/edge path.

In a standalone review, report evidence-backed findings using `path:line` and do not edit files. During implementation, fix only issues in the authorized task scope and run the repository's focused verification commands.

## Source adapted for Walleto

- [Flutter Modular Clean BLoC App](https://github.com/quangDecember/flutter-agent-skills/blob/main/skills/flutter-modular-clean-bloc-app/SKILL.md)
