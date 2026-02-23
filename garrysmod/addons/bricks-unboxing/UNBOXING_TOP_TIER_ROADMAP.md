# Top-Tier Unboxing System Roadmap (DarkRP / Physgun)

## Status Snapshot
- **Owner:** Gameplay/Economy team
- **Document status:** Completed and implementation-ready
- **Delivery horizon:** 3 phases over 8-12 weeks, then ongoing LiveOps
- **Primary success targets:**
  - D7 retention uplift from unboxing participants: **+8-12%**
  - Duplicate frustration ("bad session" reports): **-30%**
  - Economy stability (apex median volatility): **<15% weekly swing**

---

## 1) Vision and Product Pillars

### Vision
Build an unboxing ecosystem that feels **fair, exciting, social, and progression-driven** so players always have a reason to return.

### Product Pillars
1. **Feel great every session** (opening ceremony, near-miss pacing, high quality feedback).
2. **Long-term progression** (mastery tracks, collections, pity systems, milestones).
3. **Healthy economy** (crafting sinks, marketplace integrity, anti-inflation controls).
4. **Social prestige** (showcases, flex moments, gang goals, event races).
5. **Trust and fairness** (clear odds policy, transparent safety valves, exploit resistance).

---

## 2) Scope: What We Are Building

### A. Core Reward Loop (Required)
- 3-layer reward structure:
  - **Micro rewards:** commons/tokens/scrap/XP
  - **Mid rewards:** collection pieces/craft materials/themed cosmetics
  - **Apex rewards:** ultra-rare animated/stat-tracked drops
- Server-authoritative pity system by case family:
  - Soft pity ramp after threshold
  - Hard pity guarantee by cap
  - UI indicator for current pity progress
- Duplicate utility:
  - Duplicate -> fragments (scaled by rarity)
  - Fragment crafting toward deterministic item targets
  - Optional reroll station (fragments + sink fee)

### B. Meta Progression (Required)
- Permanent **Unboxing Mastery Pass**
- **Collection Album** with completion progress + rewards
- Seasonal chapter framework (8-12 weeks): themed pool, challenges, seasonal currency behavior

### C. Social + Economy (Required)
- Curated global hype feed for high-tier drops only
- Gang objectives + leaderboard support
- Listing/crafting/reroll sinks and economy diagnostics
- Admin safety tools: kill switches, anomaly alerts, logs

### D. Stretch Goals (Optional after stable launch)
- Narrative collections and lore unlocks
- Skill-coupled cosmetic variants
- Server-wide community milestone unlocks
- Creator spotlight collections

---

## 3) Implementation Plan (Execution-Ready)

## Phase 1 (Weeks 1-3): Foundation
**Goal:** Make every opening session feel rewarding and transparent.

### Deliverables
- [ ] Add per-case-family pity counters (server-side only)
- [ ] Add soft/hard pity tuning values in config
- [ ] Add duplicate -> fragment conversion in reward pipeline
- [ ] Add deterministic fragment crafting endpoint
- [ ] Expose pity state, fragment gain, and progression deltas in UI
- [ ] Add telemetry events for open result, pity depth, duplicate conversion

### Exit Criteria
- [ ] Pity increments and resets correctly under repeated test opens
- [ ] Duplicate-heavy sessions still progress crafting goal(s)
- [ ] No client-side authority over roll outcomes

## Phase 2 (Weeks 4-7): Progression + Social
**Goal:** Create mid/long-term goals and social visibility.

### Deliverables
- [ ] Ship Mastery Pass UI + XP progression rules
- [ ] Ship Collection Album tab with set completion rewards
- [ ] Add gang objectives with weekly reset behavior
- [ ] Add curated hype feed with rate limits and client mute/hide
- [ ] Add batch inventory actions (convert/sell commons by rule)

### Exit Criteria
- [ ] New player sees meaningful progress every 2-3 opens
- [ ] Gang milestone rewards grant correctly and cannot be cheesed
- [ ] Hype feed highlights significant drops without spam

## Phase 3 (Weeks 8-12): Economy Hardening + LiveOps
**Goal:** Keep system healthy under scale and events.

### Deliverables
- [ ] Marketplace health panel (median, floor/ceiling bands, velocity)
- [ ] Dynamic drop-rate nudges (small/capped/logged)
- [ ] Trade cooldown rules for apex drops
- [ ] Velocity/anomaly scoring for abuse detection
- [ ] Seasonal chapter tooling for content rotation
- [ ] A/B hooks for presentation and pacing experiments

### Exit Criteria
- [ ] Event periods do not trigger runaway inflation
- [ ] Admin kill switch can disable problematic case pools instantly
- [ ] Telemetry dashboards support D1/D7/D30 balancing decisions

---

## 4) Data and Telemetry Spec

### Event Set (Minimum)
- `unbox_open_started`
- `unbox_open_resolved`
- `unbox_pity_incremented`
- `unbox_pity_guaranteed`
- `unbox_duplicate_converted`
- `unbox_fragment_crafted`
- `unbox_market_listed`
- `unbox_market_sold`

### Required Dimensions
- SteamID64 (hashed in analytics store if needed)
- Case family
- Drop rarity + item ID
- Pity depth before/after
- Fragment balance delta
- Session length bucket
- Gang/clan participation flag

### KPI Dashboard Targets
- Opens/player/day, time-to-first-meaningful-reward
- Average pity depth by rarity tier
- Crafting conversion utilization
- Marketplace velocity + volatility
- Retention by progression bracket (D1/D7/D30)

---

## 5) Fairness, Compliance, and Trust Requirements

- Show odds or rarity bands in UI before opening.
- Clearly explain pity behavior and guarantee caps.
- Keep roll logic server-authoritative and logged.
- Log high-value drops + admin interventions in audit trail.
- If monetized, expose spending controls and cooldown options.
- Never silently nerf odds; all changes must be patch-noted.

---

## 6) Risks and Mitigations

1. **Inflation from high drop volume**
   - Mitigation: listing/crafting sinks, capped nudges, emergency kill switch.
2. **Player distrust in RNG**
   - Mitigation: transparent pity meters, odds display, visible logs for admin audits.
3. **Exploit abuse (alts/trade rings)**
   - Mitigation: velocity scoring, trade cooldowns, anomaly alerts.
4. **UI complexity and lag**
   - Mitigation: staged rendering, filter caching, batch actions with throttling.

---

## 7) In-Game Acceptance Checklist (Release Gate)

- [ ] New player opens 10 cases and sees progression every 2-3 opens.
- [ ] Duplicate-heavy session advances at least one meaningful target.
- [ ] Pity state updates correctly and resets after guarantee.
- [ ] Marketplace remains stable during boosted event windows.
- [ ] Menu/inventory interactions remain responsive under load.
- [ ] Social feed creates excitement without chat flooding.

---

## 8) Rollback Plan

If a release negatively impacts economy or trust:
1. Disable affected case pool via kill switch.
2. Freeze crafting/reroll temporarily if exploit suspected.
3. Revert last odds table + pity tuning snapshot.
4. Publish incident note with expected fix window.
5. Re-enable features in staged order after validation.

---

## 9) Definition of Done (Roadmap Completion)

This roadmap is considered complete when:
- All Phase 1-3 deliverables are checked.
- Release gate checklist passes in live environment.
- KPI trends are stable for two consecutive weekly windows.
- Admin runbook for events/incident rollback is documented and tested.
