# Brand & Visual Identity

The Villa Wolf UI follows the studio's logo: a **minimalist, monochrome black & white** identity with
a circular ring motif. This guides the Flutter theme built in Iteration 4.

## Logo

- Wordmark **VILLAWOLF** (uppercase, tight letter-spacing) with the tagline **hair studio**
  (lowercase, light weight) beneath it.
- A thin **white circular ring** on a black field is the signature graphic element — reuse it as a
  loading indicator, avatar frame, and section accent.
- Place the asset at `frontend/villawolf_app/assets/branding/villawolf-logo.png` (added with the
  Flutter app). A copy for the README can live at `docs/assets/villawolf-logo.png`.

## Palette (monochrome-first)

| Token | Value | Use |
| --- | --- | --- |
| `ink` | `#0B0B0C` | Primary background, top bar, sidebar |
| `surface` | `#161617` | Cards, sheets |
| `surfaceAlt` | `#1F1F22` | Hover/elevated surfaces |
| `line` | `#2A2A2E` | Borders, dividers, the ring |
| `onInk` | `#F5F5F4` | Primary text on dark |
| `muted` | `#9A9A9E` | Secondary text, captions |
| `accent` | `#C8B68A` (optional champagne) | Sparingly, only for a premium highlight |

Lead with black/white; the champagne accent is optional and used minimally. Light mode (for web) is a
clean inverse: near-white surfaces, ink text, the same ring motif.

## Status colours (appointments)

Keep them desaturated so they sit well on the monochrome base:
`Confirmed/Completed` → muted green · `Pending` → amber · `Cancelled/NoShow` → muted red ·
`InProgress` → soft blue.

## Type & shape

- Type: a clean grotesque/sans (e.g. Inter or Montserrat) — uppercase + wide tracking for the
  wordmark and section titles, regular for body.
- Generous spacing, hairline dividers, rounded-but-restrained corners (8–12px). Premium and calm,
  not flashy.
