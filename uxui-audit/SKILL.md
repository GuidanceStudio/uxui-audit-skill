---
name: uxui-audit
description: Full-spectrum UX/UI audit of a rendered web interface (not its source). Captures screenshots of any app — Playwright, a Playwright MCP, or screenshots you provide — then audits them across twelve dimensions (Nielsen usability, WCAG accessibility, visual design, content & language/i18n, state coverage, responsive, information architecture, interaction design, user journey, cognitive load & onboarding, trust & credibility, error prevention & recovery), assigns a 0–4 severity per finding, and emits a triageable report plus optional regression guards. Use when the user asks to "audit the UX/UI", "UX audit", "UI review", "heuristic evaluation", "design review", "audit the interface/screens", or "check the UX" of a running app. Framework-agnostic; needs an image-capable agent (capture needs Node + Playwright, or you supply PNGs).
---

# uxui-audit — Router

This skill audits the full UX/UI spectrum — not just visual design. It reviews
what the user actually *sees* and *experiences*: it captures rendered
screenshots, then asks specific, methodical questions across twelve dimensions,
assigns a severity per finding, and ties every finding to a screenshot.

It absorbs the best of: shiplightai *Design Review* (5-phase flow + regression
guards), mastepanoski `nielsen-heuristics-audit` (Nielsen 10 + 0–4 severity),
Anthropic *frontend-design* (atomic-fix + before/after ethos), WCAG 2.2 / POUR,
Jakob Nielsen's 10 heuristics, Don Norman, and the APCA contrast model — plus
six dimensions the generic skills omit: **language/i18n consistency**,
**no internal-jargon leak**, **error-shaped empty states**, **information
architecture**, **trust & credibility (dark patterns)**, and
**error prevention & recovery**.

## When to invoke

Trigger keywords (any of):
- "UX audit", "uxui audit", "UI audit", "heuristic evaluation"
- "review the UI / UX", "UX review", "UI review", "design review"
- "audit the interface / screens / pages", "check the UX/usability"
- "is this UI consistent / accessible / on-brand", "a11y review of the UI"

Do **not** use this for source-level audits (use `tech-audit` D15/D16) or for
*building* UI (use a frontend-design skill). This reviews the rendered result.

## The five phases

Run them in order. Detail for each lives in `workflow.md` — read it before
starting a real review.

1. **Scope** — establish, with the user: which surfaces (URLs/routes/components)
   and key states; which viewports (default: mobile 390×844, tablet 768×1024,
   desktop 1440×900); the **target audience and expected UI language(s)**; any
   auth; and the capture method. Write down what "consistent/done" means for
   *this* product (e.g. "UI language = Italian", "primary brand = #DC2F47").
2. **Capture** — take screenshots per surface × viewport (and per reachable
   state: empty / filled / error). Methods + exact install commands in
   `capture.md`. Save to a per-run folder; never edit the app to capture.
3. **Analyze** — read each screenshot and walk the twelve dimension groups in
   `dimensions.md`. For each issue: dimension · severity 0–4 · the screenshot ·
   what's wrong · the concrete fix. Flag what a screenshot *cannot* prove
   (exact contrast, focus order, keyboard, motion, ARIA, gesture fluidity,
   actual undo/recovery) → recommend a live/automated pass.
4. **Report** — emit the triageable report in `report-template.md`: ✅ strengths,
   then findings sorted by severity, each with a screenshot ref + fix, + summary
   counts. Be honest; don't pad. Group by surface or by dimension, whichever
   reads clearer for the set.
5. **Guard** *(optional, on request)* — turn the top findings into regression
   guards in the user's own stack (`regression-guards.md`), and/or hand the fix
   list to a planning/TDD flow. This skill audits; it does not silently edit.

## The twelve dimensions (full catalogue in `dimensions.md`)

| # | Dimension | What it audits |
|---|---|---|
| 1 | **Usability** | Nielsen's 10 heuristics |
| 2 | **Accessibility** | WCAG 2.2 POUR, contrast, target size, semantics |
| 3 | **Visual Design** | hierarchy, spacing, typography, colour semantics, motion |
| 4 | **Content & Language** | i18n consistency, no jargon leak, microcopy, UX writing |
| 5 | **State & Data** | empty/loading/error/first-run/zero-one-many/overflow |
| 6 | **Responsive** | per-breakpoint layout integrity, touch ergonomics |
| 7 | **Information Architecture** | nav structure, labeling, findability, breadcrumbs |
| 8 | **Interaction Design** | affordances, feedback, click-target sizing, gestures |
| 9 | **User Journey / Flow** | multi-screen coherence, back-navigation, dead ends |
| 10 | **Cognitive Load & Onboarding** | density, chunking, progressive disclosure, first-run guidance |
| 11 | **Trust & Credibility** | social proof, dark patterns, security indicators, transparency |
| 12 | **Error Prevention & Recovery** | confirmations, undo, error message actionability, degradation |

## Severity (Nielsen 0–4)

`0` not a problem · `1` cosmetic (fix if time) · `2` minor · `3` major (fix
soon) · `4` catastrophic (must fix before ship). Assign per finding; sort the
report by it. Rubric detail in `dimensions.md`.

## Honesty rules

- Every finding cites a **specific screenshot** and a **concrete fix** — no vague
  "improve the spacing".
- State what the screenshot **can't** verify and route it to a live/automated
  check; don't assert a11y pass/fail you can't see.
- Call out **strengths** too — a review that's all negatives is not trustworthy.
- Stay generic: the same checklist must work for any web UI in any framework.
