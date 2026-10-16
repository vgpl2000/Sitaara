# ADR-007: Cloudinary for Public Demo Media Delivery

**Status:** Accepted
**Date:** 2026-10-16
**Supersedes:** The media-storage portion of [ADR-001](ADR-001-go-api-with-supabase-postgres.md)

## Context

The app needs a small catalog of licensed demonstration videos and thumbnails. These assets contain no account, child, family, or partner data. Supabase remains suitable for the relational database, but its storage constraints are not a good fit for the planned media catalog. Video delivery should also stay outside the Go API so the service does not proxy large files.

## Decision

- Supabase is used for Postgres only.
- Cloudinary stores and publicly delivers the processed demo videos and thumbnails.
- Media remains licensed, non-sensitive, seed-controlled content. User uploads and private family media remain out of scope.
- Uploading is performed only by trusted content/deployment tooling using `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, and `CLOUDINARY_API_SECRET`.
- Flutter and the runtime Go API receive no Cloudinary write credentials. The Go API returns HTTPS delivery URLs in content read models, and Flutter treats them as opaque.
- The database/seed retains Cloudinary public IDs as well as delivery URLs. This supports asset audit, replacement, and centralized transformation changes.
- Delivery URLs are verified for predictable MP4/H.264/AAC Android playback. Poster thumbnails are prepared as separate image assets.
- Processed source files and the licence manifest remain recoverable outside Cloudinary so the catalog can be migrated if necessary.

## Consequences

- The mobile player receives CDN-hosted media without routing video bytes through Railway.
- Supabase configuration is simpler and has one responsibility: Postgres.
- Cloudinary becomes another account and operational dependency whose current limits must be verified before submission.
- Public URLs are not access control. They are permitted only because the demo media is licensed and non-sensitive.
- Asset upload/replacement requires an explicit content-operations step and coordinated seed metadata.
- A future private-media feature would require a new ADR covering authenticated delivery, signed URLs, moderation, retention, and deletion.

## Alternatives

- **Supabase Storage:** replaced because its storage constraints do not suit the planned media use.
- **External source hotlinks:** rejected because availability, terms, CORS/range behavior, and URL stability are outside project control.
- **Proxy video through Go/Railway:** rejected because it adds bandwidth, latency, range-request, and scaling responsibilities without product value.
- **Bundle videos in the APK:** rejected because it inflates the release artifact and prevents independent content replacement.
- **Self-host object storage/CDN:** rejected as unnecessary operational work for the assignment.
