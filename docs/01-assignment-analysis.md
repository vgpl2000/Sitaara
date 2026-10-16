# Assignment Analysis and Traceability

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Objective

Build one correct, complete feature slice: two parents link their accounts around one shared child and can see each other's likes and watch progress across shared video content.

The deliverable is an Android APK backed by a hosted Go API and persistent Postgres database. Source code and a detailed write-up are submitted in a Git repository.

Before implementation, a separate HTML/CSS/JavaScript mobile prototype will validate the complete experience and become the visual reference for Flutter. It is an internal design artifact, not Flutter Web and not a substitute for the required mobile deliverable.

## Assessment priorities

Ordered by expected review importance:

1. Backend correctness, data integrity, and authorization.
2. Safe partner-linking behavior under invalid and concurrent requests.
3. Correct, idempotent likes and monotonic progress.
4. Clear partner activity at video and masterclass levels.
5. Maintainable Flutter and Go structure.
6. Tests, reasoning, trade-offs, and transparent AI usage.
7. Visual polish beyond the essential experience.

## Required capabilities

| Source requirement | Project interpretation | Planned proof |
|---|---|---|
| Email/password signup and login | Authentication is implemented by the Go service; passwords are never stored directly. | Auth integration tests and APK flow |
| Parent selects Mom or Dad | Role is assigned when the account creates or joins a family. | Database role constraint and onboarding UI |
| One shared child | A family has exactly one child; the creator supplies name and DOB. | Unique database constraint and API test |
| Two masterclasses with 4-5 videos | Seed two fictional masterclasses with four licensed sample videos each. | Seed migration and content screen |
| Video playback | Flutter uses a reusable video-player component with remote HTTPS MP4 sources. | Device demonstration |
| Track likes and progress per user | Likes use a unique row; progress uses an atomic greatest-position update. | Integration and concurrency tests |
| Invite-code linking | One family member generates a 24-hour, single-use code for one opposite-role partner. | Transactional redemption tests |
| Mutual shared activity | Only linked members of the same family can see one another's activity. | Authorization tests from multiple families |
| Partner video status | Display liked state plus not started, percentage, or completed. | Video list/detail acceptance tests |
| Partner masterclass status | Display weighted watch percentage, completed count, and current-watching indicator. | Aggregate query tests |
| Hosted end to end | Go runs on Railway; Postgres uses Supabase and demo media uses Cloudinary. | Deployment runbook, media smoke test, and live health endpoint |
| Two-account test path | Provide a seeded linked couple and allow fresh registration/linking. | Demo guide |

## Explicit design decisions

- The primary client is an Android APK, not Flutter Web.
- A high-fidelity mobile prototype is built first in the root `/prototype` folder with HTML, CSS, and JavaScript.
- The prototype uses local mock state to validate interaction and usability; production security and integrity remain Go/Postgres responsibilities.
- The mobile visual system uses primary purple `#462E91` and logo/accent green `#8AC340`, with the supplied `/assets` logo files.
- Supabase authentication is not used. Authentication belongs to the Go backend.
- Supabase provides hosted Postgres only.
- Cloudinary stores and delivers the licensed, non-sensitive demo videos and thumbnails.
- Railway is the first-choice Go host.
- The creator creates the child; the invited partner inherits access after linking.
- A family allows exactly one Mom and one Dad.
- Invite codes expire after 24 hours and are single-use.
- Completion is reached at 90% watched.
- Masterclass percentage is duration-weighted.
- Partner data refreshes on screen entry and pull-to-refresh; real-time transport is excluded.
- Correctness, tests, and documentation take priority over optional features.

## Deliberately excluded

- Flutter Web and iOS distribution. The standalone HTML prototype is not a deployed Flutter client.
- Multiple children or family switching.
- Same-role couples in this assignment-specific model.
- Unlinking, partner replacement, custody workflows, or family deletion.
- Child editing, avatars, milestones, or medical information.
- Email verification, password reset email, social login, and MFA.
- Comments, messaging, notifications, subscriptions, payments, and offline playback.
- Live sockets or real-time partner presence.
- Uploading user-generated video.
- An admin dashboard.

These exclusions are scope decisions, not claims about what a production parenting product should support.

## Ambiguities resolved

### Masterclass percentage

Use total watched seconds divided by total canonical duration, capped per video. This credits partial viewing and avoids treating a one-minute and a ten-minute video as equal. Also show completed-video count to keep the result understandable.

### Currently watching

A partner is currently watching a masterclass when a video in that masterclass is incomplete, has positive progress, and received a valid progress event in the previous 10 minutes.

### Child age

At child creation, date of birth must not be in the future and the child must be younger than six years. The child is not automatically removed when they later age beyond the range.

### Child interface

The creator receives a child-creation form. Both parents see compact child context in the content experience. There is no dedicated edit or management screen.

## Success definition

The design phase is complete when the standalone prototype passes the approval gate in `design.md`. The implementation slice is complete when two independent accounts can register, create/join a family, play and like seeded content, refresh the other account, and observe correct shared activity without being able to view or mutate data belonging to another family.
