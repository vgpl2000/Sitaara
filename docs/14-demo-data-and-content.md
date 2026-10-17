# Demo Data and Content Plan

**Status:** Implemented and device-verified; licence provenance pending
**Last updated:** 2026-10-16  

## Goals

- Make shared activity visible immediately after login.
- Allow reviewers to create a fresh pair without destroying seeded state.
- Use non-personal, fictional data.
- Use reliable, appropriately licensed media with real duration.
- Keep total media size practical for mobile playback and the active Cloudinary plan.

## Seeded content

### Masterclass 1: Understanding Child Behaviour

1. Understanding Child Behaviour
2. Growth Comes With Tantrums
3. A Story About Tantrums
4. Children's Books as a Parenting Ally

### Masterclass 2: Everyday Parenting Insights

1. Why Your Baby Needs You
2. The Secret Role of Children's Books
3. The Truth About Isolation
4. When Your Child Throws Things
5. Stop Forcing Your Child

Titles and descriptions are concise editorial labels derived from the uploaded media and are not claims of professional or medical advice.

## Video acquisition policy

- Prefer reputable royalty-free libraries that permit downloading and reuse in a demonstration.
- Do not scrape or download Sitaara Instagram videos without explicit permission.
- Do not rely on expiring social-media URLs or hotlinks.
- Record original source page, creator if supplied, licence/terms link, download date, and required attribution.
- Retain source evidence in the project notes where permitted.
- Avoid identifiable children where a neutral animation, nature, object, or adult-only parenting clip works.
- Remove original audio or use only audio covered by the same licence.

## Media processing

- Nine separate clips: four landscape long-form lessons and five portrait short-form lessons.
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
| `understanding-child-behaviour` | TBD | Nupur Paiva / Sitaara (verify) | TBD | TBD | TBD | 445s | `sitaara/masterclasses/understanding-child-behaviour/01-understanding-child-behaviour` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/understanding-child-behaviour/01-understanding-child-behaviour.mp4` |
| `growth-comes-with-tantrums` | TBD | Sitaara (verify) | TBD | TBD | TBD | 92s | `sitaara/masterclasses/understanding-child-behaviour/02-growth-comes-with-tantrums` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/understanding-child-behaviour/02-growth-comes-with-tantrums.mp4` |
| `story-about-tantrums` | TBD | Sitaara (verify) | TBD | TBD | TBD | 374s | `sitaara/masterclasses/understanding-child-behaviour/03-story-about-tantrums` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/understanding-child-behaviour/03-story-about-tantrums.mp4` |
| `childrens-books-parenting-ally` | TBD | Sitaara (verify) | TBD | TBD | TBD | 179s | `sitaara/masterclasses/understanding-child-behaviour/04-childrens-books-as-a-parenting-ally` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/understanding-child-behaviour/04-childrens-books-as-a-parenting-ally.mp4` |
| `why-your-baby-needs-you` | TBD | TBD | TBD | TBD | TBD | 74s | `sitaara/masterclasses/everyday-parenting-insights/01-why-your-baby-needs-you` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/everyday-parenting-insights/01-why-your-baby-needs-you.mp4` |
| `secret-role-of-childrens-books` | TBD | TBD | TBD | TBD | TBD | 97s | `sitaara/masterclasses/everyday-parenting-insights/02-secret-role-of-childrens-books` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/everyday-parenting-insights/02-secret-role-of-childrens-books.mp4` |
| `truth-about-isolation` | TBD | TBD | TBD | TBD | TBD | 141s | `sitaara/masterclasses/everyday-parenting-insights/03-truth-about-isolation` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/everyday-parenting-insights/03-truth-about-isolation.mp4` |
| `when-your-child-throws-things` | TBD | TBD | TBD | TBD | TBD | 77s | `sitaara/masterclasses/everyday-parenting-insights/04-when-your-child-throws-things` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/everyday-parenting-insights/04-when-your-child-throws-things.mp4` |
| `stop-forcing-your-child` | TBD | TBD | TBD | TBD | TBD | 66s | `sitaara/masterclasses/everyday-parenting-insights/05-stop-forcing-your-child` | `https://res.cloudinary.com/g2g9bcrq/video/upload/sitaara/masterclasses/everyday-parenting-insights/05-stop-forcing-your-child.mp4` |

The files were supplied/uploaded for this company assignment and are technically ready for its private review. Permission for redistribution outside that review has not been independently verified; complete every TBD field before broader distribution.

## Seeded accounts

The idempotent seed creates one intentionally public linked pair:

- Mom: `mom.demo@sitaara.example`
- Dad: `dad.demo@sitaara.example`
- Shared assignment-only password: `SitaaraDemo2026!`
- Shared fictional child: Tara, born 2022-08-14.

These credentials are unique to the assignment and must never be reused elsewhere.

## Seeded activity narrative

Seed enough contrast to show every state:

- Mom likes a video Dad has not liked.
- Dad likes a different video.
- Dad has a 45-second in-progress video.
- One partner has at least one completed video.
- One untouched video shows not started.
- Masterclasses produce visibly different aggregate percentages.
- The seed timestamp makes Dad appear as `Watching now` briefly after a seed run; the state naturally expires after the documented ten-minute window.

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
- Create demo users only when explicitly running the seed command; API startup never seeds.
- Create likes/progress with database constraints and the same domain assumptions as the application.
- Seed validation verifies two masterclasses with four and five videos, positive real durations, unique Cloudinary public IDs, HTTPS delivery URLs, and complete licence records.
