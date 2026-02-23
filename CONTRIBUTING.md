# Contributing

## Scope
This repo is the source-controlled code/config for a Garry's Mod server.
Do not commit runtime/cache/log/generated files unless explicitly intended.

## Preferred editable areas
- `garrysmod/addons/`
- `garrysmod/cfg/`
- `garrysmod/lua/`

## Data and logs policy
- `garrysmod/data/` may be read for debugging and may be edited only for explicit data/config migration tasks.
- Logs may be read for debugging, but log files generally should not be committed.

## Change style
- Small, scoped PRs are preferred.
- Preserve behavior unless the task requires changing behavior.
- Document risks and in-game testing steps.
