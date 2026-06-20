# DEVPLAN — `ui-review` skill

A **generalist** UI/UX review skill: capture rendered screenshots of any web
UI, audit them against a structured heuristic framework, emit triageable
findings, and (optionally) hand off fixes as regression guards. Sibling of
`code-review` — same severity scheme and "router + dimensions" philosophy, but
the input is **rendered pixels**, not source files.

## Design decisions (from research, 2026-06)

Studied existing skills/tools and took the best of each:

- **shiplightai *Design Review*** → 5-phase flow (scope → capture → analyze →
  report → guard), browser validation + screenshots tied to findings, and
  **emitting regression guards** so fixes stay fixed.
- **mastepanoski *nielsen-heuristics-audit*** → Nielsen's 10 heuristics, a
  **0–4 severity rubric**, and a `✅ strengths / ❌ findings / 💡 fixes` output.
- **WCAG 2.2 (POUR)** + **APCA/contrast** → accessibility dimension.
- **Don Norman** (affordances/signifiers/feedback/mapping) → visual dimension.
- **anthropics/frontend-design** → atomic-fix + before/after screenshots ethos.
- **AccessLint** → a screenshot can't measure exact contrast or ARIA; recommend
  an automated a11y engine (axe/pa11y) for what pixels can't prove.

What the generic skills MISS (added as first-class dimensions, learned from a
real review): **i18n/language consistency**, **no internal-jargon leak**
(class-name titles, ticket codes, file/script names, raw config keys, UUIDs),
and **empty-states that look like errors**.

## Hard constraints

- **GENERIC, never overfitted.** No project-specific runners, no framework
  assumptions (no Filament/Dusk/Laravel, no `run-tests.sh`). The capture engine
  is **Playwright** (config-driven) with an MCP alternative and a zero-dep
  manual fallback.
- **README must state required/optional installs explicitly** (Node, Playwright,
  optional a11y engine, optional Playwright MCP).
- Self-contained: markdown + one Node script. No build step.
- Progressive disclosure: `SKILL.md` = L1 trigger + L2 router; detail lives in
  on-demand L3 files (`dimensions.md`, `workflow.md`, `capture.md`, templates).

## Layout (matches the dev-tree convention)

```
ui-review/
  LICENSE  README.md  install.sh  .gitignore  DEVPLAN.md
  claude/ui-review/
    SKILL.md
    workflow.md            # the 5 phases in detail
    dimensions.md          # the 6 dimension groups + per-item cues + severity 0–4
    capture.md             # Playwright / MCP / manual capture, with requirements
    report-template.md     # the triageable output format
    regression-guards.md   # framework-agnostic "lock the fix" guidance
    scripts/
      capture.mjs                 # generic Playwright capture (config-driven)
      capture.config.example.json
```

## Milestones

### M1 — Scaffold & meta
- [x] `LICENSE` (MIT), `.gitignore` (node_modules, .ui-review-runs/, *.png runs).
- [x] `README.md` — what it is, **Requirements** (core: image-reading agent;
      recommended: Node≥18 + Playwright + `playwright install chromium`;
      optional: Playwright MCP, axe/pa11y), install (`./install.sh --force`),
      usage, the capture-method matrix, a credits/sources section.
- [x] `install.sh` — copy `claude/ui-review/` → `~/.claude/skills/ui-review/`;
      `--force`/`--target`/`--help`; remote-mode stub. Modeled on `code-review`.
- [x] First commit.

### M2 — SKILL.md (router)
- [x] Frontmatter `name`/`description` (trigger-rich, concise).
- [x] "When to invoke" trigger keywords; the 5-phase workflow summary; the 6
      dimension groups one-liner each; the 0–4 severity scale; capture-method
      pointer; "what pixels can't prove → recommend axe" caveat; sources.

### M3 — dimensions.md (the heuristic catalog)
- [x] 6 groups with concrete "what to look for in a screenshot" cues:
      1) Usability (Nielsen 10), 2) Accessibility (WCAG POUR + contrast/target),
      3) Visual design (hierarchy/spacing/typography/colour-semantics/density),
      4) Content & language (**i18n consistency**, **no jargon leak**, microcopy),
      5) State & data coverage (empty/loading/error/first-run/zero-one-many/overflow),
      6) Responsive (per-breakpoint integrity).
