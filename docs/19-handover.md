# Sitaara Handover

**Status:** Ready for private assignment review; explicit external gates are listed below  
**Last updated:** 2026-10-16

## Deliverables

- Flutter Android app in `mobile/`, application ID `com.vgpl.sitaara`, version `1.0.0+1`.
- Go API in `backend/`, intended Railway service root `/backend`.
- PostgreSQL migrations and idempotent content/demo-family seed.
- Nine Cloudinary videos arranged as two masterclasses with four and five lessons.
- Separate approved HTML/CSS/JavaScript design reference in `prototype/`.
- Product, architecture, API, security, testing, deployment, AI-usage, and implementation records in `docs/`.

## Live and local artifacts

- API: `https://sitaara-production.up.railway.app`
- Repository: `https://github.com/vgpl2000/Sitaara`
- Signed APK: `artifacts/Sitaara-1.0.0+1-release.apk`
- APK size: 57,026,176 bytes
- APK SHA-256: `10CAE0145BB3A9B2BCC12F9DB599DE39972DCA4853DE8553A04E0C2E54FF4C4F`
- APK signer certificate SHA-256: `32f56464b4596d3f6eb7d54b058595cf99546b9e5439d037e3fe8df9cf8d93e1`
- Device note: the refreshed UI artifact is signed and verified but still needs final installation/visual QA because the authorized wireless device disconnected after the build.

The Git-ignored signing files are `mobile/android/key.properties` and `mobile/android/app/sitaara-release.jks`. They must be backed up and transferred securely with the handover; they are intentionally absent from Git.

## Assignment-only demo family

| Parent | Email | Password |
|---|---|---|
| Mom | `mom.demo@sitaara.example` | `SitaaraDemo2026!` |
| Dad | `dad.demo@sitaara.example` | `SitaaraDemo2026!` |

Both parents are linked to the fictional child Tara. Run `backend\scripts\dev.ps1 seed` to restore the canonical seed state. API startup never seeds automatically.

## Required environment values

Flutter requires no secret. Production defaults to the Railway HTTPS URL. A local API URL is supplied with `APP_ENV=local` and `API_BASE_URL` Dart definitions.

The backend requires `DATABASE_URL`, `JWT_SECRET`, `JWT_ISSUER`, `JWT_AUDIENCE`, `INVITE_HMAC_SECRET`, and `REFRESH_HMAC_SECRET`. `CLOUDINARY_CLOUD_NAME` is required only by the seed. Cloudinary API key/secret are upload-operations credentials and are not required by the API runtime or Flutter app. See `backend/.env.example` for the complete list.

## Verified on 2026-10-16

- Android Studio-equivalent `assembleDebug` completes after the Flutter PowerShell repair.
- Flutter analyzer reports zero issues and all 25 tests pass.
- Go unit tests and focused PostgreSQL integration packages pass; concurrency/race execution remains a CI gate because local Windows lacks the required race toolchain.
- The signed release APK verifies with APK Signature Scheme v2.
- The release APK was clean-installed on a Motorola edge 60 pro over wireless debugging.
- Clean launch, Mom login, Dad login, session reconciliation, linked family, two masterclasses, all posters, masterclass detail, Cloudinary play/pause, seeking, like/unlike, account summary, logout, and partner activity were exercised.
- Railway health/readiness and both demo accounts were verified without exposing tokens.

## Remaining external gates

- Complete the source/licence/provenance fields for all nine supplied videos before distribution beyond private assignment review.
- Confirm GitHub CI on the final pushed commit, including the configured Go race job.
- Verify Railway runtime variable/log hygiene in the owner dashboard; do not keep Cloudinary write credentials there when the runtime does not use them.
- Securely back up the Android keystore and its ignored `key.properties`; never commit either file.
- If submission requires simultaneous two-device evidence, repeat the already-passing sequential Mom/Dad scenario on two independent installations.

## Workstation note

Flutter's launchers at `C:\Users\Venugopal\dev\flutter\bin\flutter.bat` and `dart.bat` were backed up as `*.sitaara-backup` and repaired to prefer Windows PowerShell before `pwsh`. This fixes Android Studio's `System.Management.Automation.TypeAccelerators` / `Unable to determine engine version` failure. Restart Android Studio if it was open before the repair.
