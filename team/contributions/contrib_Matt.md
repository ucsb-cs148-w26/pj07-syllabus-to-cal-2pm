# Code Contributions – Matt Blanke

## Google OAuth & Authentication
- Built the initial landing page UI with Sign In / Sign Up buttons ([6880688](../../Plannr/Plannr/LandingView.swift))
- Implemented full Google OAuth flow: `AuthManager.swift` handles token exchange, stores the authenticated user in the backend after login ([b032824](../../Plannr/Plannr/AuthManager.swift))
- Fixed a redirect issue that occurred after sign-in/sign-up ([e3c9e4c](../../backend/app.py))
- Fixed an OAuth CSRF vulnerability by validating the `state` parameter on the backend callback route, and wrote 126-line test suite (`backend/tests/test_oauth_state.py`) covering the fix ([ff67712](../../backend/tests/test_oauth_state.py))

## Calendar Preview & Google Calendar Sync
- Added Accept All / Decline All buttons and a Sync button to `CalendarPreviewView.swift`, enabling users to bulk-accept or reject parsed events ([1e05399](../../Plannr/Plannr/CalendarPreviewView.swift))
- Implemented Google Calendar syncing: authenticated API calls that push accepted events to the user's Google Calendar ([d1c26f4](../../Plannr/Plannr/CalendarPreviewView.swift))
- Fixed an urgent syncing bug that prevented events from being pushed correctly ([f2b47b9](../../Plannr/Plannr/CalendarPreviewView.swift))

## .ics / .csv Export
- Added `.ics` and `.csv` export options to `CalendarPreviewView.swift` (iOS side) and `backend/app.py` (server-side generation), along with a full export test suite (`backend/tests/test_export.py`, 104 lines) ([8f8a809](../../backend/tests/test_export.py))

## Web / Marketing Site
- Created the GitHub Pages homepage (`index.html`) with footer, privacy policy, and Terms of Service pages ([ad948e3](../../docs/index.html), [7e63860](../../docs/))

## Testing & QA
- Wrote backend CSRF tests (`backend/tests/test_oauth_state.py`) – 126 lines covering valid/invalid state parameters ([ef1362f](../../backend/tests/test_oauth_state.py))
- Wrote export endpoint tests (`backend/tests/test_export.py`) – 104 lines covering `.ics` and `.csv` generation ([8f8a809](../../backend/tests/test_export.py))
- Documented component testing approach in `team/TESTING.md` and updated `.env.SAMPLE` ([9af7702](../../team/TESTING.md))

## Project Setup & Environment
- Added `.gitignore` and MIT `LICENSE.md` at project initialization ([34c4165](../../.gitignore))
- Added `.env.SAMPLE` to document required environment variables ([f30fe02](../../backend/.env.SAMPLE))
- Added the initial SwiftUI `HelloWorld` app scaffolding ([8196b2d](../../Plannr/))

## UI Overhaul & Navigation Flow (Mar 6–9)
- Redesigned UI flow so users add a class first, return to My Classes, then select a class to upload a syllabus for, feeding into `PDFUploadView` ([517a05a](../../Plannr/Plannr/PDFUploadView.swift))
- Added redirect back to My Classes page after syncing events to Google Calendar ([6d4154f](../../Plannr/Plannr/CalendarPreviewView.swift))
- Built `UnifiedCalendarView.swift` (442 lines) — a combined calendar view showing events across all classes with a sidebar menu ([bb90c4a](../../Plannr/Plannr/UnifiedCalendarView.swift))
- Added Upcoming Events section and made calendar events tappable/clickable ([bb90c4a](../../Plannr/Plannr/PDFUploadView.swift))
- Added profile button with full functionality in `PDFUploadView` ([5285c2c](../../Plannr/Plannr/PDFUploadView.swift))
- Added placeholder app icon assets ([bb90c4a](../../Plannr/Plannr/))

## Guest Mode (Mar 6–7)
- Implemented guest sign-in flow in `SignInView.swift` and `AuthManager.swift` — users can try the app without a Google account ([0a9008a](../../Plannr/Plannr/SignInView.swift))
- Fixed guest users being unable to upload PDFs ([cd2e00c](../../Plannr/Plannr/ClassEditView.swift))
- Added guest mode class interactions: guests can create classes and upload syllabi, but syncing to GCal is disabled ([1416643](../../Plannr/Plannr/CalendarPreviewView.swift))

## Class Management & Editing (Mar 7)
- Built `ClassEditView.swift` (566 lines) — a dedicated class editing page allowing users to rename classes, set end dates, and manage class-specific settings ([e7add8f](../../Plannr/Plannr/ClassEditView.swift))
- Added editable class name and class end date fields, with corresponding backend support in `app.py` ([13d94a6](../../Plannr/Plannr/ClassEditView.swift))
- Added inactive date support and tested deleting a class event removing its secondary Google Calendar ([f58b16c](../../Plannr/Plannr/ClassEditView.swift))
- Bug fixes across `CalendarPreviewView`, `ClassEditView`, and `SyllabusUploadView` following the class editing PR merge ([9091ff5](../../Plannr/Plannr/ClassEditView.swift))

## Re-upload Syllabus Fix (Mar 9)
- Fixed "Upload New Syllabus" functionality so re-uploading a PDF correctly replaces existing calendar events rather than duplicating them ([3f514b2](../../Plannr/Plannr/SyllabusUploadView.swift))
