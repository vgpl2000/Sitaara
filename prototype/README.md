# Sitaara Mobile Design Prototype

This is a local, buildless HTML/CSS/JavaScript prototype for validating the Sitaara mobile experience before Flutter implementation.

## Run locally

Serve this directory with any static HTTP server and open `index.html`. No package installation or build step is required.

Run `node validate.mjs` from this directory for the lightweight source and route check.

## Suggested walkthrough

1. Choose **Explore the linked demo** on Welcome.
2. Open **Understanding Big Feelings**.
3. Play or like **Co-regulation before correction**.
4. Open **Prototype controls** and switch from Mom to Dad.
5. Return to the same lesson to observe the partner activity.
6. Use the controls to inspect the unlinked, loading, offline, and server-error states.

## Scope

- Local mock data only.
- No real authentication, database, backend, or media upload.
- Not Flutter Web and not a production client.
- Canonical design rules: [`../docs/design.md`](../docs/design.md).
- Canonical screens and copy: [`../docs/05-mobile-screen-specification.md`](../docs/05-mobile-screen-specification.md).

Original brand assets remain in `../assets`; optimized semantic copies used by the prototype are in `prototype/assets`.