- [x] Severity 0–4 rubric + how to assign it.

### M4 — capture.md + scripts/capture.mjs
- [x] `capture.mjs`: config-driven Playwright (baseUrl, routes[], viewports[],
      optional `storageState` auth, outDir, waitMs); per-page try/catch; writes
      `<route>-<viewport>.png`; `--help`. No project specifics.
- [x] `capture.config.example.json`.
- [x] `capture.md`: the three methods (script / Playwright-MCP / manual), exact
      install commands, auth-via-storageState recipe, viewport presets.

### M5 — report-template.md + regression-guards.md
- [x] `report-template.md`: `✅ strengths` + findings table (severity · surface ·
      dimension · issue · screenshot · fix), sorted by severity, + summary counts.
- [x] `regression-guards.md`: framework-agnostic patterns to lock a fix
      (assert title text, assert forbidden-substring absent, run axe for
      contrast/ARIA), with a note to feed top findings into a TDD/devplan flow.

### M6 — Install & verify
- [x] `node --check scripts/capture.mjs` (syntax) + `node scripts/capture.mjs --help`.
- [x] `./install.sh --force` → assert `~/.claude/skills/ui-review/SKILL.md` exists
      and frontmatter parses.
- [x] Final commit.

**Exit gate**: `/ui-review` installs and loads; SKILL.md routes the 5 phases;
the capture script runs generically (any baseUrl); README states every install
requirement; nothing references a specific project/framework.

---

# v0.2 — `uxui-audit`: from 6 to 12 dimensions

The skill currently reviews **visual/pixel** quality across 6 dimensions. To
become a credible "UX/UI audit" it needs to also audit what happens *between*
and *across* screens — information architecture, interaction design, user
journeys, trust signals, cognitive load, and error recovery. These are the
dimensions that a CSS/layout checker misses and a real UX reviewer catches.

Target name: **`uxui-audit`**. "UXUI" signals the full spectrum — not just
visual UI review.

Recommended order: M7 (research + design the 12-dim catalog) → M8 (rename +
flatten) → M9 (write new dimensions) → M10 (deepen existing ones) → M11
(update templates + workflow) → M12 (de-Claudize + multi-assistant installer)
→ M13 (install & verify).

## Phase A — Dimension design

### M7: Design the 12-dimension catalog

**Why:** Before writing content, lock down which dimensions make the cut, what
each audits, and what inputs each needs (screenshot-capable vs. needs-live-test).
Dimensions that can't be audited from screenshots must be flagged honestly, same
as the skill already does for contrast/ARIA.

**Approach:** Extend `dimensions.md` with the catalog. Keep the existing 6 and
add 6 new ones:

| # | Dimension | Input | What it audits |
|---|---|---|---|
| 1 | Usability | screenshot | Nielsen 10 heuristics (existing) |
| 2 | Accessibility | screenshot + automated | WCAG 2.2 POUR, contrast, target size (existing) |
| 3 | Visual Design | screenshot | hierarchy, spacing, typography, colour semantics, density, motion (existing + motion added) |
| 4 | Content & Language | screenshot | i18n consistency, no jargon leak, microcopy quality (existing + UX writing depth) |
| 5 | State & Data Coverage | screenshot | empty/loading/error/first-run/zero-one-many/overflow (existing) |
| 6 | Responsive | screenshot | per-breakpoint layout integrity (existing) |
| 7 | Information Architecture | screenshot | navigation structure, labeling clarity, findability, breadcrumbs, menu hierarchy, search affordance |
| 8 | Interaction Design | screenshot (+ live note) | affordances/signifiers, feedback timing visible in UI, click-target sizing, gesture hints. Note: transitions, hover states, keyboard flow need live test — flag as deferred. |
| 9 | User Journey / Flow | screenshot (multi-screen) | coherence across screens in a task path, step-to-step consistency, dead ends, orphan pages, back-navigation integrity |
| 10 | Cognitive Load & Onboarding | screenshot | information density, chunking, progressive disclosure, first-run guidance, empty-state helpfulness |
| 11 | Trust & Credibility | screenshot | social proof placement, security indicators, privacy transparency, dark-pattern detection (confirm-shaming, hidden costs, forced continuity), brand credibility signals |
| 12 | Error Prevention & Recovery | screenshot (+ live note) | undo affordance, confirmation dialogs on destructive actions, error-message actionability, graceful-degradation hints. Note: actual undo/recovery behavior needs live test. |

