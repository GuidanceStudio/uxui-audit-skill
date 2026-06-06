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
