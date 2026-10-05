# Careerly

Careerly is a Flutter app backed by the FastAPI services in `../work_agent`.

## Local backend integration

Start the backend from `work_agent`:

```powershell
.\venv\Scripts\python.exe -m uvicorn app.api.server:app --host 0.0.0.0 --port 8000
```

Use the following base URL for the target:

| Target | Base URL |
|---|---|
| Android emulator | `http://10.0.2.2:8000` |
| Windows / Chrome on the host | `http://127.0.0.1:8000` |
| Physical Android phone over USB | `http://localhost:8000` after `adb reverse tcp:8000 tcp:8000` |

For a physical phone, keep it connected over USB and run:

```powershell
adb reverse tcp:8000 tcp:8000
```

This forwards the phone's localhost port to the host. It avoids exposing the
development server to the Wi-Fi network. The backend must be running on the
host at port 8000.

Run the app with real repositories enabled:

```powershell
flutter run --dart-define=CAREERLY_USE_API=true `
  --dart-define=CAREERLY_API_BASE_URL=http://localhost:8000
```

Replace the URL with the one for the target above. Android debug builds allow
HTTP only for the local addresses in
`android/app/src/debug/res/xml/network_security_config.xml`; release builds
retain the platform's cleartext restriction and should use an HTTPS backend.

Résumé uploads accept PDF, DOCX, TXT, and image files. PDFs with selectable
text use PDF text extraction; scanned PDFs use the backend OCR fallback. The
analysis page can fetch a job description from a URL, let the user review/edit
the fetched text, and submit it through the normal analysis endpoint.

The opt-in Flutter live integration test creates a backend user and calls the
real resume parser and analysis model, so it may consume model quota and leave
test data in the backend:

```powershell
flutter test --dart-define=CAREERLY_REAL_BACKEND=true `
  --dart-define=CAREERLY_API_BASE_URL=http://127.0.0.1:8000 `
  test\real_backend_integration_test.dart
```
