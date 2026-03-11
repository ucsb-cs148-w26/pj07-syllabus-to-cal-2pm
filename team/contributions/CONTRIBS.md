# Code Contributions – Arya Sadeghi (@AryaSadeghi21)



## AI & Syllabus Parsing Engine

-   Built the AI syllabus parsing functionality  to extract calendar events from PDF syllabi ([f434bfe](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/f434bfe))
-   Implemented the core syllabus processing workflow with error handling and event extraction ([1acca85](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/1acca85))
-   Enhanced Gemini prompt engineering to support multiple class processing in a single request ([e39a407](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/e39a407))
-   Added syllabus validation to prevent non-syllabus uploads and improve parsing accuracy ([4ec2616](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/4ec2616))
-   Fixed prompt validation to ensure non-syllabus documents return appropriate error messages ([43220a5](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/43220a5), [2e50158](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/2e50158))
-   Refined system prompts for better API call accuracy and reliability ([95f1d10](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/95f1d10)) (also multiple other commits)

## User Interface & Experience

-   Created the "Weekly Dashboard View" page UI and backend support, including your week at a glance, how busy your weekend will be, and the ability to check off events that have been completed ([f0ad395](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/f0ad395e124675a3faf93595eae263e325611361))
-   Updated and modernized the Sign In page UI to improve user experience ([75468ff](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/75468ff))
-   Fixed and enhanced the landing page UI with better visual design and layout ([5b60d8f](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/5b60d8f))
-   Contributed to recent UI revisions and added new feature requests based on user feedback ([5738b88](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/5738b88))

## Project Setup & Documentation

-   Expanded Plannr design document with comprehensive technical specifications ([37010a2](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/37010a2))
-   Established team NORMS file for project collaboration standards ([8f01bc4](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/8f01bc4))
-   Enhanced README with installation steps and detailed functionality sections ([56ee5b1](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/56ee5b1))
-   Revised section headers and improved README structure and clarity ([793f580](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/793f580))

## Project Management & Planning

-   Created initial user stories and the original the idea behind "Plannr" (no specific commit)
-   Distributed work across team members, created new tickets and features to add, and ensured the project flow stayed smooth. (no specific commit)
-   Created retrospective meeting notes and documentation structure (RETRO\_02.md) ([6285bda](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/6285bda))
-   Updated retrospective documentation with team insights and progress tracking ([d7b6f8c](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/d7b6f8c))
-   Added MVP demo link and presentation materials ([246edda](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/246edda))
-   Added stand-up notes and established sprint 02 priorities and planning ([e2205b7](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/e2205b7))

# Code Contributions – Avaneesh Vinoth Kannan

## UI Updates

Updated the UI for the tasks extracted by Gemini to improve layout and readability.

- Updated the card view displaying extracted tasks to fill the screen
- Adjusted the layout to create a cleaner and more readable interface

## Input Handling Development

Implemented multiple input methods to allow users to provide content in different formats.

- Added support for PDF input so users can upload and process PDF documents
- Implemented gallery upload functionality to allow users to select images from their device
- Developed image scanning capability to capture images directly through the device camera
- Added text input functionality to allow users to manually enter text for processing

## Input Integration

Integrated the different input types into the application workflow for consistent processing.

- Converted different input types into PDF format to improve Gemini parsing and processing
- Handled file preparation and temporary storage before sending inputs to Gemini
- Added error handling for cases where file uploads or scans failed

# Divy's Contribution

**Sign Up / Authentication**
- Added input validation for the sign-up flow, enforcing required fields, valid email format, minimum password length (8+ characters), and matching password confirmation with inline error display ([34dc7c5](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/34dc7c56e604a504d5fd58eeb2d56f626a146bcf))

**Calendar Preview**
- Designed and built `CalendarPreviewView`, a new page component displaying an interactive calendar with toggleable weekly/monthly views and a daily view on day selection ([2c4519d](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/2c4519d56c24632e9d23aa8fddaa50d13cea5009))
- Added a scrollable event list alongside the calendar with colored labels for event type and descriptions ([2c4519d](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/2c4519d56c24632e9d23aa8fddaa50d13cea5009))
- Added a fixtures file to mock `POST /syllabus` responses, enabling frontend development and testing without requiring backend calls ([2c4519d](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/2c4519d56c24632e9d23aa8fddaa50d13cea5009))
- Updated `PDFUploadView` to automatically navigate to the preview page upon successful parse ([2c4519d](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/2c4519d56c24632e9d23aa8fddaa50d13cea5009))

**Testing**
- Wrote 5 unit tests for `CalendarPreviewView` event filtering logic in `PlannrTests/CalendarPreviewViewTests.swift`, covering date filtering, type filtering, event counting, and edge cases ([ec0479e](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/ec0479e918d9c8f73b51f43df2e8cf29850929d1))
- Authored `team/TESTING.md` documenting the team's testing library selection (XCTest vs Jest) and overall testing approach ([ec0479e](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/ec0479e918d9c8f73b51f43df2e8cf29850929d1))

**Error Handling**
- Added an error message for non-syllabus or empty file uploads, surfacing feedback to the user when no events are detected ([f32fdf4](https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm/commit/f32fdf4abd75207a1fd2d01b3a9b66c67481f8e3))


