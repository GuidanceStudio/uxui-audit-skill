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

---

## Follow-up — Cross-skill coherence fixes (2026-06-20)

Issues found during coherence audit across forge-flow, uxui-audit, and
tech-audit. Fixes belong here.

### M15: Fix "Twelve dimension groups" count to 13 in dimensions.md ✅

**Why:** `dimensions.md:3` says *"Twelve dimension groups."* but the file
actually lists 13 groups (1–13). This is a copy-paste leftover from v0.2
when there were 12; v0.3 added D13 but the intro text wasn't updated.

**Approach:** Change the intro sentence to *"Thirteen dimension groups."*
in `uxui-audit/dimensions.md`.

**Tasks:**
- [x] Change "Twelve dimension groups" → "Thirteen dimension groups" in `uxui-audit/dimensions.md` line 3
- [x] Verify no other stale count references remain (`grep -rn 'twelve\|Twelve' uxui-audit/`)
- [x] Commit & push

**Done when:** `dimensions.md` intro count matches the actual number of dimension groups.

### M16: Update system prompt description from 6 to 13 dimensions

**Why:** The skill's `description` in `SKILL.md` frontmatter (which becomes
the system prompt entry) says *"six dimensions (Nielsen usability, WCAG
accessibility, visual design, content & language/i18n, state coverage,
responsive)"* — a leftover from v0.1 when the skill only had 6. The actual
skill has 13 dimensions; the system prompt misrepresents the scope.

**Approach:** Update the `description:` field in `uxui-audit/SKILL.md`
frontmatter to say "thirteen dimensions" and list them succinctly or
summarize without enumerating all 13.

**Status: Cancelled.** The source `SKILL.md` frontmatter already says
"thirteen dimensions" (updated in v0.3). The stale "six dimensions" text in
the system prompt is a cached/installed copy issue — reinstalling the skill
will pick up the correct description. No source change needed.

### M18: Add emoji shorthand to severity table (cross-skill unification) ✅

**Why:** tech-audit and uxui-audit now share the unified 0–4 severity scale.
tech-audit uses 4🔴 / 3🟡 / 0-2🟢 as visual shorthand banked on the same
numeric scale. uxui-audit's severity table should show the same emoji mapping
so reviewers see the same language in both skills.

**Approach:** Add an emoji column to the severity table in
`uxui-audit/uxui-audit/dimensions.md` and a one-line note in
`uxui-audit/uxui-audit/SKILL.md` severity section. No other changes needed —
uxui-audit already uses 0–4.

**Tasks:**
- [x] Add emoji column to severity table in `uxui-audit/uxui-audit/dimensions.md`
- [x] Add emoji shorthand note to `uxui-audit/uxui-audit/SKILL.md` severity section
- [x] Commit & push

**Done when:** uxui-audit severity docs show the same 0–4 + emoji convention as tech-audit.

### M19: Clarify ambiguous cross-reference notation in dimensions.md

**Why:** `dimensions.md:399` says *"Usability §4 consistency, Content §i18n,
or Journey §9"*. "§4" here refers to Nielsen heuristic #4 (Consistency &
standards) inside Usability (§1), but the surrounding text uses the same
§N notation for top-level dimension groups (e.g. §4 = Content & Language).
The §4 in "Usability §4 consistency" is ambiguous — a reader following the
§N convention will map it to the wrong dimension group.

**Approach:** Rewrite the phrase to avoid §N notation for Nielsen sub-items.
Use e.g. *"Usability heuristic 4 (consistency)"* or similar unambiguous
wording.

**Tasks:**
- [ ] Clarify the cross-reference in `uxui-audit/dimensions.md` line 399 to avoid §4 ambiguity
- [ ] Verify the rest of the file for similar §N-overloading issues
- [ ] Commit & push

**Done when:** The cross-reference notation is unambiguous and §N always
refers to a top-level dimension group.

---

## v0.4 — Token essentiality pass

Cross-skill audit found ~25% of the skill payload is wasted on duplication
and verbose prose. Same concepts, same behavior, fewer tokens.

Recommended order: M20 → M21 → M22 → M23.

### M20: Deduplicate across files — severity rubric, honesty rules, pixel limits

