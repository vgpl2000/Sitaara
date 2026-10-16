---
version: alpha
name: Sitaara
description: |
  Sitaara's design system embodies a warm, approachable, and trustworthy
  aesthetic designed to comfort and empower Indian parents navigating early
  childhood. The visual language combines rich, saturated purples with bold
  accent yellows to create energy and confidence, while clean typography and
  ample whitespace prevent the interface from feeling overwhelming—reflecting
  the brand's core promise of "simplifying parenthood." The palette leans into
  jewel tones that convey expertise and care, balanced by luminous accents that
  draw attention to key moments of action. Gradients are used sparingly but
  deliberately to add depth and guide the eye through the page, creating a sense
  of progression and discovery. The overall mood is inviting, modern, and
  grounded in the brand's mission to reduce parental anxiety through
  evidence-based guidance.
source:
  url: "https://sitaara.club/"
  pagesAnalyzed: 1
  extractedAt: 2026-10-16
  tokensMeasured: true
colors:
  primary: "#000000"
  link: "#0000EE"
  canvas: "#FFFFFF"
  surface-alt: "#462E91"
  on-primary: "#FFFFFF"
  ink: "#0B0B0B"
  body: "#7D6161"
  muted: "#E6DCDC"
  accent-1: "#FFCB05"
  accent-2: "#3D0000"
  accent-3: "#FCFADF"
  accent-4: "#8AC340"
typography:
  display:
    fontFamily: Poppins
    fontSize: 48px
    fontWeight: 500
    lineHeight: 1.1
    letterSpacing: 0px
  heading-lg:
    fontFamily: Poppins
    fontSize: 28px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0px
  heading-md:
    fontFamily: Poppins
    fontSize: 26px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0px
  heading-sm:
    fontFamily: Poppins
    fontSize: 22px
    fontWeight: 400
    lineHeight: 1.2
    letterSpacing: 0px
  heading-xs:
    fontFamily: Satoshi
    fontSize: 13px
    fontWeight: 700
    lineHeight: 1.4
    letterSpacing: 0.52px
    textTransform: uppercase
  body-lg:
    fontFamily: Poppins
    fontSize: 18px
    fontWeight: 500
    lineHeight: 1.5
    letterSpacing: 0px
  body-lg-strong:
    fontFamily: Poppins
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.5
    letterSpacing: 0px
  body-lg-tight:
    fontFamily: Poppins
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.3
    letterSpacing: 0px
  body-md:
    fontFamily: Poppins
    fontSize: 16px
    fontWeight: 300
    lineHeight: 1.5
    letterSpacing: 0px
  body-md-strong:
    fontFamily: Poppins
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.3
    letterSpacing: 0px
  body-sm:
    fontFamily: Poppins
    fontSize: 13px
    fontWeight: 400
    lineHeight: 1.7
    letterSpacing: 0px
  nav:
    fontFamily: sans-serif
    fontSize: 12px
    fontWeight: 400
    letterSpacing: 0px
rounded:
  none: 0px
  xs: 24px
  full: 9999px
spacing:
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 20px
  xl: 24px
  xxl: 32px
  xxxl: 40px
  section: 60px
  band: 80px
elevationStrategy: color-blocking
themes:
  derived: dark   # the other theme is the site's measured palette
  light:
    bg: "#FFFFFF"
    surface: "#462E91"
    surfaceRaised: "#442D8C"
    text: "#0B0B0B"
    textMuted: "#7D6161"
    border: "#E2E2E2"
    accent: "#0000EE"
    accentFg: "#FFFFFF"
    focusRing: "#0000EE"
    elevation: shadow
  dark:
    bg: "#090916"
    surface: "#181824"
    surfaceRaised: "#242430"
    text: "#F5F5FE"
    textMuted: "#9B9BA6"
    border: "#30303B"
    accent: "#6969FF"
    accentFg: "#090916"
    focusRing: "#4141FF"
    elevation: "border+surface"
  contrastFailures:
    - "light: text on surface = 1.93:1 (needs 4.5:1)"
gradients:
  - context: hero
    kind: linear
    value: "linear-gradient(rgb(71, 47, 145) 0%, rgb(71, 47, 145) 34.1269%, rgb(216, 214, 227) 79.8758%, rgb(255, 255, 255) 100%)"
  - context: section
    kind: linear
    value: "linear-gradient(rgba(255, 255, 255, 0) 37.6513%, rgba(0, 0, 0, 0.8) 100%)"
  - context: section
    kind: linear
    value: "linear-gradient(rgb(70, 46, 145) 0%, rgb(255, 255, 255) 100%)"
