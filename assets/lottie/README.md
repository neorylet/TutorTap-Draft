# Lottie placeholder assets

Drop the real Lottie JSON files here before running a demo:

- `welcome_study.json` — onboarding step 1 (auto-play, loop).
- `uploading_cloud.json` — Cloudinary upload progress.
- `empty_search.json` — tutor catalog zero-result state.
- `booking_success.json` — simulated checkout confirmation (play once).

`lib/widgets/lottie_slot.dart` renders a styled fallback box whenever a file is
missing, so the app still compiles and runs without these JSON files.
