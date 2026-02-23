# Top-Tier Unboxing System Roadmap (DarkRP / Physgun)

## Vision
Build an unboxing ecosystem that feels **fair, exciting, social, and progression-driven** so players always have a reason to return.

## Product Pillars
1. **Feel great every session** (opening ceremony, near-miss pacing, high quality feedback).
2. **Long-term progression** (mastery tracks, collections, pity systems, milestones).
3. **Healthy economy** (crafting sinks, marketplace integrity, anti-inflation controls).
4. **Social prestige** (showcases, flex moments, clan/gang goals, event races).
5. **Trust and fairness** (clear odds policy, transparent safety valves, exploit resistance).

---

## 1) Reward Loop Design (Core Experience)

### A. 3-Layer Reward Structure
- **Micro rewards** (common drops, tokens, scrap, XP) every few opens.
- **Mid rewards** (collection pieces, craft mats, themed cosmetics) every session.
- **Apex rewards** (ultra-rare / animated / stat-tracked) for long-term aspiration.

Why it works:
- Players always get "something" now while still dreaming about high-tier outcomes.

### B. Progressive Bad-Luck Protection
Use transparent pity progression per case family:
- Track failed rolls toward each rarity tier.
- Soft pity ramps odds upward after threshold.
- Hard pity guarantees reward by cap.

Design rules:
- Keep implementation server-side only.
- Surface progress in UI ("Legendary protection: 62% to guarantee").
- Never reduce odds silently.

### C. Duplicate Utility
Avoid dead drops via duplicate conversion:
- Duplicate -> **Fragments** by rarity.
- Fragments -> craft target items (expensive but deterministic).
- Optional reroll station (fragments + fee).

Result: every drop contributes to long-term goals.

---

## 2) Meta Progression (The "Work Toward" Layer)

### A. Unboxing Mastery Pass
Permanent account progression (not seasonal only):
- Levels earned from opens + item value + streak goals.
- Unlocks: profile badges, title colors, case discounts, extra storage, animation variants.
- Milestone levels every 10 levels with meaningful perks.

### B. Collections and Set Bonuses
Organize items into collection albums:
- Completing sets grants permanent account bonuses (cosmetic-only preferred).
- Partial completion grants profile flair and banner upgrades.
- "Museum" tab showing completion percentage and chase items.

### C. Seasonal Chapters (8-12 weeks)
- Themed case pool + time-limited challenges.
- Seasonal currencies that expire or convert down at season end.
- Prestige archive for previous seasons to preserve collector value.

---

## 3) Economy & Marketplace Integrity

### A. Controlled Sinks
To prevent inflation:
- Listing fees that scale with rarity.
- Crafting fees and reroll costs.
- Upgrade gamble station with strict EV controls.

### B. Price Stability Tools
- Median sale price + floor/ceiling bands for admin diagnostics.
- Dynamic drop-rate nudges if market floods (small, capped, logged).
- Emergency kill switch for problematic case pools.

### C. Anti-Abuse Rules
- Trade cooldown on newly opened apex items.
- Velocity checks (sudden high-volume trades/listings).
- Duplicate-account anomaly scoring for marketplace abuse.

---

## 4) UX & "Feels Good" Presentation

### A. Opening Ceremony Quality
- Distinct anticipation phases: pre-roll, reveal tension, impact burst.
- Rarity-specific sound layers and particles.
- 1-click skip option after first reveal frame (respect player time).

### B. Reward Messaging
- Show value context (market median / rarity percentile).
- Show progression impact immediately (mastery XP gained, pity changed, collection progress).
- Highlight "new best" moments (highest rarity this week, streak records).

### C. Low-Frustration Inventory
- Smart filters (rarity, collection, marketable, duplicates).
- Batch actions (sell all commons under threshold, convert duplicates).
- Compare panel for stat-track and wear variants.

---

## 5) Social Retention Systems

### A. Global Hype Feed
- Broadcast only meaningful drops (top rarity thresholds).
- Rate-limit player shoutouts to avoid spam.
- Allow hide/mute controls client-side.

### B. Friend & Gang Objectives
- Cooperative milestones: "open 200 gang cases this week".
- Shared rewards: gang badge effects, vault cosmetics, banner trails.
- Leaderboards: weekly and all-time with anti-cheese rules.

### C. Showcase Mechanics
- Inspect cards with history: obtained date, method, notable kill stats.
- Profile shelves for favorite items.
- "Featured Collection" rotation for top collectors.

---

## 6) LiveOps: Content Cadence that Keeps Players Back

### Weekly
- Rotating flash case, rotating craft target, limited challenges.

### Monthly
- Themed event weekend with boosted progression (not raw odds spikes unless disclosed).

### Seasonal
- New chapter pass, item families, collection arcs, and rare chase re-colors.

Guideline:
- Content cadence should be predictable enough to plan for, surprising enough to feel alive.

---

## 7) Data, Telemetry, and Balancing

Track this from day 1:
- Opens/player/day, session opens, and churn cohorts.
- Time-to-first-meaningful-reward.
- Pity hit rates and average pity depth.
- Crafting usage, duplicate conversion rates, marketplace velocity.
- Retention impact of milestones (D1, D7, D30 by progression bracket).

Operational dashboards:
- Economy health panel.
- Progression funnel panel.
- Event performance panel.

A/B testing examples:
- Case presentation variants.
- Pity threshold tuning.
- Mastery XP pacing.

---

## 8) Fairness, Compliance, and Player Trust

- Publish odds or rarity bands clearly in the UI.
- Expose pity state and guarantee behavior where legal and appropriate.
- Keep all roll logic server authoritative.
- Log high-value outcomes and admin interventions.
- Provide clear parental/spending controls if monetized.

Trust is a retention feature.

---

## 9) Implementation Plan for This Codebase (Pragmatic)

### Phase 1 (2-3 weeks): Foundation
- Add pity counters and duplicate fragment conversion to server reward flow.
- Add UI indicators for pity, mastery XP, and collection completion.
- Add telemetry hooks and admin diagnostics tables.

### Phase 2 (2-4 weeks): Progression + Social
- Ship Mastery Pass and Collection Album tabs.
- Add gang objectives and curated hype feed.
- Add batch inventory actions.

### Phase 3 (ongoing): LiveOps + Tuning
- Seasonal chapter tooling and content pipeline.
- Economy balancing rules and anomaly alerts.
- A/B test pacing and event structures.

---

## 10) In-Game Acceptance Checklist

1. New player opens 10 cases and receives visible progression every 2-3 opens.
2. Duplicate-heavy session still advances at least one meaningful goal.
3. Pity state updates correctly after each opening and resets on guarantee hit.
4. Marketplace remains stable during boosted events (no runaway inflation).
5. Session UX remains responsive under load (no noticeable menu lag).
6. Social feed highlights exciting moments without chat spam.

---

## "Top 1%" Differentiators

If you want to push beyond typical unboxing systems:
- **Narrative collections:** drops that unlock lore snippets and map easter eggs.
- **Skill-coupled cosmetics:** variants unlocked by gameplay achievements + unboxing parts.
- **Community milestones:** server-wide goals unlock global case themes.
- **Creator spotlights:** limited artist-designed skin lines with transparent revenue split.

These features turn unboxing from "slot machine" into a **community progression platform**.
