# Sitaara mobile

Flutter Android application for the Sitaara parenting companion.

## API configuration

The app uses the deployed Railway API by default:

`https://sitaara-production.up.railway.app`

The URL is public configuration, not a secret. Database, JWT, Cloudinary write, and signing credentials must never be added to the Flutter app.

To run against the default hosted API:

```powershell
flutter run
```

To run against another HTTPS API without editing source code:

```powershell
flutter run --dart-define=API_BASE_URL=https://example-api.test
```

For a local development API, use the Android emulator host alias:

```powershell
flutter run --dart-define=APP_ENV=local --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Plain HTTP is accepted only when `APP_ENV=local`. Production configuration must use HTTPS.

## Quality checks

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

The Android package name is `com.vgpl.sitaara`, and the minimum Android SDK is 24.