**Why:** The 0-4 severity rubric is defined in full in SKILL.md, dimensions.md,
and report-template.md. Honesty rules ("cite a screenshot, concrete fix,
include strengths") are in SKILL.md and report-template.md. The "what pixels
can't prove" disclaimer appears 10+ times across dimensions.md with near-
identical phrasing. Each duplicate costs tokens on every invocation.

**Approach:**
- Severity rubric: keep full table only in `dimensions.md`. SKILL.md and
  report-template.md get 1-line references.
- Honesty rules: keep in `report-template.md` only. SKILL.md gets 1-line ref.
- "Pixels can't prove": define once in dimensions.md preamble (already at
  lines 7-10). Remove per-dimension repeats; replace with `⚠ = pixels can't
  prove (see preamble)` marker. Remove from `capture.md:78-91`.
- Remove "UX depth dimensions (7-13)" reminder from workflow.md (keep only
  in dimensions.md).

**Tasks:**
- [ ] SKILL.md: replace severity rubric with 1-line reference to dimensions.md
- [ ] report-template.md: replace severity rubric with 1-line reference
- [ ] SKILL.md: replace honesty rules with 1-line reference to report-template.md
- [ ] dimensions.md: remove per-dimension pixel-limit repeats (10 occurrences)
- [ ] capture.md: remove pixel-cant-prove section, point to dimensions.md
- [ ] workflow.md: remove "UX depth" reminder
- [ ] Commit & push

**Done when:** Each concept defined exactly once; cross-references resolve correctly.

### M21: Compress verbose sections — preamble, heuristics, jargon, dark patterns

**Why:** SKILL.md preamble is a 15-line monologue of prior-art citations.
Nielsen 10 heuristics are 27 lines of prose where single-line descriptions
suffice. Internal-jargon checklist is 8 lines of full-sentence bullets.
Dark-patterns list has parenthetical examples expanding each item. All are
the most token-dense sections.

**Approach:**
- SKILL.md lines 6-21: compress to 3 lines — the description frontmatter
  already covers "what it audits".
- Nielsen 10 (dimensions.md §1): compress each heuristic to 1 line.
- Internal-jargon checklist (dimensions.md §4): compress to inline CSV list.
- Dark patterns (dimensions.md §11): compress to inline CSV list.
- Remove rhetorical questions from §7-13 section headers.
- Compress trigger keywords from 5 lines to 3.

**Tasks:**
- [ ] Compress SKILL.md preamble
- [ ] Compress Nielsen 10 heuristics to 1-line each
- [ ] Compress jargon checklist + dark patterns list
- [ ] Remove rhetorical question intros from §7-§13
- [ ] Compress trigger keywords
- [ ] Commit & push

**Done when:** Same information density, 25% fewer tokens in the compressed sections.

### M22: Compress SKILL.md phases summary

**Why:** The 5 phases are summarized in SKILL.md (25 lines) and fully detailed
in workflow.md (103 lines). The SKILL.md summary is verbose enough to be a
mini-workflow.

**Approach:** Replace SKILL.md lines 34-58 with a 6-line numbered list:
phase name + 1 sentence. "Detail: `workflow.md`".

**Tasks:**
- [ ] Compress phases section in SKILL.md
- [ ] Commit & push

**Done when:** SKILL.md phases section is a quick-reference, not a mini-playbook.

### M23: Trim READMEs

**Why:** README contains redundant install instructions and dimension descriptions
that duplicate SKILL.md.

**Approach:** Top-level README: compress install section, remove dimension
detail table (point to SKILL.md). uxui-audit README: remove content that
duplicates agentskills.io standard info.

**Tasks:**
- [ ] Compress top-level `README.md`
- [ ] Compress `uxui-audit/README.md` (if exists)
- [ ] Commit & push

**Done when:** READMEs convey same information with fewer words.

---

## v0.5 — Non-multimodal fallback documentation

### M24: Document non-multimodal fallback for Analyze phase

**Why:** The skill currently says "needs an image-capable agent" and the
Analyze phase says "Read every screenshot (the agent's image input)". If the
model isn't natively multimodal, the agent has no path to analyze screenshots.
The skill should document how to fall back to an image-description MCP tool
so the audit still works — with honest caveats about the quality loss.

**Approach (tool-agnostic):**
- Never hardcode a specific MCP name. Describe the *protocol*:
  0. If the model accepts images natively (multimodal), use the agent's
     image input directly — this is the preferred path, no MCP needed.
  2. If the model is not multimodal, check if the host already provides
     an image-description MCP tool (e.g. `media_describe_image`,
     `describe_image`, `describe_image_from_file`) — use it.
  3. If none is available, suggest the user install one. Mention three
     public options:
     - `mcp-image-recognition` (npm) — Anthropic/OpenAI vision, file +
       base64 input, built-in Tesseract OCR.
     - `ai-image-mcp-server` — GPT-4o Vision, `describe_image(path,
       prompt)` supports targeted prompts (ideal for "describe layout
       issues").
     - `z-ai-vision-mcp` — GLM-4.6V, UI-specific tools:
       `extract_text_from_screenshot`, `diagnose_error_screenshot`,
       `ui_diff_check`.
  3. The pattern: for each screenshot, call the tool with a **UI-specific
     prompt** (not a generic image description — the tool may default to
     scene/object recognition). E.g.: "Describe this UI screenshot in
     detail — layout, colors, text, states, errors, spacing, alignment,
     interactive elements."
- Add a "Non-multimodal agent" sub-section to Phase 3 (Analyze) in
  `workflow.md` with the fallback pattern + a short table of tradeoffs
  vs native vision (misses pixel-level contrast, can hallucinate text
  labels, can't judge color semantics precisely).
- Update the `description:` frontmatter in `SKILL.md`: change "needs an
  image-capable agent" to "uses the agent's native image input; for
  non-multimodal agents, route screenshots through an available
  image-description MCP tool (see workflow.md)."
- Add a one-liner cross-reference in `capture.md` after the three
  capture methods pointing to the Analyze fallback in `workflow.md`.

**Tasks:**
- [x] `workflow.md` Phase 3: add "Non-multimodal agent" sub-section with
      tool-agnostic fallback pattern, public MCP suggestions, and
      quality-loss caveat table
- [x] `SKILL.md`: update `description` frontmatter to document
      multimodal requirement + MCP fallback
- [x] `capture.md`: add brief cross-reference note pointing to
      `workflow.md` Analyze fallback
- [ ] Commit & push

**Done when:** A non-multimodal agent reading the skill knows exactly how
to analyze screenshots via an MCP; the quality-loss caveats are explicit;
three concrete public MCPs are suggested as fallback options.
