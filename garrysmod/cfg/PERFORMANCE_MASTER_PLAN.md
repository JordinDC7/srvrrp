# Server Performance Master Plan (DarkRP / Physgun)

This document is a practical, execution-ready plan to make server performance fast and stable under high player load.

## 1) Success Criteria (define “smoothest server”)

Set hard targets first so every optimization can be measured:

### Core server targets
- **Tick stability:** 95th percentile server frame time remains stable during peak load; no sustained hitching.
- **Lag spikes:** No periodic freezes above acceptable threshold during combat/events.
- **Player experience:** Minimal rubber-banding, delayed weapon fire, or delayed prop interaction.
- **Crash resilience:** No crash loops during peak concurrency.
- **Join performance:** Fast initial spawn and low first-minute stutter.

### Operational targets
- Reliable restart windows and graceful map change behavior.
- Predictable resource usage trend by player count.
- Actionable monitoring/alerts before players notice degradation.

---

## 2) Baseline & Instrumentation (Week 1)

You cannot optimize what you don’t measure. Build a baseline first.

### Baseline capture sessions
Run 3 controlled test windows:
1. Low load (5–10 players)
2. Mid load (20–30 players)
3. Peak-like load (40+ players / bots / scripted simulation)

Capture for each:
- Server FPS and frame-time distribution over 30+ minutes.
- CPU and RAM usage trend.
- Entity count trend and entity class distribution.
- Net message volume/frequency by message name.
- Top slow hooks/timers with average and max execution time.
- Map-dependent hotspots (spawn areas, printer-heavy zones, event hotspots).

### Add lightweight profiling helpers
- Enable profiling toggles via cvars/concommands so instrumentation can be turned on/off without code edits.
- Record hook runtime summaries (Think, PlayerTick, EntityTakeDamage, net handlers, DarkRP periodic hooks).
- Record timer callback durations and frequency.
- Track net messages per-player and globally.
- Persist summarized snapshots for comparison between builds.

### Deliverables
- “Known bottlenecks” list ranked by impact.
- “Safe quick wins” list (low-risk, immediate improvements).
- Performance dashboard/checklist used before deployment.

---

## 3) High-Impact Optimization Workstreams (Weeks 2–6)

## A) Lua hot-path cleanup (highest ROI)

Focus on frequently-called code paths first.

### Priorities
- Reduce work in `Think`/`Tick` hooks.
- Replace polling with event-driven hooks where possible.
- Cache repeated expensive lookups.
- Avoid repeated `player.GetAll()` loops in tight intervals.
- Throttle or batch recurring logic that does not need per-tick precision.

### Patterns to apply
- Early returns for invalid entities/players.
- Localize globals in hot loops.
- Move one-time setup out of runtime loops.
- Use timer intervals appropriate to gameplay sensitivity.
- Deduplicate overlapping hooks from multiple addons.

## B) Netcode and message pressure control

### Goals
- Reduce bandwidth and net handler CPU cost.
- Prevent net spam from chat/UI/status updates.

### Actions
- Audit all custom net channels and rank by frequency/size.
- Coalesce frequent tiny updates into batched payloads.
- Send delta updates instead of full-state re-sends.
- Add server-side rate limits for non-critical client requests.
- Restrict broadcast scope (`net.Send` to relevant players only).

## C) Entity and physics budget control

### Goals
- Prevent entity overload and physics storms during peak play.

### Actions
- Audit persistent/spawned entities by class.
- Cap or soft-limit expensive entities (printers, ragdolls, props, effects).
- Add cleanup/decay rules for abandoned entities.
- Review collision groups and physics settings for non-critical props.
- Ensure scripted entities do not run unnecessary per-tick logic.

## D) Addon rationalization

### Goals
- Keep only value-producing addons and disable expensive overlap.

### Actions
- Inventory all addons with owner/purpose/status.
- Measure per-addon hook/timer/net footprint.
- Remove duplicates/legacy code.
- Gate optional features behind cvars.
- Standardize load order for compatibility and reduced initialization spikes.

## E) Database/storage optimization (if used by addons)

### Goals
- Remove stutter caused by blocking or bursty DB activity.

### Actions
- Audit DB calls in gameplay hooks.
- Ensure asynchronous DB usage where possible.
- Batch writes for non-critical stats/logging.
- Add indexes for frequent query patterns.
- Add backoff/retry strategy to avoid DB outage cascades.

---

## 4) Configuration & Runtime Tuning (parallel)

Tune server cvars and startup/runtime settings based on measured behavior.

### CPU/frame consistency
- Validate tick-related settings against desired gameplay feel.
- Tune networking rates conservatively with stability first.
- Avoid over-aggressive values that increase CPU overhead without real gain.

### Memory and garbage behavior
- Monitor memory growth over long uptime windows.
- Identify Lua allocation hotspots and temporary table churn.
- Reduce avoidable allocation in hot paths.

### Restart hygiene
- Move to predictable maintenance/restart cadence informed by memory and performance trends.
- Add pre-restart warnings and graceful transitions.

---

## 5) Map & Content Strategy

