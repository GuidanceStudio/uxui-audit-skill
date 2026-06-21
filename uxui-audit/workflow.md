# Workflow — the five phases in detail

Read this before running a real review. Each phase has a goal and a checklist.

---

## 1 · Scope

Goal: know exactly what to capture and what "good" means *for this product*,
before taking a single screenshot.

Establish with the user (ask, don't assume):

- **Surfaces** — the list of URLs/routes (or components) to review. If the app
  is large, agree a representative cut: the highest-traffic flows + any screen
  the user is worried about. Get the auth-gated ones too.
- **Key states** — which screens have meaningful empty / filled / error / loading
  states worth capturing.
- **Viewports** — default trio: mobile `390×844`, tablet `768×1024`, desktop
  `1440×900`. Adjust to the product's real audience.
- **Audience & language** — who uses it, and the **expected UI language(s)**.
  Write this down — it's the yardstick for the i18n dimension (e.g. "UI must be
  Italian end-to-end").
- **Brand invariants** — primary colour, font, logo, tone — so you can judge
  consistency rather than guess.
- **Capture method** — Playwright script, Playwright MCP, or user-supplied PNGs
  (see `capture.md`). Confirm the requirement is installed.

Output of this phase: a short scope note (surfaces × viewports × states, the
language/brand yardstick, the capture method).

## 2 · Capture

Goal: a clean set of screenshots, one per surface × viewport (× state where it
matters), in a per-run folder. **Never modify the app to capture** — review it
as it ships.

- Use `capture.md` for the exact method + commands.
- Name files predictably: `<surface>-<viewport>[-<state>].png`.
- Capture full-page where the surface scrolls (don't miss below-the-fold).
- For auth-gated UIs, set up `storageState` once (see `capture.md`).
- Sanity-check the shots opened correctly — a captured **error page** (blank,
  500, login bounce) is itself a finding, not a capture failure to hide.
- For User Journey (D9), capture sequential screens in a flow path — don't just
  capture isolated pages. A checkout or signup flow needs step-by-step shots.

Output: `./.uxui-audit-runs/<timestamp>/` (or a folder the user points at) full
of screenshots.

## 3 · Analyze

Goal: honest, specific findings tied to screenshots.

- **Read every screenshot** (the agent's image input). For each, walk the thirteen
  groups in `dimensions.md`.
- Capture once, review against all dimensions — don't re-capture per dimension.
- Record each issue as: `dimension · severity 0–4 · screenshot · what's wrong ·
  concrete fix`. The fix must be actionable ("title shows the class name
  'Users Page'; set an Italian page title 'Utenti'"), never vague.
- **Note strengths** as you go (✅) — they calibrate the audit and tell the user
  what not to touch.
- **Mark the limits**: when a check needs the DOM/live (exact contrast, focus
  order, keyboard, motion, ARIA, gesture fluidity, actual undo behavior), record
  it as "needs axe/pa11y/live" rather than guessing pass/fail.
- **Cross-surface checks**: compare screens for consistency (same concept named
  the same way, same button placement, same language). Cite both screenshots.
  Cross-surface findings belong to Usability §4, Content §4 (i18n), or Journey §9.
- Don't pad. A clean dimension is "clean".
Output: a findings list (internal), each triageable.

### Non-multimodal agent (model can't see images)

If the model doesn't accept images natively, use an image-description MCP tool
to convert each screenshot into text, then audit the text:

1. **If the model is multimodal** — use native image input. This is the
   preferred path. Skip this section.
2. **If an image-description MCP is available** on the host (e.g.
   `media_describe_image`, `describe_image`, `describe_image_from_file`) —
   use it. For each screenshot, call it with a prompt like:
   > "Describe this UI screenshot in detail: layout, all visible text, colors,
   > spacing/alignment, interactive elements, states (loading/empty/error),
   > any visual anomalies or broken elements."
3. **If no MCP is available** — suggest the user install one. Three public
   options:
   - `mcp-image-recognition` (npm) — Anthropic/OpenAI vision, file + base64
     input, built-in Tesseract OCR.
   - `ai-image-mcp-server` — GPT-4o Vision, supports targeted prompts
     (e.g. "describe layout issues").
   - `z-ai-vision-mcp` — GLM-4.6V, UI-specific tools:
     `extract_text_from_screenshot`, `diagnose_error_screenshot`,
     `ui_diff_check`.

**Quality caveats vs native vision:**

| What's lost | Impact |
|---|---|
| Exact contrast ratios | Can't judge WCAG contrast; flag everything as "needs axe" |
| Color-semantic precision | May misread brand colors or miss red-for-danger mismatches |
| Text accuracy | May hallucinate or paraphrase labels, nav items, error text |
| Pixel-level alignment | Can't spot 1px misalignments or subtle spacing drift |
| Layout nuance | May miss z-order issues, overlapping elements, clipping |
| Icon recognition | May not identify specific icons or their semantic meaning |

Still effective for: nav structure, IA, content/i18n consistency, state
coverage, dark patterns, error-message quality, journey coherence, cognitive
load — anything language- or structure-based. Flag the lost categories as
"needs live / image-capable pass" in the report.

## 4 · Report

Goal: a report the user can act on immediately.

- Use `report-template.md`.
- Lead with **✅ strengths**, then **findings sorted by severity** (4 → 1), each
  with: severity, surface, dimension, the issue, the screenshot ref, the fix.
- Add a **summary table** (counts per severity, counts per dimension) so the
  user sees the shape at a glance.
- Group by surface or by dimension — whichever reads clearer for this set
  (many cross-cutting findings → group by dimension; few surfaces → by surface).
- Be honest about coverage: list what was NOT reviewed (surfaces skipped,
  a11y deferred to axe, states not reachable, live-only checks).

Output: the markdown report (and the screenshots it references).

## 5 · Guard *(optional, on request)*

Goal: stop the top findings from regressing — in the user's own stack.

- Only on request. This skill **audits**; it does not silently edit the app.
- For each high-severity fix, suggest a regression guard using
  `regression-guards.md` (framework-agnostic): assert the corrected title text,
  assert a forbidden substring is absent, run axe for contrast/ARIA, etc.
- Offer to hand the prioritised fix list to a planning/TDD flow (e.g. a devplan
  skill) rather than fixing inline — keeps audit and remediation separated.

Output: a short list of guard tests to add (in the user's framework), or a
handoff to a fix plan.
