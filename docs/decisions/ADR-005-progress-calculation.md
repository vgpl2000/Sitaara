# ADR-005: Monotonic and Duration-Weighted Progress

**Status:** Accepted  
**Date:** 2026-10-16  

## Context

Progress events can arrive late, duplicate, or out of order. Videos have different durations. The UI must show partner video state, masterclass completion, and whether the partner is currently watching.

## Decision

- Persist the maximum valid playback position per user/video.
- Mark completion once at 90% of canonical duration.
- Calculate masterclass percentage as total capped watched seconds divided by total duration.
- Also return completed-video count.
- Consider a partner currently watching when positive incomplete progress was reported within 10 minutes.

## Consequences

- Retries and out-of-order events cannot reduce progress.
- Partial viewing and video length are represented fairly.
- `Completed` may mean 90-99%, so status and numeric percentage must be presented clearly.
- Current-watching is an inferred recent-activity state, not a live presence guarantee.

## Alternatives

- Average per-video percentages: rejected because it weights short and long videos equally.
- Completed-video ratio only: rejected because partial viewing disappears.
- 100% completion: rejected because credits, rounding, and player events can prevent completion.
- WebSocket presence: rejected because refresh consistency is sufficient.
