---
name: walleto-security-review
description: Audit a Walleto Flutter change or bounded feature for concrete mobile security and privacy risks in auth, financial data, storage, logging, networking, deep links, platform settings, or dependencies. Use for explicit security review or a security-sensitive coding change; review mode is read-only.
---

# Walleto security review

Read `CLAUDE.md`, `AGENTS.md`, and relevant `CODING_RULES.md` sections before reviewing. Use the current [OWASP MASVS](https://mas.owasp.org/MASVS/) and [MAS Checklist](https://devguide.owasp.org/en/04-design/03-mas-checklist/) as control and test references, selecting only controls relevant to the changed surface.

## Review the reachable risk

1. Identify the asset at risk, entry point, trust boundary, supported flavor/platform, and plausible attacker action. Trace the actual path through UI, domain, data, Supabase, local storage, and native configuration as relevant.
2. Check authorization and financial operations on the trusted backend; the mobile client and bundled `env/` values are inspectable. Distinguish public client identifiers from true secrets using the provider's contract. Never assume client-side validation or obfuscation enforces authorization.
3. Inspect relevant token/session handling, secure versus ordinary preferences, logout cleanup, sensitive values in logs or analytics, HTTPS exceptions, deep links, WebViews, exported platform components, backup and screenshot behavior, and changed dependencies. Read `pubspec.lock`, `android/`, or `ios/` only when the change or threat requires them.
4. Verify each suspected weakness with code/config evidence and an attack precondition. Dependency scanners and text searches are leads, not proof. Missing certificate pinning, root detection, or obfuscation alone is not a vulnerability without a documented threat and requirement.

Report confirmed findings separately from defense-in-depth suggestions and unresolved questions. Each finding needs severity, `path:line`, protected asset, reachable attack path, impact, evidence, and a proportionate remedy. State what was and was not verified; a clean static review does not prove the app secure.

For a standalone review, obey the Review Agent's read-only permissions: do not edit, run codegen, probe live systems, rotate keys, post PR comments, or change production settings. In an authorized implementation task, return findings to the Code Agent for fixes within its permitted scope; native changes remain under the Platform Agent scope.

## Sources adapted for Walleto

- [Flutter Security](https://github.com/thienqo/flutter-skills/blob/main/skills/flutter-security/SKILL.md)
- [OWASP MASVS](https://mas.owasp.org/MASVS/)
