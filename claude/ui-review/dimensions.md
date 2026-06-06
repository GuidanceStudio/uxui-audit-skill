# Dimensions — the UI/UX review catalogue

Six dimension groups. For each item: what to look for **in a screenshot**, and
the typical severity band. Walk every group over every surface. A finding =
`dimension · severity · surface/screenshot · what's wrong · concrete fix`.

A screenshot proves *layout, content, colour, state*. It does **not** prove
keyboard order, focus management, motion, exact contrast ratios, or ARIA — for
those, say so and route to an automated engine (axe-core / pa11y) or a live pass.

---

## Severity rubric (Nielsen 0–4)

Rate by **impact × frequency**, not by how easy it is to fix.

| | Meaning | Examples |
|---|---|---|
| **0** | Not a usability problem | — |
| **1** | Cosmetic — fix only if time allows | 1px misalignment; a slightly off shade |
| **2** | Minor — low priority | a non-ideal label; mild spacing inconsistency |
| **3** | Major — high priority, fix soon | mixed-language UI; unreadable low-contrast text; primary action not findable |
| **4** | Catastrophic — must fix before ship | broken/blank screen; error-page leak to users; data loss with no undo; illegible content |

When unsure between two bands, pick the higher one if it touches a primary task
or first impression.

---

## 1 · Usability — Nielsen's 10 heuristics

1. **Visibility of system status** — does the UI show where you are, what's
   selected, what's loading/saving, progress? Look for active-nav state,
   spinners, toasts, "saved" confirmations.
2. **Match between system and the real world** — labels in the user's language
   and mental model, not developer/system terms.
3. **User control & freedom** — visible cancel/close/back/undo on every modal,
   form, destructive action. No dead-ends.
4. **Consistency & standards** — same concept = same word, icon, colour, place
   everywhere (e.g. the nav label and the page title agree). Buttons in
   consistent positions.
5. **Error prevention** — confirmations on destructive/irreversible actions;
   disabled states with a reason; constrained inputs.
6. **Recognition over recall** — options visible rather than memorised; helper
   text and examples present where a format is non-obvious.
7. **Flexibility & efficiency** — shortcuts/filters/bulk actions for frequent
   tasks without harming novices.
8. **Aesthetic & minimalist design** — no noise competing with the primary
   content; every element earns its place.
9. **Help users recognise/recover from errors** — error messages are in plain
   language, say what happened and how to fix it (not a code/stack trace).
10. **Help & documentation** — contextual help/tooltips where needed; findable.

Typical bands: 3–4 for control/freedom and error recovery failures; 2–3 for
consistency; 1–2 for minimalism nits.

## 2 · Accessibility — WCAG 2.2, POUR

- **Perceivable**
  - **Contrast** — body text ≥ 4.5:1, large text/UI ≥ 3:1 (or APCA equivalent).
    Watch for light-grey-on-white, white-on-light, brand-colour text on a tinted
    bg. *A screenshot shows obvious failures; verify exact ratios with a tool.*
  - **Colour is not the only signifier** — status/required/error also conveyed by
    text or icon, not hue alone.
  - **Text alternatives / labels** — icon-only controls have a visible or
    accessible label (flag icon-only buttons for an ARIA check).
- **Operable**
  - **Target size** — interactive targets ≥ 24×24 CSS px (WCAG 2.2 AA), ~44 px
    recommended on touch. Watch tiny icon buttons / dense table actions.
  - **Focus visible** — *can't verify from a static shot* → route to live/axe.
  - **Keyboard reachable** — *can't verify from a shot* → route to live/axe.
- **Understandable** — consistent navigation/identification; clear labels and
  instructions; predictable behaviour.
- **Robust** — semantic structure (one h1, logical heading order), valid
  components → route the un-seeable parts to axe-core / pa11y.

Typical bands: 4 for illegible contrast on core content; 3 for sub-minimum
targets on primary actions; 2 for icon-only labels pending a11y verification.

## 3 · Visual design

