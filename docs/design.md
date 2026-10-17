# Sitaara Mobile Design System

**Status:** Implemented Flutter design reference

**Last updated:** 2026-10-16

**Applies to:** HTML/CSS/JavaScript mobile prototype and Flutter Android app

## Purpose

This document is the canonical visual and interaction system for the Sitaara assignment. It adapts Sitaara's public brand language to a focused mobile product without copying production screens or editorial content.

The HTML prototype must prove the navigation, hierarchy, copy, component behavior, and usability before Flutter implementation begins. Flutter should reproduce the approved prototype deliberately; the prototype is not Flutter Web and is not production code.

## Experience principles

1. **Calm before clever.** Reduce parental overwhelm through simple choices, generous spacing, and plain language.
2. **Together, not tracked.** Partner activity should feel supportive and collaborative, never like surveillance.
3. **Content first.** Branding frames the learning experience but does not compete with video titles or progress.
4. **One clear next action.** Each screen should make its primary action immediately obvious.
5. **Trust through consistency.** Forms, status language, progress, errors, and navigation follow predictable patterns.
6. **Accessible by default.** Color never carries meaning alone, text remains readable at larger scale, and controls are comfortably tappable.

## Brand assets

The supplied files in `/assets` are the authoritative visual source for the prototype:

| Asset | Intended use |
|---|---|
| `assets/200x200bb-75.webp` | App-icon reference and prototype launcher/favicon source |
| `assets/jxCC0aq4hz0Upn8JHTZRPYU50.png` | Primary horizontal logo lockup for purple or dark surfaces |
| `assets/s8mITtcKeyymZ6Dh7cjaOk3o.png` | Alternate horizontal logo lockup where its proportions fit better |

Asset rules:

- Preserve the logo's aspect ratio and clear space.
- Do not recolor, stretch, outline, crop through, or add effects to the wordmark.
- Use the supplied app-icon artwork as the source when producing Android launcher variants.
- Optimized copies may be renamed and converted inside the prototype and Flutter projects; retain the original files in `/assets`.
- Use the full lockup on Welcome and authentication surfaces. Use a compact mark or wordmark only where horizontal space is constrained.
- Never fetch logo assets from the public website at runtime.

## Color system

The confirmed brand relationship is purple-led with green used for the logo and restrained brand accents.

| Token | Value | Role |
|---|---|---|
| `brand.primary` | `#462E91` | Primary buttons, selected controls, links, focus, active navigation |
| `brand.primaryPressed` | `#382474` | Pressed primary controls |
| `brand.primarySoft` | `#EEEAF8` | Selected-card tint, progress track tint, supportive highlights |
| `brand.green` | `#8AC340` | Logo and small brand accents |
| `brand.greenSoft` | `#EFF7E5` | Restrained green tint; never the only success signal |
| `surface.canvas` | `#F8F7FC` | Default app background |
| `surface.card` | `#FFFFFF` | Cards, sheets, form surfaces |
| `surface.purple` | `#462E91` | Welcome/hero band and selected high-emphasis surfaces |
| `text.primary` | `#201B2C` | Main text on light surfaces |
| `text.secondary` | `#6F687C` | Supporting copy and metadata |
| `text.onPrimary` | `#FFFFFF` | Text and icons on purple |
| `border.default` | `#E3DFEC` | Input and card borders |
| `status.error` | `#B42318` | Error text/icon with explanatory copy |
| `status.errorSoft` | `#FDECEA` | Error container background |
| `status.warning` | `#8A5A00` | Warning text/icon with explanatory copy |
| `status.warningSoft` | `#FFF4D6` | Warning container background |
| `status.success` | `#237A44` | Confirmed-success text/icon; not a substitute for brand green |
| `status.successSoft` | `#E8F5EC` | Success container background |
| `brand.yellow` | `#FFD21F` | Warm editorial accent borrowed from the current public site |
| `brand.yellowSoft` | `#FFF6C9` | Soft invitation, step, and empty-state surfaces |

