# AGENTS.md

## Scope
This repository is the full source-controlled code/config for the Garry's Mod server.

Codex is authorized to inspect and modify ANY tracked file in this repository when required to complete a task, including:
- `garrysmod/addons/`
- `garrysmod/cfg/`
- `garrysmod/lua/`
- `garrysmod/data/` (for debugging, migrations, config repair, or compatibility fixes)
- workflow/deploy files (if needed for deployment/restart fixes)
- UI/HUD/menu files
- trading/unboxing systems
- weapon/damage-related hooks and configs

## Working mode
Use a repo-wide audit-first approach, then implement fixes across related systems in a single coordinated update when requested.

When debugging gameplay issues (damage, UI, networking, trading, inventories), Codex may:
- read logs
- inspect data/config files
- patch Lua across multiple addons
- normalize duplicated hooks
- fix conflicting UI layout code
- update menus/HUD integration code

## Constraints
- Do NOT touch secrets or credentials unless explicitly asked.
- Do NOT commit runtime cache, workshop cache, generated binaries, or logs unless explicitly requested.
- Preserve server-specific behavior where possible, but prioritize fixing broken systems when requested.
- If multiple addons conflict, prefer the fix with the smallest blast radius and document the conflict in the summary.

## Testing expectations
For gameplay fixes, include:
- what changed
- likely root cause
- in-game test steps (exact steps)
- rollback notes (which files to revert)

## Priority systems in this repo
High-priority gameplay systems include:
- weapon damage / PVP damage hooks
- unboxing / case view popups / rewards UI
- trade menu / trading flows
- inventory UI / item actions
- HUD/menu integration
- server monetization hooks (e.g., Prometheus integrations) when relevant
