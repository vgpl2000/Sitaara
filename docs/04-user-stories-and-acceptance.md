# User Stories and Acceptance Criteria

**Status:** Draft for review  
**Last updated:** 2026-10-16  

## Authentication

### US-AUTH-001 - Register

As a parent, I want to register so that my activity belongs to my own account.

- **AC-AUTH-001:** Given a valid unused email and acceptable password, when registration succeeds, then the account is created and an access/refresh pair is returned. (`FR-AUTH-001`)
- **AC-AUTH-002:** Given an email differing only by case from an existing account, registration is rejected without creating another user. (`FR-AUTH-001`)
- **AC-AUTH-003:** The password never appears in database plaintext, responses, or logs. (`NFR-SEC-002`)

### US-AUTH-002 - Restore session

As a returning parent, I want the app to restore my session securely.

- **AC-AUTH-004:** A valid refresh token is exchanged once and the old token becomes unusable. (`FR-AUTH-003`)
- **AC-AUTH-005:** Concurrent refresh requests cannot both create valid successor sessions.
- **AC-AUTH-006:** A revoked, expired, malformed, or reused token returns unauthenticated without leaking token details.

## Family onboarding

### US-FAM-001 - Create family and child

As the first parent, I want to create our family and child so I can begin using shared content.

- **AC-FAM-001:** Family, creator membership, and child either all commit or none commit. (`FR-FAM-002`)
- **AC-FAM-002:** Blank or overlong child names are rejected. (`FR-FAM-003`)
- **AC-FAM-003:** Future DOB and age six or older at creation are rejected. (`FR-FAM-004`)
- **AC-FAM-004:** Retrying cannot give one account multiple families. (`FR-FAM-005`)

### US-FAM-002 - Join family

As the invited parent, I want to join using a short code so both accounts share the same child.

- **AC-FAM-005:** A valid invite and available opposite role create exactly one membership. (`FR-INV-003`)
- **AC-FAM-006:** After commit, both members retrieve the same family and child. (`FR-INV-008`)
- **AC-FAM-007:** Selecting an occupied role returns `ROLE_TAKEN` without changing data. (`FR-FAM-006`)

## Invite integrity

### US-INV-001 - Generate invite

As a sole family member, I want a temporary code to invite my partner safely.

- **AC-INV-001:** The code expires 24 hours after generation. (`FR-INV-001`)
- **AC-INV-002:** Regeneration revokes all previous unredeemed codes for the inviter. (`FR-INV-002`)
- **AC-INV-003:** A member of a full family cannot create an invite. (`FR-INV-007`)
- **AC-INV-004:** The raw code is not stored in the database or logs.

### US-INV-002 - Prevent invalid linking

As a family member, I want invalid redemption prevented so my family cannot be hijacked or corrupted.

- **AC-INV-005:** The inviter cannot redeem their own code. (`FR-INV-005`)
- **AC-INV-006:** An already-assigned account cannot redeem any code. (`FR-INV-006`)
- **AC-INV-007:** When two eligible accounts concurrently redeem one code, exactly one succeeds and the other receives a conflict. (`FR-INV-004`)
- **AC-INV-008:** A redeemed, revoked, expired, or unknown code reveals no family details.

## Content and personal activity

### US-CONT-001 - Browse and play

As a parent, I want to browse masterclasses and play videos.

- **AC-CONT-001:** Two ordered masterclasses are returned with four ordered videos each. (`FR-CONT-001`, `FR-CONT-002`)
- **AC-CONT-002:** Every video has a positive canonical duration and HTTPS media URL.
- **AC-CONT-003:** The reusable player releases resources on exit and reports final progress. (`FR-CONT-004`)

### US-ACT-001 - Like video

As a parent, I want to like or unlike a video.

- **AC-ACT-001:** Two like requests result in one like row and both responses are successful. (`FR-ACT-002`)
- **AC-ACT-002:** Two unlike requests leave zero rows and both responses are successful. (`FR-ACT-003`)
- **AC-ACT-003:** One user's like never changes another user's like state.

### US-ACT-002 - Preserve watch progress

As a parent, I want my furthest position remembered even if events arrive out of order.

- **AC-ACT-004:** Reporting 50 seconds and then 20 seconds stores 50 seconds. (`FR-ACT-005`)
- **AC-ACT-005:** Reporting beyond duration stores no more than duration. (`FR-ACT-007`)
- **AC-ACT-006:** Crossing 90% sets completion; later events do not clear it. (`FR-ACT-006`)
- **AC-ACT-007:** A lower re-watch event updates recency but not furthest progress.

## Shared activity and authorization

### US-SHARED-001 - See partner video activity

As a linked parent, I want to see my partner's activity on a video.

- **AC-SHARED-001:** A partner like is displayed with the partner's role. (`FR-SHARED-003`)
- **AC-SHARED-002:** Zero progress shows not started; positive incomplete progress shows percentage; completed shows completed.
- **AC-SHARED-003:** Before linking, partner fields are absent or null and contain no guessed identity. (`FR-SHARED-001`)

### US-SHARED-002 - See partner masterclass activity

As a linked parent, I want a useful summary of my partner's masterclass progress.

- **AC-SHARED-004:** Percentage equals capped watched seconds divided by total duration, rounded for display. (`FR-SHARED-004`)
- **AC-SHARED-005:** Completed count includes only videos at or above 90%.
- **AC-SHARED-006:** Watching-now is true only for recent positive incomplete progress in that masterclass. (`FR-SHARED-005`)

### US-SEC-001 - Isolate families

As a parent, I expect unrelated users to be unable to see my family activity.

- **AC-SEC-001:** Changing resource IDs or request bodies never returns another family's user activity. (`NFR-SEC-003`)
- **AC-SEC-002:** An authenticated user from Family A cannot query partner activity for Family B.
- **AC-SEC-003:** Content responses identify a partner only by role and public display label, not email or account/session metadata. (`FR-SHARED-007`)
- **AC-SEC-004:** Authorization is enforced by the service even if the mobile client is modified.

## Mobile resilience

### US-MOB-001 - Refresh and recover

As a mobile user, I want understandable recovery when the network is unreliable.

- **AC-MOB-001:** Pull-to-refresh preserves current content until the replacement succeeds. (`FR-SHARED-006`)
- **AC-MOB-002:** Retryable network errors provide Retry without duplicating mutations.
- **AC-MOB-003:** Expired access credentials trigger at most one coordinated refresh operation.
- **AC-MOB-004:** Invalid sessions return the user to Login with a concise explanation.

## Release scenario

The release candidate passes when a reviewer can complete this uninterrupted narrative:

1. Log into the seeded Mom account and like/watch a video.
2. Log into the seeded Dad account on another device/session and refresh.
3. Observe the Mom's like, video status, and masterclass aggregate.
4. Register two fresh accounts.
5. Create a child as one role, generate a code, and join as the opposite role.
6. Confirm self-linking, code reuse, and role-conflict attempts are rejected safely.