Color rules:

- Purple `#462E91` is the primary interaction color.
- Green `#8AC340` belongs primarily to the logo and small branded accents. It is not used for body text or large button fills.
- Yellow from the public marketing site is a supporting warmth accent, never the main interaction color.
- Use white text on purple. Do not place green text directly on white unless the measured contrast passes WCAG AA at its actual size.
- Status components always include an icon and text, never color alone.
- Dark mode is outside the assignment scope.

## Typography

Use **Poppins** for the prototype and Flutter app. If the font cannot load, fall back to `Inter`, `system-ui`, or the platform sans-serif.

| Style | Size | Weight | Line height | Use |
|---|---:|---:|---:|---|
| Display | 32 | 700 | 40 | Welcome statement only |
| Title 1 | 28 | 700 | 36 | Primary page title |
| Title 2 | 22 | 600 | 30 | Section and masterclass titles |
| Title 3 | 18 | 600 | 26 | Card titles and dialogs |
| Body | 16 | 400 | 24 | Standard copy and inputs |
| Body strong | 16 | 600 | 24 | Important labels and values |
| Body small | 14 | 400 | 20 | Metadata and helper text |
| Label | 13 | 600 | 18 | Chips, field labels, navigation |
| Caption | 12 | 500 | 16 | Timestamps and compact supporting text |

Avoid long uppercase labels. Numeric progress uses tabular figures where available.

## Spacing and layout

Use a 4-point base scale: `4`, `8`, `12`, `16`, `20`, `24`, `32`, `40`, and `48`.

- Design baseline: `390 x 844` logical pixels.
- Required usable range: `320-430` logical pixels wide.
- Content uses one column with `20px` preferred horizontal gutters (`16px` at narrow width).
- Respect device safe areas and keep fixed actions clear of gesture/navigation regions.
- Avoid important controls above the comfortable thumb zone unless they are navigation actions.
- Scrolling is vertical; horizontal scrolling is limited to intentional carousels, which are not required here.

## Shape, borders, and elevation

- Buttons and fields: full pill radius, including form actions and compact actions.
- Standard cards: `20px` corner radius.
- Hero and high-emphasis cards: `24px` corner radius.
- Chips and segmented controls: full pill radius.
- Default border: `1px solid #E3DFEC`.
- Prefer borders and surface contrast over shadows.
- If elevation is necessary, use one soft shadow only: `0 8px 24px rgba(44, 31, 78, 0.10)`.

## Core components

### Buttons

- Primary: purple fill, white label, 52px minimum height, full-width on forms.
- Secondary: white/card fill, purple label, purple or neutral border.
- Tertiary: text/icon action with no container; maintain a 48px touch target.
- Destructive: semantic error styling and confirmation when the action is irreversible.
- Loading: retain width, replace or accompany label with progress, and prevent duplicate submission.
- Disabled: reduced emphasis but still readable; do not communicate disabled state by opacity alone.

### Inputs

- Persistent field label above the control; placeholder is an example, not the label.
- 52px minimum control height and 16px text.
- Focus uses a 2px purple ring.
- Error state includes a message beneath the field and an error icon where useful.
- Password inputs include a labelled visibility toggle.
- Invite code input uses six visually grouped characters while remaining one accessible field.

### Cards

- Use cards to group one decision or one content item, not every line of text.
- Masterclass cards prioritize thumbnail, title, personal progress, and one concise partner summary.
- Partner activity uses a purple-soft container with role-labelled text.
- Avoid nested cards deeper than one level.

### Progress

- Personal progress: solid purple bar plus numeric percentage.
- Partner progress: purple-soft or outlined treatment plus `Mom`/`Dad` label.
- Completed: check icon and `Completed`; do not rely on green alone.
- Watching now: an active dot may supplement, never replace, the words `Watching now`.

### Navigation

