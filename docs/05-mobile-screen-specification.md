# Mobile Screen Specification

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Experience direction

Use Sitaara's public visual language as inspiration: calm, warm, credible, spacious, and family-oriented. The canonical mobile system is `design.md`: primary purple is `#462E91`, supplied logo/accent green is `#8AC340`, and the local files in `/assets` are the authoritative logo sources. Do not copy production screens, expert portraits, or proprietary editorial content.

Partner activity is supportive context rather than surveillance. Prefer phrases such as `Dad is halfway through` over audit-like timestamps.

The approved HTML/CSS/JavaScript prototype in `/prototype` is the interaction and visual reference for the Flutter implementation. It is not Flutter Web and must not be embedded in the final app.

## Screen inventory

### 1. Launch / session restoration

- Sitaara mark, neutral background, progress indicator.
- Attempts secure-token restoration once.
- Routes to Login, Onboarding, or Library.
- If restoration fails because the network is unavailable, show Retry and Sign out locally.

### 2. Welcome

- Short value statement about parenting together.
- Primary: **Create account**.
- Secondary: **Log in**.

### 3. Sign up

- Email, password, confirm password.
- Password requirements visible before submission.
- Password visibility toggle.
- Loading disables duplicate submission.
- Inline validation plus a page-level error for network/service failures.

### 4. Log in

- Email and password.
- Generic invalid-credentials message.
- No password-reset flow in this release; optionally show `Password recovery is not available in this demo` only if needed.

### 5. Choose family path

- Two cards: **Create a family** and **Join your partner**.
- Briefly explain that one parent creates the child and the second joins by code.

### 6. Create child

- Role segmented control: Mom / Dad.
- Child name.
- DOB date picker constrained to the allowed range.
- Primary: **Create family**.
- Explain that the child can be created once and is shared after linking.
- No child photo or editing.

### 7. Join family

- Role segmented control: Mom / Dad.
- Six-character code input with auto-uppercase and grouped display.
- Primary: **Join family**.
- Error copy maps stable API codes to clear actions.

### 8. Invite partner

- Appears as a prominent card for a sole family member and as a focused modal/page when opened.
- Shows code, exact expiry in local time, Copy, and Share.
- Regenerate action explains that the previous code stops working.
- Never displays internal invite identifiers.

### 9. Library / Home

- App bar with compact account action.
- Child context: `For <name> · <age label>`.
- Partner card:
  - Unlinked: invitation call to action.
  - Linked: `Learning together with Dad/Mom`.
- Two masterclass cards containing:
  - Thumbnail, title, description, video count.
  - Personal progress bar and percentage.
  - Partner role, percentage, completed count.
  - `Watching now` chip when applicable.
- Pull-to-refresh refreshes family and content summary.

### 10. Masterclass detail

- Title, description, thumbnail, total duration.
- Personal and partner summary cards.
- Ordered video rows containing duration, own progress, own like, and partner activity.
- Partner row examples:
  - `Not started by Dad`
  - `Dad watched 52%`
  - `Completed by Dad`
  - `Liked by Dad`
- Tapping a row opens the player.

### 11. Video player

- Reusable component built around the selected Flutter video package.
- Standard play/pause, seek, elapsed/total, full-screen, and replay behavior.
- Below player: title, masterclass link, Like toggle, personal status, partner status.
- Progress reports every five seconds while playing plus lifecycle events.
- Media initialization, buffering, playback failure, and retry states are distinct.
- Leaving the route flushes the latest known position best-effort and disposes the controller.

### 12. Account

- Own email.
- Role and linked-partner role when onboarded.
- Shared child read-only summary.
- API/app build information useful for the demo.
- Logout.
- No edit, unlink, delete account, or partner replacement actions.

## Common UI states

Every data screen defines:

- Initial skeleton/loading.
- Refresh in progress while retaining existing data.
- Empty state where meaningful.
- Offline or timeout with Retry.
- Unauthorized route to session recovery.
- Forbidden state without sensitive explanation.
- Generic server error containing a request ID for debugging.

## Partner visibility rules

- Do not render an empty partner identity before linking.
- Use role labels rather than partner email.
- Own and partner progress use different labels and accessible colors, not color alone.
- If the partner has no progress and no like, explicitly say `Dad has not started` only on detail screens; keep list cards uncluttered.

## Validation copy examples

| API code | Mobile message |
|---|---|
| `INVALID_CREDENTIALS` | `Email or password is incorrect.` |
| `EMAIL_ALREADY_USED` | `An account with this email already exists.` |
| `CHILD_AGE_OUT_OF_RANGE` | `Sitaara currently supports children from birth up to age 5.` |
| `INVITE_INVALID` | `That invite code is invalid or no longer available.` |
| `INVITE_EXPIRED` | `That code has expired. Ask your partner for a new one.` |
| `INVITE_ALREADY_USED` | `That code has already been used.` |
| `SELF_LINK_NOT_ALLOWED` | `You cannot use your own invite code.` |
| `ROLE_TAKEN` | `That family already has a parent with this role.` |
| `ALREADY_IN_FAMILY` | `This account is already linked to a family.` |

## Accessibility and responsiveness

- Minimum 48dp interactive targets.
- Respect Android text scaling without clipped controls.
- Provide semantic labels for icons and video controls.
- Maintain sufficient text/background contrast.
- Do not depend on red/green alone for status.
- Support narrow phones down to approximately 320 logical pixels.
- Keep primary actions reachable with the keyboard visible.

## Branding assets

Use the supplied assets as follows:

- `assets/200x200bb-75.webp`: app-icon and prototype launcher/favicon reference.
- `assets/jxCC0aq4hz0Upn8JHTZRPYU50.png`: primary horizontal lockup on purple/dark surfaces.
- `assets/s8mITtcKeyymZ6Dh7cjaOk3o.png`: alternate horizontal lockup where its proportions fit better.

Preserve original files, proportions, colors, and clear space. Create optimized copies inside `/prototype` and the future Flutter asset bundle rather than fetching website assets at runtime. Video content and thumbnails follow the licensing record in `14-demo-data-and-content.md`.

## Prototype presentation requirements

- Present a mobile app frame with a 390x844 baseline, not a desktop website layout.
- Remain usable at widths of 320, 390, and 430 logical pixels.
- Make all twelve screens and their primary transitions reachable with local mock data.
- Provide a deliberate way to switch between Mom and Dad perspectives for shared-activity review.
- Include linked, unlinked, progress, completed, liked, loading, validation, offline, and server-error states.
- Use semantic HTML, visible keyboard focus, accessible names, and reduced-motion support.
- Treat mock authentication, linking, likes, and progress as interaction simulation only; backend rules remain canonical elsewhere.