components:
  button-filled:
    typography: "{typography.nav}"
    textColor: "{colors.link}"
    height: 51px
    padding: "12px 32px 12px 32px"
    rounded: 16px
    backgroundColor: "{colors.accent-1}"
  button-icon:
    typography: "{typography.nav}"
    textColor: "{colors.primary}"
    height: 40px
    rounded: 40px
    backgroundColor: "rgba(0, 0, 0, 0.2)"
  button-icon-sm:
    typography: "{typography.nav}"
    textColor: "{colors.primary}"
    height: 28px
    padding: "10px 4px 10px 10px"
  navigation:
    typography: "{typography.nav}"
    textColor: "{colors.primary}"
    height: 66px
    padding: "0px 40px 0px 40px"
  footer:
    typography: "{typography.nav}"
    textColor: "{colors.primary}"
    padding: "80px 0px 40px 0px"
    rounded: "40px 40px 0px 0px"
    backgroundColor: "{colors.surface-alt}"
  link:
    typography: "{typography.nav}"
    textColor: "{colors.link}"
    padding: "12px 20px 12px 20px"
    rounded: 40px
    backgroundColor: "{colors.surface-alt}"
  link-sm:
    typography: "{typography.nav}"
    textColor: "{colors.link}"
    padding: "12px 20px 12px 20px"
    rounded: 187px
    backgroundColor: "{colors.canvas}"
states:
breakpoints:
  - width: 375
    containerWidth: 356
    gridColumns: 1
    navLinksVisible: 1
    menuToggleVisible: false
    headingPx: 40
    bodyPx: 12
    sectionPaddingX: 8
  - width: 768
    containerWidth: 691
    gridColumns: 1
    navLinksVisible: 1
    menuToggleVisible: false
    headingPx: 40
    bodyPx: 12
    sectionPaddingX: 8
  - width: 1024
    containerWidth: 922
    gridColumns: 1
    navLinksVisible: 1
    menuToggleVisible: false
    headingPx: 48
    bodyPx: 12
    sectionPaddingX: 8
  - width: 1280
    containerWidth: 1200
    gridColumns: 1
    navLinksVisible: 5
    menuToggleVisible: false
    headingPx: 48
    bodyPx: 12
    sectionPaddingX: 8
  - width: 1440
    containerWidth: 1200
    gridColumns: 1
    navLinksVisible: 5
    menuToggleVisible: false
    headingPx: 48
    bodyPx: 12
    sectionPaddingX: 8
coverage:
  statesFound: 11
  gradientsFound: 3
  rolesUnassigned: 4
  archetypesUnnamed: 0
  archetypesDetected: 0
  responsiveMeasured: true
  stylesheetsBlocked: false
  semanticRampDeclared: false
---

# Design System Inspired by Sitaara

## 1. Visual Theme & Atmosphere

Sitaara's design system embodies a warm, approachable, and trustworthy aesthetic designed to comfort and empower Indian parents navigating early childhood. The visual language combines rich, saturated purples with bold accent yellows to create energy and confidence, while clean typography and ample whitespace prevent the interface from feeling overwhelming—reflecting the brand's core promise of "simplifying parenthood." The palette leans into jewel tones that convey expertise and care, balanced by luminous accents that draw attention to key moments of action. Gradients are used sparingly but deliberately to add depth and guide the eye through the page, creating a sense of progression and discovery. The overall mood is inviting, modern, and grounded in the brand's mission to reduce parental anxiety through evidence-based guidance.

**Key Characteristics**

- Rich, saturated purple (`{colors.surface-alt}` — `#462E91`) as the primary brand surface, evoking trust and expertise
- Bold yellow accent (`{colors.accent-1}` — `#FFCB05`) for high-emphasis CTAs and highlights, creating visual pop
- Clean, light backgrounds (`{colors.canvas}` — `#FFFFFF`) paired with warm neutrals for approachable readability
- Generous whitespace and subtle gradients to guide focus without overwhelming
- Pill-shaped and sharply-angled buttons reflecting modern, contemporary interaction patterns
- Poppins typeface delivering warm, rounded letterforms that feel friendly and accessible

## 2. Color Palette & Roles

### Primary
- **Brand / Primary** (`{colors.primary}` — `#000000`): Primary CTA fills, brand accent elements, active states, and high-contrast headings on light surfaces

