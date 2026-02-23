# AGENTS.md — Codex rules for this GMod server repo

## Mission
This repository is the source of truth for a production Garry's Mod server (DarkRP on Physgun).
Make safe, maintainable, performance-conscious changes that improve gameplay, stability, and admin operations.

## Default editable paths
Codex may edit these by default:
- `garrysmod/addons/**`
- `garrysmod/cfg/**`
- `garrysmod/lua/**`

## Debug-readable paths (read anytime)
Codex may inspect these for debugging/investigation:
- `garrysmod/data/**`
- `garrysmod/logs/**`
- `garrysmod/clientside_errors.txt`

## Conditionally editable paths
Codex may modify these ONLY when the task explicitly requires it, and the PR explains why:
- `garrysmod/data/**` (config/data migrations, seeded defaults, data-driven addon config)

## Generally do not edit unless explicitly requested
- `garrysmod/cache/**`
- `garrysmod/download/**`
- `garrysmod/downloads/**`
- `garrysmod/html/**`
- `garrysmod/temp/**`
- generated runtime files, binary caches, secrets/license files

## Safety rules
- Do not add malicious code, backdoors, hidden admin bypasses, credential logging, or anti-user code.
- Do not make anti-cheat evasion or exploit code.
- Keep diffs minimal and scoped to the requested task.

## Performance standards (GMod/Lua)
- Avoid heavy work in `Think` hooks unless necessary.
- Avoid net message spam and repeated expensive calls.
- Prefer clean hook/timer lifecycle management.
- Preserve behavior unless the task asks for behavior changes.

## PR requirements
Every PR should include:
1. What changed
2. Why it changed
3. Risks / side effects
4. In-game testing steps
5. Rollback notes (if applicable)

## Deployment awareness
- GitHub Actions deploys to Physgun after merge to `main`.
- Deploy target is `/garrysmod/`.
- CI may deploy only changed files.
- Avoid noisy/runtime changes unless explicitly required.
