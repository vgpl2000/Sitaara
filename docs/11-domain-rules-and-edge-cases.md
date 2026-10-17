# Domain Rules and Edge Cases

**Status:** Implemented and handover-aligned
**Last updated:** 2026-10-16  

## Canonical invariants

1. One account belongs to zero or one family.
2. One family has exactly one child after creation.
3. One family has at most one Mom and one Dad.
4. A partner is the other member of the authenticated user's family; no arbitrary partner selection exists.
5. One invite can produce at most one new membership.
6. One user/video pair has at most one like.
7. Furthest progress never decreases.
8. Completion is monotonic after crossing 90%.
9. Partner activity is invisible before linking and outside the family.

## Family creation

Preconditions:

- Authenticated account has no family membership.
- Role is exactly `mom` or `dad`.
- Child name and DOB are valid.

Transaction:

1. Lock or otherwise serialize the user's onboarding state.
2. Recheck no membership exists.
3. Insert family.
4. Insert creator membership.
5. Insert child.
6. Commit.

If the client times out, it calls `/v1/me`; it does not blindly create again. The unique membership constraint prevents a second family assignment.

## Invite generation

Preconditions:

- Requester is a family member.
- Family currently has one member.

Transaction:

1. Lock family or requester membership.
2. Recount members.
3. Revoke every prior unused invite created by requester.
4. Generate code using a cryptographically secure source.
5. Insert only the keyed digest with 24-hour expiry.
6. Commit and return the raw code once.

If digest collision occurs, generate another code and retry a bounded number of times.

## Invite redemption

Normalize code by trimming, removing permitted separators, and uppercasing. Reject an invalid alphabet/length before database lookup.

Transaction checks in order:

1. Lock invite by digest.
2. Reject unknown/revoked/expired/redeemed invite.
3. Reject `inviter_user_id == authenticated_user_id`.
4. Lock the target family and relevant user membership state.
5. Reject if redeemer already has a family.
6. Reject if family already has two members.
7. Reject if requested role already exists.
8. Insert membership.
9. Mark invite redeemed by that user at the same timestamp.
10. Commit.

Database uniqueness errors are mapped to stable conflict codes rather than internal SQL messages.

### Concurrent redemption

With two simultaneous redeem requests, one locks/commits first. The second sees the redeemed state after acquiring the lock and fails. Even if lock behavior changes, unique role/family/user constraints prevent an invalid state.

## Likes

- `PUT like` is desired-state semantics, not toggle semantics.
- Like inserts with conflict ignored.
- `DELETE like` deletes if present.
- Both operations return the final desired state.
- The UI may optimistically update but rolls back on failure.
- Like ownership always comes from the token subject.

Using a toggle endpoint is rejected because network retries could reverse the user's intent.

## Progress

Input is an integer playback position in seconds.

Validation and calculation:

1. Video must exist and be published.
2. Negative values are rejected.
3. Incoming value is clamped to canonical duration.
4. Upsert uses the maximum of stored and incoming.
5. `last_watched_at` updates for every valid playback report.
6. Completion is set when resulting furthest seconds are at least `ceil(duration * 0.90)`.
7. Completion timestamp remains the first crossing time.

Out-of-order events, retries, background flushes, and multiple devices therefore cannot reduce progress.

## Watch states

For a user/video:

- **Not started:** no row or furthest seconds is zero.
- **Watching N%:** positive progress below completion threshold.
- **Completed:** completion timestamp exists.

Display percentage is `floor(100 * furthest / duration)`, capped at 100. Completion may therefore be displayed as `Completed` at a numeric value between 90 and 100.

## Masterclass aggregation

For each video, treat missing progress as zero and cap watched seconds to duration.

- Percentage: floor of total watched seconds divided by total duration times 100.
- Completed count: videos with `completed_at`.
- Total count: published videos in the masterclass.
- Currently watching: at least one incomplete video with positive progress and `last_watched_at >= now - 10 minutes`.

The calculation uses one database time reference per response to avoid boundary inconsistencies.

## Authorization edge cases

- Unonboarded account requesting content: return onboarding-required conflict/forbidden state consistently.
- Sole family member: own activity returned; partner object null.
- Linked family: only the other family member can populate partner fields.
- Supplying another user's ID: impossible in defined endpoints; unknown fields are rejected.
- Guessing another family/content activity URL: no endpoint accepts a family or partner ID for activity.
- Deleted/unpublished content: return not found without orphan activity leakage.

## Role edge cases

- Creator chooses role during atomic family creation.
- Joiner chooses role during redemption.
- Same role as creator returns `ROLE_TAKEN` and leaves invite usable for a valid opposite-role redemption.
- Role cannot change after membership in this release.
- This binary role model is assignment-specific and documented as a production limitation.

## Child edge cases

- Whitespace-only name is invalid.
- Unicode names are supported and length is measured consistently.
- Future DOB is invalid.
- Exactly six years old at creation is outside the 0-5 target range.
- A valid child aging beyond five does not invalidate the existing family.
- No child update means concurrent edit behavior is out of scope.

## Failure semantics

- Unexpected failure before commit leaves no partial domain state.
- Successful commit followed by lost response is recoverable through reads.
- Clients retry safe reads, likes/unlikes, and monotonic progress.
- Clients do not automatically retry registration, family creation, invite generation, or redemption without first checking current state.
- All conflict/error responses use stable machine codes.