### Accent Colors
- **Primary Highlight** (`{colors.accent-1}` — `#FFCB05`): High-emphasis call-to-action buttons, decorative section headers, and attention-grabbing accents
- **Decorative Deep Red** (`{colors.accent-2}` — `#3D0000`): Decorative accent; no assigned functional role
- **Decorative Light Cream** (`{colors.accent-3}` — `#FCFADF`): Decorative accent; no assigned functional role
- **Decorative Sage Green** (`{colors.accent-4}` — `#8AC340`): Decorative accent; no assigned functional role

### Interactive
- **Link Color** (`{colors.link}` — `#0000EE`): Inline hyperlinks and link-styled interactive elements

### Neutral Scale
- **Canvas / Background** (`{colors.canvas}` — `#FFFFFF`): Default page background, card surfaces, and on-brand text container
- **Surface Alt** (`{colors.surface-alt}` — `#462E91`): Section band backgrounds, footer surface, and alternating surface treatment
- **Ink / Primary Text** (`{colors.ink}` — `#0B0B0B`): Headings and primary body text, ensuring high contrast and readability
- **Body Text** (`{colors.body}` — `#7D6161`): Body copy and secondary narrative text
- **Muted / Caption Text** (`{colors.muted}` — `#E6DCDC`): Captions, hints, secondary text, and low-emphasis labels

## 3. Typography Rules

### Font Family

**Primary:** Poppins (`font-family: 'Poppins', sans-serif`)
Warm, rounded, approachable sans-serif; used for all headings, navigation, and primary content.

**Secondary:** Satoshi (`font-family: 'Satoshi', sans-serif`)
Modern, geometric sans-serif; used sparingly for uppercase small labels and metadata.

**Fallback:** `sans-serif`
System sans-serif as final fallback.

### Hierarchy

| Role | Font | Size | Weight | Line Height | Letter Spacing | Notes |
|---|---|---|---|---|---|---|
| Display | Poppins | 48px | 500 | 1.1 | 0px | Hero headlines, maximum emphasis |
| Heading MD | Poppins | 26px | 600 | 1.2 | 0px | Section headers, prominent blocks |
| Heading LG | Poppins | 28px | 400 | 1.4 | 0px | Feature headers, secondary prominence |
| Heading SM | Poppins | 22px | 400 | 1.2 | 0px | Card titles, subsection headers |
| Heading XS | Satoshi | 13px | 700 | 1.4 | 0.52px | Labels, tags; uppercase variant |
| Body MD | Poppins | 16px | 300 | 1.5 | 0px | Standard body copy |
| Body MD Strong | Poppins | 16px | 400 | 1.3 | 0px | Emphasized body text |
| Body LG | Poppins | 18px | 500 | 1.5 | 0px | Larger body, link text |
| Body LG Strong | Poppins | 18px | 600 | 1.5 | 0px | Strong emphasis, featured body |
| Body LG Tight | Poppins | 18px | 600 | 1.3 | 0px | Compact strong body text |
| Body SM | Poppins | 13px | 400 | 1.7 | 0px | Captions, small text, metadata |
| Navigation | sans-serif | 12px | 400 | not measured | 0px | Top-level navigation links |

### Principles

- Display size (`{typography.display}`) delivers maximum impact at 48px with moderate weight (500), ensuring headlines feel prominent but not heavy.
- Hierarchy uses weight and size in concert: headings lean on weight (600–700) while body relies on size (16–18px) and line height (1.5) for scanability.
- Body line heights (1.5–1.7) provide generous breathing room, reflecting the brand's philosophy of reducing overwhelm.
- Satoshi's uppercase treatment and tight tracking (`0.52px` on `{typography.heading-xs}`) signal metadata and labels distinctly from body content.
- Navigation uses a neutral sans-serif at `{typography.nav}` (12px, weight 400) for compact, readable menu items.

## 4. Component Stylings

### Buttons

**Primary Filled Button**
- Background: `{colors.accent-1}` (`#FFCB05`)
- Text Color: `{colors.link}` (`#0000EE`)
- Font: sans-serif, 12px, weight 400, line-height normal
- Padding: `12px 32px`
- Height: 51px
- Border Radius: 16px
- Border: none
- Box Shadow: none
- Width: 200px (default width; adjust per layout)

**Icon Button**
- Background: `rgba(0, 0, 0, 0.2)`
- Text Color: `{colors.ink}` (`#0B0B0B`)
- Font: sans-serif, 12px, weight 400, line-height normal
- Padding: `0px`
- Height: 40px
- Width: 40px
- Border Radius: 40px (circular)
- Border: none
- Box Shadow: none