- Authentication and onboarding use a linear stack with a clear Back action.
- The content experience uses a compact top app bar; bottom navigation is unnecessary for this information architecture.
- Preserve user-entered non-sensitive data when returning from validation errors.
- Successful authentication/onboarding replaces previous history where documented in `03-user-flows.md`.

### Feedback and motion

- Skeletons are used for initial content loading.
- Pull-to-refresh retains existing content.
- Toast/snackbar confirms lightweight actions such as copying an invite code.
- Inline or full-state errors explain the next action.
- Empty states use concise supportive copy and one relevant action.
- Motion lasts roughly 160-240ms and never blocks task completion.

## Screen composition

The canonical screen inventory remains in `05-mobile-screen-specification.md`.

- **Welcome/auth:** purple brand field or soft gradient, full logo lockup, custom vector illustration, and one dominant action.
- **Onboarding:** short step framing, visible progress, one decision per screen.
- **Library:** warm greeting and child context, partner card, then masterclass cards.
- **Masterclass:** strong cover/title, compact dual-progress summary, scannable video list.
- **Player:** media first, controls with strong contrast, then like and partner activity details.
- **Invite:** code is the focal object; Copy and Share are immediate; expiry and regeneration are secondary.

## Accessibility requirements

- Minimum touch target: `48 x 48` logical pixels.
- Body text never smaller than 14px; interactive text never smaller than 14px.
- Meet WCAG AA contrast for text and essential controls.
- Support at least 200% text scaling without clipped actions or inaccessible content.
- Provide visible keyboard focus in the HTML prototype.
- Every icon-only control has an accessible name and tooltip/semantic label.
- Respect reduced-motion preference in the prototype and platform accessibility settings in Flutter.
- Video controls expose play state, elapsed time, duration, seek value, captions availability, and fullscreen action semantically.

## Prototype contract

The standalone prototype lives in `/prototype` and uses HTML, CSS, and JavaScript only.

It must:

- visually simulate a mobile app rather than a responsive marketing website;
- implement every screen and primary transition in `05-mobile-screen-specification.md`;
- include representative loading, empty, validation, offline, and server-error states;
- simulate two-account linking and partner activity with local mock state;
- use the supplied local logo assets and the tokens in this document;
- work at 320px, 390px, and 430px widths;
- be keyboard navigable and usable with visible focus;
- keep prototype-specific assets and code entirely inside `/prototype` except for copied/optimized brand assets.

It must not:

- be described as Flutter Web or as the submitted application;
- connect to the production database or store real credentials;
- make security or concurrency claims based on front-end simulation;
- become a source of duplicated business rules copied blindly into Flutter.

## Prototype approval gate

Flutter UI implementation begins only after review confirms:

1. All required journeys are reachable without explanation.
2. Primary actions and Back behavior are predictable.
3. Partner activity is understandable without feeling invasive.
4. Dense content remains scannable on a 320px-wide viewport.
5. Brand colors and supplied logos are applied consistently.
6. Loading, error, empty, and success feedback are credible.
7. Accessibility checks reveal no critical issue.

## Do and don't

### Do

- Use purple for action and hierarchy, green for brand recognition and small accents.
- Use generous whitespace and concise, reassuring copy.
- Show own and partner progress with explicit labels.
- Keep one dominant action per screen.
- Reuse components and tokens across the prototype and Flutter design translation.

### Don't

- Turn the mobile app into a miniature version of the marketing website.
- Use yellow as the default CTA color or blue browser-link styling.
- Overload cards with progress, likes, timestamps, and metadata at equal emphasis.
- Use excessive shadows, gradients, glass effects, or decorative animation.
- Invent additional logo treatments or recolor supplied assets.

## Source and limitations

This system combines the user's confirmed brand direction, supplied local logo assets, and observed public-site qualities such as warmth, whitespace, and purple color blocking. It is an assignment-specific mobile interpretation, not an official Sitaara brand guideline. Production-only screens, proprietary content, and expert imagery are intentionally excluded.
