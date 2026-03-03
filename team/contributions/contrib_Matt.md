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