**Icon Button Small**
- Background: `rgba(0, 0, 0, 0)` (transparent)
- Text Color: `{colors.ink}` (`#0B0B0B`)
- Font: sans-serif, 12px, weight 400, line-height normal
- Padding: `10px 4px 10px 10px`
- Height: 28px
- Width: 22px
- Border Radius: 0px (sharp)
- Border: none
- Box Shadow: none

### Navigation

**Default Navigation Bar**
- Background: `rgba(0, 0, 0, 0)` (transparent)
- Text Color: `{colors.ink}` (`#0B0B0B`)
- Font: sans-serif, 12px, weight 400, line-height normal
- Padding: `0px 40px`
- Height: 66px
- Border Radius: 0px
- Border: none
- Box Shadow: none
- Full width (1440px at desktop)

### Links

**Link Default**
- Background: `{colors.surface-alt}` (`#462E91`)
- Text Color: `{colors.link}` (`#0000EE`)
- Font: sans-serif, 12px, weight 400, line-height normal
- Padding: `12px 20px`
- Height: 52px
- Width: 124px (default; scale per context)
- Border Radius: 40px (pill-shaped)
- Border: none
- Box Shadow: none

**Link Default Small**
- Background: `{colors.canvas}` (`#FFFFFF`)
- Text Color: `{colors.link}` (`#0000EE`)
- Font: sans-serif, 12px, weight 400, line-height normal
- Padding: `12px 20px`
- Height: 51px
- Width: 176px
- Border Radius: 187px (pill-shaped)
- Border: none
- Box Shadow: none

### Footer

**Default Footer**
- Background: `{colors.surface-alt}` (`#462E91`)
- Text Color: `{colors.ink}` (`#0B0B0B`)
- Font: sans-serif, 12px, weight 400, line-height normal
- Padding: `80px 0px 40px 0px`
- Height: 484px (approx.)
- Width: 1440px (full)
- Border Radius: `40px 40px 0px 0px` (rounded top corners)
- Border: none
- Box Shadow: none

## 5. Layout Principles

### Spacing System

Sitaara employs a precise 4px base unit, scaling logarithmically to accommodate everything from fine micro-interactions to large section breaks. All spacing decisions route through this scale to maintain rhythm and predictability.

- `{spacing.xxs}` = 4px — Micro-spacing between inline elements
- `{spacing.xs}` = 8px — Tight padding in compact components
- `{spacing.sm}` = 12px — Button and input padding
- `{spacing.md}` = 16px — Standard component padding and inter-element spacing
- `{spacing.lg}` = 20px — Larger component padding
- `{spacing.xl}` = 24px — Card and container padding
- `{spacing.xxl}` = 32px — Large section padding
- `{spacing.xxxl}` = 40px — Extra-large section spacing
- `{spacing.section}` = 60px — Major section breaks (horizontal or vertical)
- `{spacing.band}` = 80px — Full-width band sections with prominent breathing room

### Grid & Container

- **Max Content Width:** 1200px (measured at 1280px+ viewport; constrains main content)
- **Section Padding (Horizontal):** `{spacing.xs}` (8px) on mobile (375–1024px); maintained through desktop to allow responsive gutters
- **Full-width Sections:** Footer, hero band, and alternating purple sections extend edge-to-edge at all breakpoints
- **Single-column Layout:** The site employs a single-column grid across all measured breakpoints; multi-column grid components are not present in this site

### Whitespace Philosophy

Whitespace is treated as a first-class design tool, not a residue. Large breathing room around headlines, generous line heights (1.5–1.7 on body text), and ample section padding (`{spacing.section}` and `{spacing.band}`) reduce cognitive load and align with the brand's promise to simplify parenthood. Margins between sections prevent visual crowding; internal padding within cards and containers ensures content doesn't feel trapped.

### Border Radius Scale

- `{rounded.none}` = 0px — Sharp-cornered buttons (button filled), images, and minimalist components
- `{rounded.xs}` = 24px — Slightly softened containers and cards, providing subtle friendliness
- `{rounded.full}` = 9999px — Pill-shaped buttons (link defaults) and perfectly circular icon buttons

### Border Widths

No border-width values were extracted from the site's measured styles. All observed components use `border: 0px none` or no border at all. Do not assume a border system; if borders are needed, use `1px solid` with the appropriate color role as a default.

