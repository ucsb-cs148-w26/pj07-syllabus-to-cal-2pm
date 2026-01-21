Project: Syllabus to Calendar

Meeting Time: lect02 - 1.12.26

Type of meeting: Sprint01 Planning Meeting

Team: Matt [x], Divyani [x], Jiaming [x], Divya [x], Saeed [x], Avaneesh [x], Yuhang [x], Arya [x]

## Sprint 01 Goal
Deliver a **minimum viable product (MVP)** that demonstrates an end-to-end workflow:
1. User logs in
2. User uploads a syllabus (PDF)
3. Backend parses important dates and tasks
4. Parsed tasks are displayed to the user
5. User can add tasks to Google Calendar

This sprint prioritizes **core functionality over UI polish**.

---

## MVP Scope: Work Breakdown

### 1. Authentication (Login)
**Objective:** Enable users to securely log in to the app.

**Tasks**
- Google OAuth sign-in (iOS)
- Backend token verification
- Create or fetch user record in database

**Definition of Done**
- User can log in and access the main app screen

---

### 2. Syllabus Upload (Frontend)
**Objective:** Allow users to upload a syllabus PDF.

**Tasks**
- PDF file picker UI
- Upload progress indicator
- Error handling for invalid files
- Send file to backend API

**Definition of Done**
- PDF is successfully uploaded to the backend

---

### 3. Backend API Endpoints
**Objective:** Support the full MVP workflow.

**Endpoints**
- `POST /upload` – accept syllabus file
- `POST /parse` – extract text and dates
- `POST /calendar/sync` – create Google Calendar events

**Definition of Done**
- Endpoints function correctly and return valid responses

---

### 4. Syllabus Parsing
**Objective:** Extract tasks and important dates from uploaded syllabi.

**Tasks**
- PDF text extraction
- Date parsing using regex and dateparser
- Normalize tasks (title, date, description)

**Definition of Done**
- Backend returns a structured list of parsed tasks

---

### 5. Display Parsed Tasks (Frontend)
**Objective:** Show parsed tasks to the user before syncing.

**Tasks**
- Display list of parsed tasks
- Basic task details (title, due date)
- Handle empty or partial results

**Definition of Done**
- User can clearly view parsed tasks in the app

---

### 6. Google Calendar Integration
**Objective:** Add confirmed tasks to the user’s Google Calendar.

**Tasks**
- Google Calendar API integration
- Create calendar events
- Handle success and failure responses

**Definition of Done**
- Tasks appear correctly in the user’s Google Calendar

---

## Out of Scope for Sprint 01
- UI polish and animations
- Support for non-PDF files (DOCX, pictures, etc.)
- Advanced AI-based parsing
- Conflict detection and reminders
- Admin dashboards

---

## Notes
- Each task should be owned by at least one team member
- Cross-team coordination required for API contracts
- Focus on a clean demo-ready flow