**Camera Scan & OCR Upload**
- Fixed onScanComplete firing before controller.dismiss in SyllabusUploadView.swift, preventing scanned images from being dropped; fixed double-slash bug in the /syllabus endpoint URL; updated upload button label (#154)
- Added OCR fallback in app.py's extract_text_from_pdf using pytesseract + pdf2image so scanned/image-based PDFs that return empty text from PyPDF2 are still parsed correctly (#154)

**Export (CSV / ICS)**
- Filtered CSV and ICS exports to only include events with accepted status, excluding declined and pending events (#148)
- Added accepted event count display in the export modal (e.g. "3 accepted events will be exported") and a warning when no events have been accepted yet (#148)

**Sync Sessions**
- Added a "View Sync Sessions" button on the class page (visible after at least one sync), recording a timestamped snapshot of synced events on every first-time sync and re-sync and appending it to session history
- Built a Sync Sessions page listing all past sessions, each expandable to show the full event list that was synced at that time


# Contributions -- Divya Subramonian


## Frontend: Homepage and App Structure

- Built the initial homepage `ContentView`, replacing the placeholder Hello World screen with a functional landing UI (d32a5a1)
- Redesigned main page layout to support multiple classes/syllabi, enabling users to manage more than one course at a time (`AddClassView.swift`, `SyllabusUploadView.swift`, `ClassManager.swift`) (2f379d1)
- Fixed main page edge case when no classes exist yet (2d23ea2)
- These structural changes formed the backbone of the app’s multi-syllabus flow, splitting our application into distinct, navigable screens (architectural contribution that allowed the rest of the team to build on top of the frontend)

 
## PDF Upload Feature

- Implemented the baseline PDF upload feature, allowing users to select and submit syllabus documents from their device for processing (`PDFUploadView.swift`) (9a68161)


## Calendar Preview: Event Editing and Color Selection

- Added per-event accept, decline, and edit options on the Calendar Preview page (`CalenderPreviewView.swift`), giving users control over which parsed events to keep and how to modify them (9bafda7)
- Built a color selector feature so users can assign custom colors to events on the Calendar Preview page, improving visual organization (865a925, 9a05513)
- These features made the preview page an editing surface rather than a read-only list (a UX improvement that lets users fine-tune their calendar before syncing)


## Miscellaneous - Documentation and Merging
 
- Drafted and improved team agreements document, establishing norms for collaboration (8731c17, 9f11919)
- Added user journey to team documentation to guide product direction (dcd109e)
- Maintained and updated `README` with current project information (dbd8bb6, 5d3cae2)
- Contributed team members' learning reflections to `LEARNING.md` and updated the file (6fcfd21, a3425e1)
- Updated `AI_CODING.md` with reflections on AI-assisted development practices (91ceea1, a6f2ff3, 01cc74c)
- Updated `LEADERSHIP.md` to document team leadership (11084b2, 5c9a32d)
- Wrote and expanded `MANUAL.md` with documentation covering all major app features and purposes (cac8891, 23cfc84)

# Code Contributions – Jiaming Liu

## Backend development

Defined the initial API endpoints for the backend
using FastAPI.

## Backend deployment

Together with Yuhang:

- Deployed the backend to our cloud Linux server
- Set up DNS `https://cs148.misc.iamjiamingliu.com/cs148api` to point to the server
- Set up Github actions and workflows for CI CD

## iOS development

- Updated various aspects of the iOS codebase to ensure the app is in the navy blue and gold color theme
- Refactored the events preview page to ensure a clean UI with minimal cluttering and intuitive UX

## iOS deployment

Consulted for the team with my experience of iOS app store deployment,
shared my knowledge on what is needed to deploy an app onto the app store

## App Icon Design

Designed on Canvas the app logo.

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


# Code Contributions – Yuhang Jiang

## Database Management
- Implmeneted the whole database program `db_manager.py` storing necessary user's info with fetching and updating functions ([70abd18](../../backend/database/db_manager.py))
- Fixed path resolving issue of the database storage file, and move the path under `.env` to protect privacy ([70abd18](../../backend/database/db_manager.py))

## Production Server Setup & Maintenance
- Built and run the service app on the production server
- Migrated the localhost url to the actual production server on the Google Cloud Console
- Setup TLS certificates and Proxy to make `https://cs148.misc.iamjiamingliu.com/cs148api` usable

## Auto-deployment Script
- Updated the script `CD.yaml` that github action would automatically login into the server, synchronize with main, and restart the server ([57feb28](../../.github/workflows/CD.yaml))

## Database Testing
- Wrote backend database tests (`backend/tests/test_db_manager.py`) – 121 lines covering valid/invalid parameters for fetching and updating funtions, also mocking the connection erros ([b831e40](../../backend/tests/test_db_manager.py))
- Documented component testing approach in `team/TESTING.md`([54809f9](../../team/TESTING.md)) 

## Deployment Documentation
- Updated the deployment procedures in the `readme.md` ([00c63d6](../../README.md))
- Created a detailed and live documentation on deployment procedures in `DEPLOY.md` ([18a07a5](../../docs/DEPLOY.md))

  