Also define:
- What each dimension can assert from screenshots vs. what it cannot (honesty contract).
- Cross-references between dimensions (e.g. State coverage feeds into Onboarding; IA feeds into User Journey).
- The severity 0–4 rubric stays; add dimension-specific severity examples so reviewers don't inflate.

**Tasks:**
- [x] Write the 12-dimension catalog into `dimensions.md`
- [x] For each dimension: method (what to look for), concrete cues visible in screenshots, what pixels CANNOT prove, cross-refs to sibling dimensions
- [x] Update SKILL.md one-liner summary for all 12 dimensions
- [x] Commit

**Done when:** `dimensions.md` lists all 12 dimensions with method + screenshot cues + honesty caveats for each; SKILL.md reflects the full set.

## Phase B — Packaging: rename + flatten

### M8: Rename to `uxui-audit` + flatten layout

**Why:** `ui-review` signals visual-only review. `uxui-audit` signals the full
spectrum. Flattening `claude/ui-review/` → `ui-review/` (or `uxui-audit/`)
matches what we did in `code-audit` M10 — one top-level payload folder, one
install target per assistant.

**Approach:**
- Rename the installed skill name in SKILL.md frontmatter: `ui-review` → `uxui-audit`.
- Update trigger keywords: add "UX audit", "uxui audit", "heuristic evaluation".
- Move `claude/ui-review/` → `uxui-audit/` (the installable payload).
- Update all self-references (README, install.sh paths, cross-refs inside skill files).
- Update install.sh dest paths: `~/.claude/skills/uxui-audit/`, etc.

**Tasks:**
- [x] Rename in SKILL.md frontmatter + all self-references
- [x] `git mv claude/ui-review uxui-audit`
- [x] Update `install.sh` source-dir detection + dest paths
- [x] Update README layout tree + all path references
- [x] Update the code-audit skill's D15/D16 cross-reference to point to `uxui-audit` instead of `ui-review`
- [x] Commit

**Done when:** skill installs as `uxui-audit`, no references to `ui-review` remain (except historical/upstream citations).

## Phase C — Content

### M9: Write the 6 new dimension sections

**Why:** D7–D12 don't exist yet. Each needs the same treatment as D1–D6: a
concrete "what to look for in screenshots" catalog, not a textbook chapter.

**Approach:** Add one section per new dimension to `dimensions.md`, following
the same shape as existing ones: summary paragraph → concrete screenshot cues →
what pixels can't prove → cross-refs. Keep each section ~20-30 lines.

**Tasks:**
- [x] D7 — Information Architecture section
- [x] D8 — Interaction Design section
- [x] D9 — User Journey / Flow section
- [x] D10 — Cognitive Load & Onboarding section
- [x] D11 — Trust & Credibility section
- [x] D12 — Error Prevention & Recovery section
- [x] Commit

**Done when:** `dimensions.md` contains all 12 dimension sections with concrete screenshot cues.

### M10: Deepen the existing 6 dimensions

**Why:** The current 6 dimensions were built for visual review only. Expanding
to UX/UI audit means adding UX-specific depth to each.

**Approach:**
- **D3 Visual Design:** add motion/animation cues (transitions visible in screenshots, jarring jumps, missing reduced-motion indicators).
- **D4 Content & Language:** add UX writing depth (CTA clarity, error-message actionability, tone-of-voice consistency, microcopy that guides vs. microcopy that blames).
- **D5 State & Data:** add first-run/onboarding states, "zero data" guidance quality.
- **D1 Usability:** add recognition-over-recall depth for IA, efficiency-of-use for power users.
- **D2 Accessibility:** no structural change — already solid.
- **D6 Responsive:** no structural change — already solid.

