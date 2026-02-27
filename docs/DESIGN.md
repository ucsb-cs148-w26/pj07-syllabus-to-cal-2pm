# Plannr Design Document

## Table of Contents

1.  [Project Overview](#project-overview)
2.  [High-Level System Architecture](#high-level-system-architecture)
3.  [Detailed Software Architecture Design](#detailed-software-architecture-design)
4.  [Design Process Documentation](#design-process-documentation)
5.  [User Interface and User Experience (UX) Considerations](#user-interface-and-user-experience-ux-considerations)
6.  [Technology Stack](#technology-stack)
7.  [Database Design](#database-design)
8.  [API Design](#api-design)
9.  [Security Considerations](#security-considerations)
10.  [Future Enhancements](#future-enhancements)

## Project Overview

**Plannr** is an iOS application that streamlines academic planning by extracting important dates from course syllabi and automatically integrating them into users’ Google Calendars. The app uses AI-powered document parsing to identify key dates such as exam dates, assignment due dates, and important course milestones.

### Key Features

-   PDF and image syllabus upload
-   AI-powered date extraction using Google’s Gemini API
-   Google OAuth authentication and Calendar API integration
-   Interactive calendar preview with event editing capabilities
-   Color-coded class organization
-   Export to various calendar formats (iCal, CSV)

### Target Users

-   College students managing multiple course schedules
-   Students who want automated syllabus-to-calendar conversion
-   Users seeking better academic time management tools

## High-Level System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   iOS Frontend  │◄──►│  Python Backend  │◄──►│ External APIs   │
│    (Swift UI)   │    │   (FastAPI)      │    │                 │
└─────────────────┘    └──────────────────┘    │ • Google OAuth  │
                                ▲              │ • Calendar API  │
                                │              │ • Gemini AI     │
                                ▼              └─────────────────┘
                       ┌──────────────────┐
                       │ SQLite Database  │
                       │                  │
                       │ • User Profiles  │
                       │ • Syllabi Data   │
                       │ • Calendar Events│
                       │ • OAuth Tokens   │
                       └──────────────────┘
```

### Architecture Components

**1\. iOS Frontend (Swift)**

-   Handles user authentication and session management
-   Provides intuitive UI for syllabus upload (camera, file picker)
-   Displays parsed events in an interactive calendar preview
-   Allows users to edit, approve, or decline extracted events
-   Manages Google OAuth flow and deep linking

**2\. Python Backend (FastAPI)**

-   RESTful API server handling all business logic
-   Document processing (PDF parsing, image OCR)
-   AI integration with Google Gemini for intelligent date extraction
-   Google Calendar API integration for event synchronization
-   User session and credential management

**3\. SQLite Database**

-   Lightweight, file-based database for local data storage
-   Stores user authentication tokens securely
-   Maintains syllabus parsing history and user preferences
-   Caches calendar event data for offline access

**4\. External Service Integration**

-   **Google OAuth 2.0**: Secure user authentication and authorization
-   **Google Calendar API**: Two-way calendar synchronization
-   **Google Gemini AI**: Advanced document understanding and date extraction

## Detailed Software Architecture Design

### Frontend Architecture (iOS - Swift)

```swift
PlannrApp (Main App Entry Point)
├── Views/
│   ├── SignInView          // Google OAuth login
│   ├── LandingView         // Main dashboard
│   ├── SyllabusUploadView  // File/camera upload
│   ├── CalendarPreviewView // Event review & editing
│   └── AddClassView        // Class management
├── Managers/
│   ├── AuthManager         // Authentication state
│   └── ClassManager        // Course data management
└── Models/
    └── EventFixtures       // Data models for events
```

**Key Frontend Components:**

-   **AuthManager**: Centralized OAuth state management using `@StateObject` and `@Published` properties for reactive UI updates
-   **URL Scheme Handling**: Deep linking support for OAuth callbacks (`plannr://auth/callback`)
-   **SwiftUI Navigation**: Declarative UI with environment objects for shared state
-   **File Upload**: Support for both camera capture and document picker

### Backend Architecture (Python - FastAPI)

```python
app.py (Main FastAPI Application)
├── Endpoints/
│   ├── /auth/google        // OAuth initiation
│   ├── /auth/callback      // OAuth callback handling
│   ├── /upload/syllabus    // File upload processing
│   ├── /parse/syllabus     // AI-powered parsing
│   ├── /calendar/sync      // Google Calendar integration
│   └── /export/{format}    // Multi-format export
├── Services/
│   ├── Document Processing // PDF/image handling
│   ├── AI Integration     // Gemini API interaction
│   └── Calendar Service   // Google Calendar operations
└── Database/
    └── db_manager.py      // SQLite operations
```

**Key Backend Components:**

-   **Document Processing Pipeline**: PyPDF2 for PDF text extraction, with plans for OCR support
-   **AI Service Integration**: Structured prompts to Gemini API for reliable date extraction
-   **OAuth Flow Management**: Server-side Google OAuth with secure token storage
-   **Calendar Synchronization**: Bidirectional sync with conflict resolution

### Database Schema

```sql
CREATE TABLE users (
    email TEXT UNIQUE NOT NULL PRIMARY KEY,
    google_credentials TEXT,  -- JSON-stored OAuth tokens
    calendar TEXT,            -- JSON-stored calendar preferences
    syllabi TEXT              -- JSON-stored syllabus history
);
```

## Design Process Documentation

### Important Team Decisions

This section will document key architectural and design decisions made during team meetings. Key decisions to be tracked include:

1.  **Technology Stack Selection** (Meeting: Sprint 1, Week 2)
    
    -   Decision: Swift for native iOS experience vs. React Native
    -   Rationale: Better performance and access to iOS-specific features
    -   Impact: Single-platform deployment, steeper learning curve
2.  **AI Service Selection** (Meeting: Sprint 1, Week 3)
    
    -   Decision: Google Gemini vs. OpenAI GPT for document parsing
    -   Rationale: Better integration with existing Google services ecosystem
    -   Impact: Simplified authentication flow, consistent API experience
3.  **Database Architecture** (Meeting: Sprint 2, Week 1)
    
    -   Decision: SQLite vs. PostgreSQL for data storage
    -   Rationale: Lightweight deployment, sufficient for current scale
    -   Impact: Simpler setup, future migration considerations for scaling

*Note: This section should be expanded as team meetings progress, with references to specific meeting notes in the team/ directory.*

## User Interface and User Experience (UX) Considerations

### User Flow Diagram

```
[App Launch] → [Sign In] → [Landing Page] → [Upload Syllabus] 
      ↓
[AI Processing] → [Calendar Preview] → [Edit Events] → [Sync to Google Calendar]
      ↓
[Export Options] → [Class Management] → [Settings]
```

### Detailed User Journey

1.  **Authentication Flow**
    
    -   Users sign in via Google OAuth for seamless integration
    -   Deep linking handles callback URL for native app experience
    -   Persistent login state maintained locally
2.  **Syllabus Upload Experience**
    
    -   Dual input methods: camera capture or file selection
    -   Visual feedback during upload and processing
    -   Progress indicators for AI parsing operations
3.  **Event Review & Editing**
    
    -   Interactive calendar view with color-coded events
    -   In-line editing capabilities for dates, titles, and descriptions
    -   Batch operations for accepting/declining multiple events
4.  **Calendar Integration**
    
    -   Real-time preview before committing changes
    -   Conflict detection and resolution suggestions
    -   Multi-format export options (iCal, CSV, Google Calendar)

### Design Principles

-   **Simplicity First**: Minimize steps from upload to calendar integration
-   **Visual Clarity**: Clear iconography and color coding for different event types
-   **Error Recovery**: Graceful handling of parsing errors with manual correction options
-   **Accessibility**: VoiceOver support and dynamic type sizing

## Technology Stack

### Frontend

-   **Swift 5.x**: Native iOS development
-   **SwiftUI**: Declarative UI framework
-   **Combine**: Reactive programming for state management

### Backend

-   **Python 3.9+**: Server-side development
-   **FastAPI**: High-performance web framework
-   **PyPDF2**: PDF text extraction
-   **SQLite3**: Embedded database

### External Services

-   **Google Gemini AI**: Document understanding and parsing
-   **Google OAuth 2.0**: User authentication
-   **Google Calendar API**: Calendar synchronization

### Development Tools

-   **Xcode**: iOS development environment
-   **Postman**: API testing and documentation
-   **Git/GitHub**: Version control and collaboration

## Database Design

### Current Schema

The application uses a simple JSON-based storage approach within SQLite for rapid prototyping:

```python
# User table structure
{
    "email": "user@example.com",
    "google_credentials": {
        "access_token": "...",
        "refresh_token": "...",
        "expires_at": "..."
    },
    "calendar": {
        "preferences": {...},
        "color_mappings": {...}
    },
    "syllabi": [
        {
            "filename": "CS148_syllabus.pdf",
            "parsed_events": [...],
            "upload_timestamp": "..."
        }
    ]
}
```

### Future Normalization Considerations

For production scaling, consider normalizing into:

-   `users` table (core user info)
-   `syllabi` table (uploaded documents)
-   `events` table (extracted calendar events)
-   `user_preferences` table (settings and preferences)

## API Design

### Core Endpoints

Endpoint

Method

Description

`/auth/google`

GET

Initiate Google OAuth flow

`/auth/callback`

GET

Handle OAuth callback

`/upload/syllabus`

POST

Upload syllabus file

`/parse/syllabus/{id}`

POST

Trigger AI parsing

`/calendar/sync`

POST

Sync events to Google Calendar

`/export/ical`

GET

Export as iCal format

`/export/csv`

GET

Export as CSV format

### Request/Response Examples

```python
# Upload syllabus
POST /upload/syllabus
Content-Type: multipart/form-data
{
    "file": <binary data>,
    "course_name": "CS 148"
}

# Response
{
    "syllabus_id": "uuid",
    "filename": "CS148_syllabus.pdf",
    "status": "uploaded"
}
```

## Security Considerations

### Authentication & Authorization

-   Google OAuth 2.0 with secure token storage
-   JWT-based session management
-   Refresh token rotation for long-term access

### Data Protection

-   Encrypted storage of sensitive credentials
-   HTTPS enforcement for all API communications
-   Input validation and sanitization for file uploads

### Privacy Compliance

-   Minimal data collection principle
-   User consent for calendar access
-   Data retention policies documented in privacy policy

## Future Enhancements

### Phase 2 Features

-   **Advanced AI Features**: Improved Natural language event descriptions
-   **Collaboration**: Shared calendars for study groups
-   **Integration Expansion**: Outlook, Apple Calendar support

### Technical Improvements

-   **Caching Strategy**: Redis for improved performance
-   **Database Migration**: PostgreSQL for production scaling
-   **Monitoring**: Application performance monitoring (APM)
-   **CI/CD Pipeline**: Automated testing and deployment

### User Experience Enhancements

-   **Offline Support**: Local calendar caching
-   **Smart Notifications**: Intelligent deadline reminders
-   **Analytics Dashboard**: Study schedule insights
-   **Customization**: Themes and personalization options

---

*This document is a living document that will be updated as the project evolves. Last updated: February 27, 2026*
