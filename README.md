# uxui-audit

A **full-spectrum UX/UI audit skill** for coding agents (Claude Code, Codex,
opencode, and any agent that supports the [Agent Skills](https://agentskills.io)
standard and can read images).

It captures rendered screenshots of *any* web UI, audits them against a
structured 13-dimension framework (Nielsen + WCAG + Don Norman + IA +
trust/dark-patterns + error recovery + performance perception + the language/jargon/state checks the
generic skills miss), and emits triageable findings with a 0–4 severity each —
optionally handing the top issues off as regression guards.

It uses a unified 0–4 severity scheme and
"router + dimensions" philosophy, but the input is *rendered pixels*, not
source files.

## What it does

Five phases:

1. **Scope** — which surfaces (URLs/routes/components), which viewports, the
   target audience & expected UI language, and any auth.
2. **Capture** — screenshots per surface × viewport (Playwright, a Playwright
   MCP, or screenshots you provide).
3. **Analyze** — walk thirteen dimension groups over each screenshot, assign a
   severity 0–4, tie every finding to a specific screenshot.
4. **Report** — a triageable report: strengths, findings sorted by severity,
   each with a concrete fix.
5. **Guard** *(optional)* — turn the top findings into regression guards in
   *your* test stack (framework-agnostic guidance).

The thirteen dimensions: usability, accessibility, visual design, content/i18n, states, responsive, information architecture, interaction design, user journey, cognitive load, trust, error recovery, and performance perception — full catalogue in `uxui-audit/dimensions.md`.

## Requirements

The skill itself is just Markdown + one Node script — **no build step**.

| Tier | Requirement | Why / how |
|---|---|---|
| **Core (always)** | An agent that can **read images** (any image-capable agent). | The analysis is the agent reading screenshots against the checklist. |
| **Recommended (automated capture)** | **Node.js ≥ 18** and **Playwright**. | Drives a headless browser to take the screenshots. Install: `npm i -D playwright` then `npx playwright install chromium` (downloads a Chromium build, ~100–150 MB). |
| **Alternative capture** | A **Playwright MCP server** (e.g. `@playwright/mcp`) connected to your agent. | The agent navigates + screenshots through MCP tools instead of the bundled script. No Node script needed. |
| **Optional (deeper a11y)** | An automated accessibility engine — **axe-core** (`@axe-core/cli`) or **pa11y**. | A screenshot cannot measure exact contrast ratios, focus order, or ARIA. Run one of these for what pixels can't prove; the skill tells you when. |
| **Zero-dependency fallback** | None. | Drop your own PNG screenshots into a folder and point the skill at them — the heuristic analysis runs with no tooling at all. |

> Auth-gated UIs: generate a Playwright `storageState.json` once (log in via
> `npx playwright codegen <url>` or a small script) and pass it in the capture
> config — see `uxui-audit/capture.md`.

## Install

```sh
git clone git@github.com:GuidanceStudio/uxui-audit-skill.git
cd uxui-audit-skill
./install.sh --target claude      # ~/.claude/skills/uxui-audit/
./install.sh --target codex        # ~/.codex/skills/uxui-audit/
./install.sh --target opencode     # ~/.config/opencode/skills/uxui-audit/
./install.sh --target all           # claude + codex + opencode
./install.sh --target manual        # print the folder path; copy it yourself
# or one-liner:
bash <(curl -fsSL https://raw.githubusercontent.com/GuidanceStudio/uxui-audit-skill/main/install.sh) --target claude
```

## Use

Invoke the skill however your assistant invokes skills, then describe what you
want:

| Assistant | How to invoke |
|---|---|
| Claude Code | `/uxui-audit`, or just ask ("UX audit of my app") |
| Codex CLI | `/uxui-audit` (same SKILL.md standard), or ask |
| opencode | `/uxui-audit`, or ask |
| Gemini CLI | `/uxui-audit` (installed as a TOML command) |
| Cursor / Windsurf / Copilot / Aider | reference the skill from `AGENTS.md`, then ask |

Typical phrasings: `"UX audit of http://localhost:3000"`, `"heuristic evaluation"`,
`"review the UI/UX"`, `"check accessibility"`, `"design review"`.

## Usage sketch

```bash
# 1. capture (Playwright path)
npm i -D playwright && npx playwright install chromium
cp <your-skills-dir>/uxui-audit/scripts/capture.config.example.json uxui-audit.config.json
# edit uxui-audit.config.json: baseUrl, routes, viewports, (optional) auth
node <your-skills-dir>/uxui-audit/scripts/capture.mjs uxui-audit.config.json
# → screenshots land in ./.uxui-audit-runs/<timestamp>/

# 2. ask the agent: "/uxui-audit — analyze .uxui-audit-runs/<timestamp>"
```

## Repository layout

```
uxui-audit-skill/
├── install.sh
├── README.md
├── LICENSE
├── DEVPLAN.md
└── uxui-audit/
    ├── SKILL.md
    ├── dimensions.md
    ├── workflow.md
    ├── capture.md
    ├── report-template.md
    ├── regression-guards.md
    └── scripts/
        ├── capture.mjs
        └── capture.config.example.json
```

## Inspiration

Synthesised from: shiplightai *Design Review* (5-phase flow + regression
guards), mastepanoski *nielsen-heuristics-audit* (Nielsen 10 + 0–4 severity),
Anthropic *frontend-design* (atomic-fix + before/after ethos), the WCAG 2.2 /
POUR guidelines, Jakob Nielsen's 10 usability heuristics, Don Norman's *The
Design of Everyday Things*, and the APCA contrast model.

MIT licensed.