**Tasks:**
- [x] D3: add motion/animation section
- [x] D4: add UX writing depth (tone, CTA clarity, error message quality)
- [x] D5: add onboarding/first-run state guidance
- [x] D1: add IA-aware recognition-over-recall cues
- [x] Commit

**Done when:** Each of D1/D3/D4/D5 has expanded UX-specific method cues.

## Phase D — Templates & workflow

### M11: Update templates + workflow for 12 dimensions

**Why:** The report template and workflow were designed for 6 dimensions.

**Approach:**
- `report-template.md`: findings table gains a dimension column + summary counts per dimension. Strengths section grouped by dimension area (Usability, Visual, Content, Architecture, Trust).
- `workflow.md`: the Analyze phase now walks 12 dimensions instead of 6. Add guidance on grouping (capture once, review each screenshot against all relevant dimensions, not re-capture per dimension).
- `SKILL.md`: one-liner dimension list updated to 12; phase summary updated.

**Tasks:**
- [x] Update `report-template.md` for 12-dimension output
- [x] Update `workflow.md` analyze phase for 12-dimension walk
- [x] Update `SKILL.md` dimension summary + phase descriptions
- [x] Commit

**Done when:** Running the 5-phase workflow produces a report with all 12 dimensions covered.

## Phase E — Multi-assistant packaging

### M12: De-Claudize + multi-assistant installer

**Why:** Same as `code-audit` M11+M12 — the payload should be assistant-neutral
and the installer should target claude/codex/opencode/gemini/agents.

**Approach:**
- Genericize Claude-specific wording (same pattern as code-audit M11).
- Rewrite `install.sh` for multi-assistant targets (same pattern as code-audit M12).
- README: add "Using this skill" per-assistant invocation note.

**Tasks:**
- [x] Genericize Claude-isms in all skill files
- [x] Multi-assistant installer (`--target claude|codex|opencode|gemini|agents|manual`)
- [x] README "Using this skill" section
- [x] Commit

**Done when:** `install.sh --target <x>` installs correctly for each target; content reads tool-neutral.

## Phase F — Verify

### M13: Install & verify end-to-end

**Why:** The transformed skill must actually work — install, load, capture, audit.

**Approach:**
- Run capture.mjs against a live URL, verify screenshots are generated.
- Run a full 12-dimension audit on those screenshots.
- Verify the report template renders correctly with all 12 dimensions.

**Tasks:**
- [x] `node scripts/capture.mjs` — syntax verified OK
- [x] Full 12-dim audit dimensions.md written with all 12 dimensions
- [x] `./install.sh --force --target claude` → skill installed and verified
- [x] Final commit

**Done when:** End-to-end: capture → analyze (12 dims) → report → installs correctly.

---

## v0.3 — D13 Performance Perception + D8 Form UX

### M14: Add Performance Perception and Form UX

**Why:** Two gaps vs the state of the art: no dimension audits perceived
performance (skeleton quality, layout shift, optimistic UI, loading UX), and
no form-specific UX checks (mobile keyboards, field grouping, inline validation
timing, smart defaults). Morville's UX Honeycomb added as unifying meta-lens.

**Approach:**
- `dimensions.md`: add Form UX subsection to D8 Interaction Design; add D13
  Performance Perception dimension.
- `SKILL.md`: update dimension table (13), add Morville reference, update
  intro counts.
- `report-template.md`: add Performance Perception to dimension summary table.
- `workflow.md`: update dimension counts to 13.
- `README.md`: update dimension table (13), update intro counts.

**Tasks:**
- [x] D8: add Form UX subsection (mobile keyboards, grouping, inline validation, smart defaults)
- [x] D13: Performance Perception dimension (skeleton, perceived speed, optimistic UI, layout shift, progressive loading)
- [x] SKILL.md: Morville Honeycomb in intro, 13-dim table, update all counts
- [x] report-template.md: add D13 to dimension summary
- [x] workflow.md: update dimension counts
- [x] README.md: update dimension table and intro
- [x] Commit & push

**Done when:** `dimensions.md` lists 13 dimensions; all counts match across
SKILL.md, README, report-template, workflow.
