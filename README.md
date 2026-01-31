# Plannr
Plannr is an iOS app that takes in a user's syllabi and exports the important due dates, such as exams, homeworks, and more, to their Google Calendar. 

A student can:
- Upload syllabi as a picture or PDF
- Provide feedback if the syllabi-to-calendar conversion isn't entirely correct
- Edit/accept/decline color-coded events
- Log into Google account
- Specify which syllabi corresponds to which class (color/label)

## Group Members
- Arya Sadeghi: @AryaSadeghi21
- Yuhang Jiang: @yuhangj554
- Divyani Punj: @divyanipunj
- Matt Blanke: @m4ttblanke
- Jiaming Liu: @iamjiamingliu
- Divya Subramonian: @divyagsubramonian
- Avaneesh Vinoth Kannan: @AvaneeshVinothK

## Tech Stack
We will be using:
- Swift (primarily for frontend development)
- SQLite (for database)
- Python (for backend development)
- Google OAuth (to connect accounts to calendar)
- Google Calendar API (RESTful API for defining endpoints)

## User Roles and Permissions
### 1. User (Student)
### Description
End users of the app (students) who upload syllabi, review extracted dates, and sync events to their own Google Calendar.

### Permissions

#### Authentication & Account
- Sign in via Google OAuth 2.0
- Sign out
- Revoke Google Calendar access

#### Syllabus Management
- Upload syllabus files (PDF, DOCX)
- View own uploaded syllabi
- Delete own uploaded syllabi
- Re-upload updated syllabus versions

#### Parsing & Review
- Trigger syllabus parsing
- View extracted events (assignments, exams, deadlines)
- Edit parsed event details (title, date, time, description)
- Approve or reject extracted events before syncing

#### Google Calendar Integration
- Select target Google Calendar
- Create events in Google Calendar
- Update events previously created by the app
- Delete events created by the app
- View sync history and status (success/failure)

#### Data Access Restrictions
- Can only access:
  - Their own uploads
  - Their own parsed events
  - Their own calendar sync jobs
  - Their own Google OAuth tokens
 
### 2. Admin
### Description
System administrators responsible for maintaining app health, monitoring usage, and handling errors.

### Permissions

#### All User Permissions
- Full access to all User-level features

#### System Monitoring
- View system-wide usage metrics (number of uploads, parses, syncs)
- View parsing error logs and failures
- Inspect background job status

#### User Management
- View user accounts (metadata only)
- Disable or suspend abusive users
- Enforce rate limits

#### Configuration & Maintenance
- Enable or disable parsing features (e.g., AI-assisted parsing)
- Configure max upload sizes and allowed file types
- Manage environment-level settings
- Perform database maintenance tasks

#### Data Access Boundaries
- Admins **do not** modify user calendars directly
- Admins **do not** view full syllabus contents unless explicitly required for debugging

## Deployment
Since we are building an iOS app, we use the simulator on Xcode to test/view our app's functionality.

# Installation

## Prerequisites

- **Xcode 15+** (with iOS 17+ SDK) — for building and running the iOS app
- **Python 3.10+** — for running the backend server
- **pip** — Python package manager
- **Git** — for cloning the repository
- A **Google Cloud project** with the following APIs enabled:
  - Google Calendar API
  - Google OAuth 2.0
  - Gemini API (Google Generative AI)

## Dependencies

### iOS App (Plannr)
The iOS app uses only native Apple frameworks (no third-party dependencies):
- **SwiftUI** — declarative UI framework
- **AuthenticationServices** — Google OAuth sign-in flow
- **UniformTypeIdentifiers** — PDF file type identification for the file picker

### Python Backend
- **FastAPI** — web framework for the REST API
- **Uvicorn** — ASGI server for running FastAPI
- **google-generativeai** — Google Gemini AI SDK for syllabus parsing
- **PyPDF2** — PDF text extraction
- **python-dotenv** — environment variable management
- **google-auth / google-auth-oauthlib** — Google OAuth 2.0 authentication
- **google-api-python-client** — Google Calendar API client
- **python-multipart** — multipart form-data parsing for file uploads
- **pydantic** — request/response data validation

## Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ucsb-cs148-w26/pj07-syllabus-to-cal-2pm.git
   cd pj07-syllabus-to-cal-2pm
   ```

2. **Set up the backend:**
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate   # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Configure environment variables:**
   ```bash
   cp .env.SAMPLE .env
   ```
   Then edit `backend/.env` and fill in your credentials:
   - `GEMINI_API_KEY` — your Google Gemini API key
   - `GOOGLE_CLIENT_ID` — your Google OAuth client ID
   - `GOOGLE_CLIENT_SECRET` — your Google OAuth client secret
   - `GOOGLE_REDIRECT_URI` — defaults to `http://localhost:8000/auth/callback`

4. **Start the backend server:**
   ```bash
   uvicorn app:app --host 0.0.0.0 --port 8000 --reload
   ```

5. **Open the iOS project in Xcode:**
   ```bash
   open Plannr/Plannr.xcodeproj
   ```

6. **Run the iOS app** on a simulator or device from Xcode (select a target and press Cmd+R).

# Functionality

1. **Sign In** — Tap "Sign In with Google" to authenticate via Google OAuth. This grants the app permission to add events to your Google Calendar.
2. **Upload Syllabus** — Tap "Upload PDF" to select a syllabus PDF from your device. The file is sent to the backend for parsing.
3. **Review Parsed Events** — After parsing, you are taken to the Calendar Preview screen where extracted events (homework, exams, quizzes, labs) are displayed in a weekly/monthly calendar view with color-coded cards.
4. **Sync to Google Calendar** — Tap "Sync!" to push the parsed events to your Google Calendar as all-day events.

# Known Problems

- The backend URL is currently hardcoded to `http://localhost:8000` in `PDFUploadView.swift`, so the iOS app only works when the backend is running locally on the same machine as the simulator.
- OAuth redirect requires the iOS simulator or a device that can handle the `plannr://` custom URL scheme.

# Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

# License

This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for details.
