# Syllabus to Calendar App 
Our Syllabus to Calendar app is an iOS app that takes in a user's syllabi and exports the important due dates, such as exams, homeworks, and more, to their Google Calendar. 

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

## Installation

### Prerequisites

run pip install -r requirements.txt

Dependencies

TODO: List which libraries / add-ons you added to the project, and the purpose each of those add-ons serves in your app.

Installation Steps

TODO: Describe the installation process (making sure you give complete instructions to get your project going from scratch). Instructions need to be such that a user can just copy/paste the commands to get things set up and running. Note that with the use of GitHub Actions, these instructions can eventually be fully automated (e.g. with act, you can run GitHub Actions locally).

Functionality

TODO: Write usage instructions. Structuring it as a walkthrough can help structure this section, and showcase your features.

Known Problems

TODO: Describe any known issues, bugs, odd behaviors or code smells. Provide steps to reproduce the problem and/or name a file or a function where the problem lives.
