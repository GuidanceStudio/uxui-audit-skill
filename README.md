# ui-review

A **generalist UI/UX review skill** for coding agents (Claude Code, and any
agent that supports the [Agent Skills](https://agentskills.io) standard and can
read images).

It captures rendered screenshots of *any* web UI, audits them against a
structured heuristic framework (Nielsen + WCAG + Don Norman, plus
language/jargon/state checks the generic skills miss), and emits triageable
findings with a 0–4 severity each — optionally handing the top issues off as
regression guards so fixes stay fixed.

It is the **visual sibling of a code review**: same severity scheme and
"router + dimensions" philosophy, but the input is *rendered pixels*, not
source files.

## What it does

Five phases:

1. **Scope** — which surfaces (URLs/routes/components), which viewports, the
   target audience & expected UI language, and any auth.
2. **Capture** — screenshots per surface × viewport (Playwright, a Playwright
   MCP, or screenshots you provide).
3. **Analyze** — walk six dimension groups over each screenshot, assign a
   severity 0–4, tie every finding to a specific screenshot.
4. **Report** — a triageable report: strengths, findings sorted by severity,
   each with a concrete fix.
5. **Guard** *(optional)* — turn the top findings into regression guards in
   *your* test stack (framework-agnostic guidance).

The six dimension groups: **Usability** (Nielsen 10) · **Accessibility**
(WCAG 2.2 POUR, contrast, target size) · **Visual design** (hierarchy, spacing,
typography, colour semantics, density) · **Content & language** (i18n
consistency, no internal-jargon leak, microcopy) · **State & data coverage**
(empty / loading / error / first-run / zero-one-many / overflow) ·
**Responsive** (per-breakpoint integrity).

## Requirements

The skill itself is just Markdown + one Node script — **no build step**.

| Tier | Requirement | Why / how |
|---|---|---|
| **Core (always)** | An agent that can **read images** (Claude Code, or any image-capable agent). | The analysis is the agent reading screenshots against the checklist. |
| **Recommended (automated capture)** | **Node.js ≥ 18** and **Playwright**. | Drives a headless browser to take the screenshots. Install: `npm i -D playwright` then `npx playwright install chromium` (downloads a Chromium build, ~100–150 MB). |
| **Alternative capture** | A **Playwright MCP server** (e.g. `@playwright/mcp`) connected to your agent. | The agent navigates + screenshots through MCP tools instead of the bundled script. No Node script needed. |
| **Optional (deeper a11y)** | An automated accessibility engine — **axe-core** (`@axe-core/cli`) or **pa11y**. | A screenshot cannot measure exact contrast ratios, focus order, or ARIA. Run one of these for what pixels can't prove; the skill tells you when. |
| **Zero-dependency fallback** | None. | Drop your own PNG screenshots into a folder and point the skill at them — the heuristic analysis runs with no tooling at all. |

> Auth-gated UIs: generate a Playwright `storageState.json` once (log in via
> `npx playwright codegen <url>` or a small script) and pass it in the capture
> config — see `claude/ui-review/capture.md`.

## Install

```bash
git clone <this-repo> ui-review && cd ui-review
./install.sh --force
```

This copies the skill into `~/.claude/skills/ui-review/`. Then invoke it in your
agent:

```
/ui-review            # review the running app — the skill will ask for scope
```

or just describe the task ("review the UI/UX of http://localhost:3000").

## Usage sketch

```bash
# 1. capture (Playwright path)
npm i -D playwright && npx playwright install chromium
cp ~/.claude/skills/ui-review/scripts/capture.config.example.json ui-review.config.json
# edit ui-review.config.json: baseUrl, routes, viewports, (optional) auth
node ~/.claude/skills/ui-review/scripts/capture.mjs ui-review.config.json
# → screenshots land in ./.ui-review-runs/<timestamp>/

# 2. ask the agent: "/ui-review — analyze .ui-review-runs/<timestamp>"
```

## Credits

Synthesised from, and indebted to: shiplightai *Design Review* (5-phase flow +
regression guards), mastepanoski *claude-skills* `nielsen-heuristics-audit`
(Nielsen 10 + 0–4 severity), Anthropic *frontend-design* (atomic-fix +
before/after ethos), the WCAG 2.2 / POUR guidelines, Jakob Nielsen's 10
usability heuristics, Don Norman's *The Design of Everyday Things*, and the
APCA contrast model.

MIT licensed.
