---
name: ui-review
description: Generalist UI/UX review of a rendered web interface (not its source). Captures screenshots of any app — Playwright, a Playwright MCP, or screenshots you provide — then audits them across six dimensions (Nielsen usability, WCAG accessibility, visual design, content & language/i18n, state coverage, responsive), assigns a 0–4 severity per finding, and emits a triageable report plus optional regression guards. Use when the user asks to "review the UI/UX", "design review", "audit the interface/screens", or "check the UX" of a running app. Framework-agnostic; needs an image-capable agent (capture needs Node + Playwright, or you supply PNGs).
---

# ui-review — Router

This skill reviews what the user actually *sees*. It is **not** code review and
**not** "tell me if this looks good": it captures the rendered UI, then asks
specific, methodical questions across six dimensions, assigns a severity per
finding, and ties every finding to a screenshot so it is triageable and fixable.

It is the visual sibling of `code-review` — same 0–4 severity scheme and
"router + dimensions" discipline — but the input is **rendered pixels**.

It absorbs the best of: shiplightai *Design Review* (5-phase flow + regression
guards), mastepanoski `nielsen-heuristics-audit` (Nielsen 10 + 0–4 severity),
Anthropic *frontend-design* (atomic-fix + before/after ethos), WCAG 2.2 / POUR,
Jakob Nielsen's 10 heuristics, Don Norman, and the APCA contrast model — plus
three dimensions the generic skills omit: **language/i18n consistency**,
**no internal-jargon leak**, and **error-shaped empty states**.

## When to invoke

Trigger keywords (any of):
- "review the UI / UX", "UX review", "UI review", "design review"
- "audit the interface / screens / pages", "check the UX/usability"
- "is this UI consistent / accessible / on-brand", "a11y review of the UI"

Do **not** use this for source-level audits (use `code-review`) or for
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
3. **Analyze** — read each screenshot and walk the six dimension groups in
   `dimensions.md`. For each issue: dimension · severity 0–4 · the screenshot ·
   what's wrong · the concrete fix. Flag what a screenshot *cannot* prove
   (exact contrast, focus order, keyboard, motion, ARIA) → recommend an
   automated a11y engine (axe/pa11y) for those.
4. **Report** — emit the triageable report in `report-template.md`: ✅ strengths,
   then findings sorted by severity, each with a screenshot ref + fix, + summary
   counts. Be honest; don't pad. Group by surface or by dimension, whichever
   reads clearer for the set.
5. **Guard** *(optional, on request)* — turn the top findings into regression
   guards in the user's own stack (`regression-guards.md`), and/or hand the fix
   list to a planning/TDD flow. This skill reviews; it does not silently edit.

## The six dimensions (one line each — full catalogue in `dimensions.md`)

1. **Usability** — Nielsen's 10 (visibility of status, match to real world, user
   control/undo, consistency, error prevention, recognition>recall, …).
2. **Accessibility** — WCAG 2.2 POUR: contrast (AA 4.5:1 / 3:1; APCA), target
   size (≥24px), focus visibility, colour-not-sole-signifier, semantics.
3. **Visual design** — hierarchy, spacing/rhythm/alignment, typographic scale,
   **colour semantics** (red=danger, not the primary "create"), density/overflow.
4. **Content & language** — **i18n consistency** (one language per surface, no
   mixed EN/IT in titles/labels/buttons/columns), **no internal-jargon leak**
   (class-name titles like "X Page", ticket/milestone codes, file/script names,
   raw config keys, UUIDs, stack traces, lorem/faker data), clear microcopy.
5. **State & data coverage** — empty states that **guide, not alarm** (no scary
   X/red for "nothing yet"); loading; actionable errors; first-run; and the
   data extremes zero / one / many / very-long (overflow, truncation, wrap).
6. **Responsive** — per-breakpoint layout integrity: no overflow/clipping, sane
   reflow, touch ergonomics on mobile.

## Severity (Nielsen 0–4)

`0` not a problem · `1` cosmetic (fix if time) · `2` minor · `3` major (fix
soon) · `4` catastrophic (must fix before ship). Assign per finding; sort the
report by it. Rubric detail in `dimensions.md`.

## Honesty rules

- Every finding cites a **specific screenshot** and a **concrete fix** — no vague
  "improve the spacing".
- State what the screenshot **can't** verify and route it to a live/automated
  check; don't assert a11y pass/fail you can't see.
- Call out **strengths** too — a review that's all ❌ is not trustworthy.
- Stay generic: the same checklist must work for any web UI in any framework.