## 6. Depth & Elevation

### Elevation Strategy

Sitaara uses **color-blocking** as its primary depth mechanism rather than layered shadows. Depth is conveyed through surface color changes — the rich purple (`{colors.surface-alt}` — `#462E91`) sections sit as visually distinct surfaces against the white canvas (`{colors.canvas}` — `#FFFFFF`). No measurable box-shadows were extracted from the site's components, indicating a flat, contemporary aesthetic that relies on color contrast and opacity to establish hierarchy.

| Level | Treatment | Use |
|---|---|---|
| Base / Flat | No shadow; opaque solid background | Primary buttons, text on canvas, standard surfaces |
| Elevated / Surface Alt | Background color shift to `{colors.surface-alt}` (`#462E91`) with full opacity | Section bands, footer, navigation overlays |
| Overlay / Transparency | Background color with `0.80` or `0.30` opacity | Interactive overlays, hover states, modal backdrops |

**Shadow Philosophy:**
The absence of shadows reflects a modern, flat design approach. Depth is achieved through deliberate color shifts and opacity layering rather than simulated 3D elevation. This keeps the interface clean and reduces visual noise—key to the brand's promise of simplifying the parental experience.

### Opacity Levels

- **Full Opacity** = 1.0 (100%) — All solid surfaces, text, and primary components
- **High Opacity** = 0.80 (80%) — Semi-transparent overlays, muted backgrounds
- **Mid Opacity** = 0.60 (60%) — Icon button backgrounds (`rgba(0, 0, 0, 0.2)` uses 20% opacity; recalculate as needed)
- **Low Opacity** = 0.30 (30%) — Subtle background tints, faded elements

### Z-index / Layering

- **Base** = 1 — Default stacking for standard page elements
- **Tier 2** = 2 — Elevated components (modals, dropdowns)
- **Tier 3** = 3 — Higher overlays and sticky elements
- **Toast / Topmost** = 2147483647 — Notifications and alerts that must sit above all other content

## 7. Do's and Don'ts

### Do

- **Use the purple (`{colors.surface-alt}` — `#462E91`) strategically** for full-width sections and footer to anchor the page and create visual rest points.
- **Pair body text (`{colors.body}` — `#7D6161`) with high line height** (1.5–1.7) to maintain readability and reduce cognitive strain—core to the brand's simplicity mission.
- **Apply yellow accent (`{colors.accent-1}` — `#FFCB05`) only to primary CTAs** ("Download App," "Get Started") to create a single, unmistakable call-to-action per section.
- **Maintain `{spacing.md}` (16px) or greater** between major content blocks to prevent crowding and support the "simplifying" ethos.
- **Use Poppins for all headings and navigation** to maintain warm, approachable tone; fallback to sans-serif only in extended body text where needed.
- **Employ pill-shaped buttons (`{rounded.full}` — 9999px) for secondary links and navigation** to soften interaction points.
- **Preserve generous padding inside buttons and cards** (`{spacing.sm}` to `{spacing.lg}`) so content breathes and feels uncluttered.

### Don't

- **Do not layer multiple shadows** or use blur effects; the system relies on color blocking, not 3D depth.
- **Do not use yellow (`{colors.accent-1}`) for body text or secondary elements**; reserve it exclusively for high-emphasis actions.
- **Do not reduce line height below 1.2** on headings or below 1.5 on body text; tight leading contradicts the brand's simplifying philosophy.
- **Do not apply the purple surface to text** — use it only for section backgrounds and containers.
- **Do not mix serif and sans-serif in the same hierarchy level**; Poppins and Satoshi each serve distinct roles (headings vs. labels).
- **Do not set interactive elements with sharp corners (`{rounded.none}`)** except for minimalist icon buttons; pill-shaped buttons feel more approachable and modern.
- **Do not invent semantic colors** (error red, success green); the site's extraction found no error/warning/success states, so do not fabricate them.

## 8. Responsive Behavior

### Breakpoints

| Breakpoint | Viewport Width | Content Width | Notable Changes |
|---|---|---|---|
| Mobile | 375px | 356px | Single column; section padding `{spacing.xs}` (8px); display text 40px |
| Tablet | 768px | 691px | Single column maintained; body text 12px; no layout shift |
| Desktop (small) | 1024px | 922px | Single column; display text remains 40px |
| Desktop (medium) | 1280px | 1200px (max constrained) | Display text increases to 48px; navigation shows 5 links; max width applied |
| Desktop (large) | 1440px | 1200px (max constrained) | Content unchanged from 1280px; full width reserved for gutters and edges |

