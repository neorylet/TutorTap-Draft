# TutorTap roadmap

_Last updated 25 Nov 2026 · `main` @ a8c4416_

## Shipped

- Auth, onboarding, role select, student and tutor shells
- Browse, tutor profiles, availability slots
- Booking loop: slot lock, simulated checkout, confirmed booking, reschedule, cancel that frees the slot
- Classroom: courses, modules with multi-file attachments, in-app PDF viewer, add/edit/delete
- Assignments, exams, flashcards, mock exams, study studio
- Firestore rules hardened: no role self-promotion, one slot transition per write
- Cloudinary uploads for module files, plus `tool/purge_cloudinary.mjs` for orphan cleanup

## Phase 2 — Session lifecycle (in progress)

- [ ] Tutor completes an ended session; earnings count completed bookings only
- [ ] Tutor declines or cancels a booking; the slot frees itself
- [ ] Student list splits Upcoming / Past; no-show state

## Phase 3 — Tutor profile experience (next)

The tutor profile is five fields (name, subjects, rate, bio, room link) and the page
shows initials, a hardcoded "Verified" badge, and a public room link. Avatar upload is
a placeholder bypass that stores `https://example.com/...` URLs. `tutors/{uid}` is
world-readable, so private fields in that document are public today.

- [ ] P0 split public and private tutor data (`tutor_private/{uid}`); rules: owner plus admin only; frozen-field whitelist on update; validation for rate and text lengths
- [ ] P1 real avatar upload to Cloudinary with square crop, rendered on both cards and the profile page
- [ ] P2 content model: headline, about, languages, experience, education, certifications, teaching mode
- [ ] P3 owner editor: stepped form, completion meter, live preview, per-field validation
- [ ] P4 public page: header, trust strip, about, experience, languages, availability, policies, sticky book CTA
- [ ] Verified badge shown only when `verificationStatus == verified`

## Phase 4 — Messaging

- [ ] `chats/{chatId}` with a `messages` subcollection, one thread per booking
- [ ] Rules: participants only, no edits to sent messages, length cap
- [ ] Unread counts, entry points from booking detail and classroom

## Phase 5 — Reviews

- [ ] Student rates a completed session once; `rating` and `ratingCount` recomputed
- [ ] Reviews on the tutor profile, tutor reply

## Phase 6 — Launch hardening

- [ ] Rules unit tests (emulator needs JDK 21)
- [ ] Exam answer keys: tutor-only answers with server grading, or accept exposure
- [ ] Cloud Functions on Blaze: Cloudinary delete on file removal, notification emails
- [ ] PDPA: privacy notice, data export and delete, retention policy
- [ ] Store prep: icons, screenshots, release signing, Play data safety form

## Phase 7 — Deferred (deliberately last)

- [ ] Identity documents and admin review: private Storage upload, admin role, review queue, approve or reject
- [ ] Auth hardening: email verification, MFA, session revocation, account deletion
- [ ] Intro video on the tutor profile
- [ ] Real payments and tutor payouts (currently simulated)

## Decisions pending

- Which tutor fields are public versus private (surname, exact location, room link)
- Hourly sessions only, or lesson packages as well
- Blaze billing: unlocks Cloud Functions and server-side grading
- Identity-document retention window, when Phase 7 starts
