# Design System Master File — Walleto

> Page overrides in `pages/` win over this file.

---

**Project:** Walleto  
**Direction:** **Noir Glass** (clean break from Ledger Bento / Soft Navy / Candy)  
**ui-ux-pro-max:** Personal Finance Tracker → *Glassmorphism + Dark Mode (OLED)* + *Modern Dark (Cinema Mobile)*  
**Dials:** Variance **9** · Motion **6** · Density **5**  
**Mode:** **Dark-primary** (not light stone, not forest gold)

---

## Why this replaces Ledger Bento

Previous directions still read as “light fintech template.” Product DB primary style for expense trackers is **dark OLED + glass**. Cinema Mobile adds atmospheric depth without candy chrome.

## Thesis

Night money console: deep charcoal stage, frosted elevated panels, **one electric teal accent**, typography-led balance hero.

| Do | Don't |
|----|--------|
| Dark `#050506` → `#0A0A0F` | Light stone / forest ink / gold ledger |
| Glass hairline `rgba(255,255,255,0.08)` | Pastel cyan/yellow, purple neon crypto |
| Teal accent `#2DD4BF` | Navy SaaS blue, gold Swiss underline |
| Space Grotesk + DM Sans | Nunito, IBM Plex soft-bank, Jakarta+gold |
| Huge balance as type hero | Identical stacked light cards |

---

## Color

| Role | Hex | Const |
|------|-----|--------|
| Background deep | `#050506` | `scaffoldBackgroundColor` |
| Elevated / card | `#121214` | `surfaceColor` |
| Pure white (rare) | `#FFFFFF` | `whiteColor` |
| Text | `#EDEDEF` | `blackColor` |
| Muted | `#8A8F98` | `darkGreyColor` |
| Border / hairline | `#2A2A2E` | `frameColor` |
| Primary / CTA | `#2DD4BF` | `primaryColor` |
| On primary | `#042F2E` | button text |
| Primary soft | `#0D3D38` | `primaryShadeColor` |
| Primary wash | `#0A2825` | `primaryShade1Color` |
| Accent secondary | `#5EEAD4` | `secondaryColor` |
| Income | `#34D399` | `greenColor` |
| Expense | `#FB7185` | `redColor` |
| Field | `#1A1A1D` | `fieldFillColor` |
| Overlay | `rgba(0,0,0,0.55)` | `backgroundOverlayColor` |

## Typography

- **Display / amounts:** Space Grotesk (500–700), tight tracking on heroes  
- **Body / UI:** DM Sans (400–600)  
- Amounts stay Space Grotesk (tabular feel via weight), not playful rounded fonts  

## Layout (Home)

1. Ambient dark scaffold (optional soft teal blob opacity ≤0.08 — decorative, not candy)  
2. **Type hero:** micro label + oversized balance  
3. Glass row: Income | Expense pills  
4. Elevated panels for wallets / chart / recent (r=16, hairline border)  
5. Floating dark tab bar + teal FAB  

## Auth

Dark full-bleed, wordmark, Space Grotesk welcome, teal CTA, glass fields — no illustration carnival.

## Motion

180–280ms, ease out; press scale ~0.97 on tiles; no elastic tabs.

## Anti-patterns

Light forest/gold Ledger, soft navy SaaS, candy pastels, purple glow walls, neumorphic clay grey.