### Touch Targets

- **Minimum touch target height:** 44px (inferred from button heights; primary filled button = 51px, link buttons = 51–52px)
- **Minimum touch target width:** 40px (icon buttons are `40px × 40px`)
- **Spacing between targets:** Maintain at least `{spacing.xs}` (8px) between adjacent interactive elements to prevent accidental mis-taps

### Collapsing Strategy

- **Mobile (375–768px):** Single column layout; sections stack vertically; section padding remains constant at 8px to preserve gutters
- **Transition (1024px):** Still single column; first display of desktop heading size (48px); navigation remains compact
- **Desktop (1280px+):** Content constrains to 1200px max width; 5 navigation links visible (from hidden/condensed state); hero section and full-width bands extend to viewport edges
- **No hamburger menu observed:** Navigation does not collapse into a toggle at any measured breakpoint; all links remain visible once expanded

## 9. Agent Prompt Guide

### Quick Color Reference

- **Primary CTA:** Brand Black (`{colors.primary}` — `#000000`) — used for emphasis and active states
- **CTA Button Fill:** Highlight Yellow (`{colors.accent-1}` — `#FFCB05`) — primary call-to-action buttons
- **Heading Text:** Ink (`{colors.ink}` — `#0B0B0B`) — all headlines and primary text
- **Body Text:** Body (`{colors.body}` — `#7D6161`) — main content paragraphs
- **Background:** Canvas (`{colors.canvas}` — `#FFFFFF`) — default page surface
- **Section / Footer:** Surface Alt Purple (`{colors.surface-alt}` — `#462E91`) — alternating bands
- **Link Color:** Blue (`{colors.link}` — `#0000EE`) — inline hyperlinks
- **Secondary Text:** Muted (`{colors.muted}` — `#E6DCDC`) — captions, hints

### Iteration Guide

1. **All buttons use sans-serif at 12px weight 400**, line-height normal; primary filled button at 51px height with 16px border-radius; link buttons 40px (pill) or 187px (pill).
2. **Typography hierarchy is Poppins-first**; display 48px weight 500; headings 26–28px weight 600; body 16–18px weight 300–400; small text 13px.
3. **Section padding scales via the spacing system**: `{spacing.xxs}` (4px) for micro, `{spacing.md}` (16px) standard, `{spacing.band}` (80px) for major breaks.
4. **Depth comes from color shifts**, not shadows; purple section (`#462E91`) establishes layering against white canvas; no box-shadow values present in system.
5. **Pill-shaped buttons (`{rounded.full}` — 9999px) for secondary/link buttons; sharp corners only on icon buttons** (`{rounded.none}` — 0px); softened cards at `{rounded.xs}` (24px).
6. **Responsive breakpoint shift occurs at 1280px**: display text grows to 48px, content max-width locks at 1200px, navigation shows full link count. Below 1280px, single-column layout and smaller typography.
7. **Line height on body (1.5–1.7) is sacred** to the brand's simplifying ethos; never compress below 1.5 except in special metadata roles (body-sm at 1.7).

## 10. Known Gaps

- **No semantic color ramp extracted:** The site does not expose error, warning, or success states in its measured markup. Do not invent these colors; if needed, propose additions to the brand team.
- **Four accent colors (deep red, cream, sage green) lack assigned roles:** These were observed in the page but have no functional purpose in the measured components. Treat as decorative only; do not assign error/success/warning meanings.
- **No interaction states explicitly measured:** Hover, active, focus, and disabled states were referenced in the extraction but contain only CSS variable fallbacks, not concrete values. Assume standard web conventions (slight opacity or color shift) unless the brand provides explicit state documentation.
- **No dark mode or theme switching:** The extraction covers only the light theme visible on the live site. A dark-mode variant, if it exists, was not measured.
- **Surfaces behind authentication not analyzed:** The site may contain gated content (user dashboard, expert panels, etc.); only the public homepage was captured.
- **No border system implemented:** Components use `border: 0px none`; if borders are required in new components, this system does not provide a measured border scale.
- **Gradients are page-specific**: Three linear gradients were observed (hero band gradient, section overlays) but are not generalized as reusable tokens. Use them verbatim on their intended sections only.
- **Single page analyzed:** Extracted patterns are from the homepage only. Navigation, internal page templates, user account flows, and authentication screens were not measured and may differ from these tokens.