- **Hierarchy** — is the primary action/most-important content the most
  prominent? Can you find the main CTA in < 2 seconds?
- **Spacing, rhythm, alignment** — consistent gutters and vertical rhythm;
  elements aligned to a grid; no cramped or floating bits.
- **Typography** — a limited, consistent type scale; readable size (~16px body)
  and line length (~45–75 chars); not too many weights/families.
- **Colour semantics** — red = danger/destructive (a red *create/save* button
  reads as dangerous); green = success; amber = warning; one brand primary used
  consistently. Flag semantic mismatches.
- **Density & overflow** — tables/cards that overflow horizontally, force
  scroll, or truncate key columns; content clipped by a container.
- **Brand consistency** — logo, palette, font, corner radius, iconography
  coherent across surfaces.
- **Imagery/iconography** — icons consistent in style/weight and meaningful.

Typical bands: 3 for an unfindable primary action or horizontal overflow on a
core table; 2 for colour-semantic mismatch; 1 for minor rhythm nits.

## 4 · Content & language  *(the differentiators)*

These are routinely missed by generic heuristic skills, yet dominate real-world
"this feels unpolished" impressions.

- **i18n / language consistency** — within a surface, **one** language.
  Cross-check title vs nav vs breadcrumb vs buttons vs column headers vs
  placeholders vs empty-states. Mixed EN/IT (or any pair) in one screen, or a
  button half-translated ("New Assistente"), is a finding. Severity 3 — it
  screams "unfinished" on first impression.
- **No internal-jargon leak** — user-facing text must not contain:
  - class-derived titles ("…Page", "ListUsers"), route/component names;
  - ticket/milestone/issue codes ("UX-NAV-1", "JIRA-123");
  - file names, paths, script names, migration/seed names;
  - raw config keys (`pre_warm_pool_max`), env-file names, deploy commands;
  - internal IDs / UUIDs / slugs shown as the primary identifier;
  - stack traces / error class names / SQL on an error surface;
  - placeholder/lorem/faker data shipped in a demo or production build.
  Severity 2–4 depending on whether it's a stray helper (2) or a config/file
  name shown to a customer (3) or a stack trace on a user error page (4).
- **Microcopy quality** — labels are human and unambiguous; terminology is
  consistent (one name per concept); empty/error copy is specific and helpful;
  no truncated/clipped strings.

## 5 · State & data coverage

The states teams forget. Capture and review each where reachable.

- **Empty state** — must **guide, not alarm**: a neutral icon + "nothing here
  yet" + a next action. A red/✕ "error-shaped" empty state, or a bare
  English "No records", is a finding (severity 2–3).
- **Loading** — skeletons/spinners, no layout jump, no frozen-looking blank.
- **Error** — actionable, plain-language, with a recovery path; never a raw
  exception (that's a severity-4 leak — see §4).
- **First-run / onboarding** — does a brand-new account see something sensible?
- **Data extremes** — review **zero / one / many / very-long**: long names
  wrapping or truncating, huge lists/pagination, overflowing tables, 0-value
  formatting.
- **Partial/degraded** — missing avatar, absent optional field, offline.

## 6 · Responsive & cross-viewport

Review the same surfaces at each viewport (mobile / tablet / desktop):

- No horizontal overflow or clipped content; layout reflows (no fixed desktop
  widths forcing a tiny mobile zoom).
- Nav collapses sensibly (hamburger/drawer) and is reachable.
- Touch targets and spacing comfortable on mobile (≥ ~44px, no crowding).
- Tables become cards/scrollers rather than overflowing.
- Critical actions remain visible (not pushed off-screen or under the fold
  without affordance).

Typical bands: 3–4 for content unreachable/broken on mobile; 2 for awkward but
usable reflow; 1 for minor mobile spacing.

---

## Applying it

For each surface, produce findings across all six groups (most will be ✅ — note
those too). Don't invent problems; if a group is clean, say "clean" and move on.
Cross-surface findings (e.g. an inconsistency between two screens) belong to
**Usability §4 consistency** or **Content §i18n** — cite both screenshots.
