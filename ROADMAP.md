# TutorTap roadmap

_Last updated 25 Nov 2026 · `main` @ e2f4cca_

## Shipped

- Auth, onboarding, role select, student and tutor shells
- Browse, tutor profiles, availability slots
- Booking loop: slot lock, simulated checkout, confirmed booking, reschedule, cancel that frees the slot
- Classroom: courses, modules with multi-file attachments, in-app PDF viewer, add/edit/delete
- Assignments, exams, flashcards, mock exams, study studio
- Firestore rules hardened: no role self-promotion, one slot transition per write
- Cloudinary uploads for module files, plus `tool/purge_cloudinary.mjs` for orphan cleanup

## Phase 2 — Session lifecycle (in progress)

Completion is in; decline and the student Past split follow in the next slice.

- [x] Tutor completes an ended session; earnings count completed bookings only
- [ ] Tutor declines or cancels a booking; the slot frees itself
- [ ] Student list splits Upcoming / Past; no-show state

## Phase 3 — Tutor profile experience (done)

Committed in `e2f4cca`. Public profile carries headline, bio, languages, teaching
mode, experience, education and certifications; `meetingRoomInfo` and credential
URLs live in `tutor_private/{uid}`; avatar upload is real; the badge reads
`verificationStatus` instead of being hardcoded.

- [x] P0 split public and private tutor data; owner-only private document; validated profile writes
- [x] P1 real avatar upload to Cloudinary, rendered on cards and the profile page
- [x] P2 content model: headline, bio, languages, experience, education, certifications, teaching mode
- [x] P3 owner editor: completion meter, chip inputs, repeatable entries, validation
- [x] P4 public page: header, about, experience, languages, availability, policies, sticky CTA
- [x] Badge shown only when `verificationStatus == verified`, labelled Reviewed

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

- Which tutor fields are public versus private (surname, exact location) - room link resolved: private
- Hourly sessions only, or lesson packages as well
- Blaze billing: unlocks Cloud Functions and server-side grading
- Identity-document retention window, when Phase 7 starts
