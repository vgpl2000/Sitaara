# Demo Data and Content Plan

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Goals

- Make shared activity visible immediately after login.
- Allow reviewers to create a fresh pair without destroying seeded state.
- Use non-personal, fictional data.
- Use reliable, appropriately licensed media with real duration.
- Keep total media size practical for mobile playback and the active Cloudinary plan.

## Seeded content

### Masterclass 1: Understanding Big Feelings

1. Naming the feeling
2. Co-regulation before correction
3. Building a calm-down routine
4. Reconnecting after a difficult moment

### Masterclass 2: Play That Builds Connection

1. Following your child's lead
2. Turning routines into play
3. Simple open-ended play
4. Ending play without a battle

Titles and descriptions are fictional demo editorial content, not claims of professional or medical advice.

## Video acquisition policy

- Prefer reputable royalty-free libraries that permit downloading and reuse in a demonstration.
- Do not scrape or download Sitaara Instagram videos without explicit permission.
- Do not rely on expiring social-media URLs or hotlinks.
- Record original source page, creator if supplied, licence/terms link, download date, and required attribution.
- Retain source evidence in the project notes where permitted.
- Avoid identifiable children where a neutral animation, nature, object, or adult-only parenting clip works.
- Remove original audio or use only audio covered by the same licence.

## Media processing

- Eight separate clips, ideally 20-90 seconds each.
- MP4 with H.264 video and AAC audio for broad Android compatibility.
- 720p target, optimized bitrate, fast-start metadata.
- Consistent landscape aspect ratio unless the design deliberately supports portrait.
- Extract a representative thumbnail from each processed clip.
- Verify duration using tooling after processing; store the verified integer duration in seed data.
- Target a modest combined size suitable for the active Cloudinary account limits; verify current limits rather than documenting a fixed quota.
- Upload from trusted content tooling only. There is no client or public API upload flow.
- Preserve predictable Android compatibility with an explicitly verified MP4/H.264/AAC delivery URL; generate optimized poster thumbnails separately.

## Licence manifest template

| Video slug | Source page | Creator | Licence/terms | Downloaded | Attribution needed | Processed duration | Cloudinary public ID | Delivery URL |
|---|---|---|---|---|---|---|---|---|
| `naming-feelings` | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

No clip enters the production seed until its row is complete.

## Seeded accounts

Create one intentionally public linked pair with obvious demo-only addresses:

- Mom demo account - credentials published in the final README.
- Dad demo account - credentials published in the final README.
- Shared fictional child under six.

The exact addresses/passwords are chosen at deployment. Public credentials must be unique to this demo and never reused elsewhere.

## Seeded activity narrative

Seed enough contrast to show every state:

- Mom likes a video Dad has not liked.
- Dad likes a different video.
- One partner has a 40-60% in-progress video.
- One partner has at least one completed video.
- One untouched video shows not started.
- Masterclasses produce visibly different aggregate percentages.
- Do not permanently seed `Watching now`, because recency should reflect actual events. Demonstrate it by playing during the live flow.

## Fresh reviewer flow

Public registration remains enabled. Instructions explain:

1. Register Account A.
2. Create family/child and generate code.
3. Register Account B on another device/session.
4. Join using the opposite role.
5. Act on content in one account and refresh the other.

No reset endpoint is provided. Reviewers can use unique email aliases for repeat tests.

## Brand asset policy

- Treat `assets/200x200bb-75.webp`, `assets/jxCC0aq4hz0Upn8JHTZRPYU50.png`, and `assets/s8mITtcKeyymZ6Dh7cjaOk3o.png` as the supplied source assets.
- Use primary purple `#462E91` and logo/accent green `#8AC340` according to `design.md`.
- Preserve original files and create optimized copies inside `/prototype` and the future Flutter asset bundle as needed.
- Store local app assets rather than fetching website assets at runtime.
- Preserve aspect ratio and do not recolor, distort, outline, or add effects to the supplied wordmark.
- Do not copy expert portraits or production editorial content.
- Make clear in the README that this is an assignment prototype, not an official production release.

## Seed implementation

- Stable UUIDs or deterministic natural keys for content make the seed rerunnable.
- Upsert content by stable slug and video order.
- Create demo users only when explicitly enabling demo seed.
- Create likes/progress with database constraints and the same domain assumptions as the application.
- Seed validation verifies two masterclasses, four videos each, positive durations, unique Cloudinary public IDs, HTTPS delivery URLs, and complete licence records.