### Map performance pass
- Profile peak hotspots (spawn, PD, market areas, event zones).
- Reduce expensive dynamic lighting/effects in high-traffic zones.
- Review prop density and physics-heavy map interactions.

### Workshop/download impact
- Minimize unnecessary client downloads.
- Remove oversized or unused assets from server collections.
- Improve first-join experience by pruning non-essential content.

---

## 6) Scalability Controls for High Population

When population rises, enable adaptive load controls.

### Progressive degradation (graceful, not painful)
- Reduce cosmetic effect frequency at high server load.
- Temporarily lengthen intervals for non-critical background systems.
- Prioritize combat/movement/input responsiveness over cosmetic updates.

### Protective guardrails
- Rate-limit exploitable spam actions (commands/net usage/entity spam).
- Auto-cleanup when entity/physics thresholds exceed safe limits.
- Alert admins when approaching critical load conditions.

---

## 7) Reliability & Operations

### Monitoring/alerting
- Build a simple on-server metrics heartbeat (frame time, player count, entity count, net throughput, memory).
- Trigger alerts for sustained degradation (not one-off spikes).

### Incident playbooks
Create runbooks for:
- Severe lag spike triage.
- Net spam incident.
- Physics meltdown.
- DB slowdown.
- Post-update regression rollback.

### Rollback readiness
- Keep performance-related changes small and reversible.
- Maintain known-good config snapshots.
- Fast disable flags for risky optimizations.

---

## 8) Testing Protocol (must-pass before production)

### Pre-merge performance gate
For every substantial gameplay/addon change:
- Run scripted load test with representative player actions.
- Compare against baseline thresholds.
- Reject or revise changes that regress key metrics.

### In-game validation checklist
- Join/spawn smoothness.
- Combat responsiveness under load.
- Job switching, doors, economy actions, inventory interactions.
- Prop spawning/cleanup behavior.
- Admin tools and moderation flows under stress.

### Soak testing
- Multi-hour uptime test with simulated activity.
- Watch for memory leak patterns and late-onset hitching.

---

## 9) Suggested Implementation Timeline

### Phase 0 (Days 1–3)
- Baseline metrics and instrumentation.
- Bottleneck ranking and quick-win shortlist.

### Phase 1 (Week 1–2)
- Fix top 20% hot-path offenders (hooks/timers/net spam).
- Add protective rate limits and entity guardrails.

### Phase 2 (Week 3–4)
- Addon consolidation and map hotspot tuning.
- DB/storage optimization pass.

### Phase 3 (Week 5+)
- Adaptive load controls and long-soak reliability hardening.
- CI/performance regression checks integrated into normal workflow.

---

## 10) Ownership & Governance

Assign clear owners:
- **Performance lead:** prioritization and acceptance criteria.
- **Addon owners:** module-level optimization accountability.
- **Ops/admin owner:** monitoring, alerts, incident handling.

Define recurring rituals:
- Weekly performance review with trend charts.
- “No regression” policy for merges.
- Monthly addon pruning and cleanup day.

---

## 11) Quick Wins You Can Start Immediately

1. Audit and reduce heavy `Think` logic.
2. Batch/throttle high-frequency net messages.
3. Add entity cleanup for abandoned props/ragdolls/printers.
4. Disable or gate non-essential cosmetic effects during peak.
5. Remove duplicate/unused addons.
6. Add basic live metrics + alert thresholds.

These six steps typically produce a noticeable improvement quickly while larger refactors are planned.

---

## 12) Execution Status Tracker (Repository Scope)

This tracker reflects what has been implemented directly in this repository versus what still requires live server operations, player load testing, or admin process rollout.

### Implemented in repository (automation/config scaffolding)
- ✅ Lightweight heartbeat snapshots with frame/entity/net/timer summaries.
- ✅ Snapshot persistence and recent history dump commands.
- ✅ Net budget registration and usage warning diagnostics for SRVRRP channels.
- ✅ Prop burst rate-limit guardrail for non-admin players.
- ✅ Optional ragdoll cleanup scheduler (disabled by default).
- ✅ UI telemetry event aggregation heartbeat.
- ✅ Hook runtime monitor toggle (`srvrrp_perf_hook_monitor_enabled`) for profiling passes.
- ✅ Adaptive load state signaling (`srvrrp_adaptive_high_load`) with enter/recover thresholds.
- ✅ Tunable defaults in `srvrrp_performance.cfg` for monitor/guardrail/adaptive controls.

### Still required (ops + in-game execution)
- ⏳ Run formal low/mid/peak baseline sessions and archive results.
- ⏳ Publish ranked bottleneck report from live traces and hook/net/timer summaries.
- ⏳ Enforce pre-merge load-test gate and no-regression acceptance policy.
- ⏳ Complete addon inventory/rationalization with owner assignment.
- ⏳ Execute map hotspot tuning passes on active production maps.
- ⏳ Establish alert routing and incident runbooks in admin operations.
- ⏳ Validate + enable ragdoll cleanup in production after staged soak verification.
- ⏳ Finalize numeric SLO thresholds for frame-time, entity budget, and join performance.

