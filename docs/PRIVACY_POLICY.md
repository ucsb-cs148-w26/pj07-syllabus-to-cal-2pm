# Privacy Policy for Plannr

*Last updated: January 28, 2025*

## 1. Introduction

Plannr ("we," "our," or "the App") is a student productivity tool that extracts key dates from course syllabi and syncs them to your Google Calendar. This privacy policy explains what data we collect, how we use it, and how you can request deletion.

## 2. Data We Collect

When you use Plannr, we collect and process the following:

- **Google Account Information:** Your name and email address, obtained through Google Sign-In.
- **Google OAuth Credentials:** Access and refresh tokens that allow Plannr to interact with your Google Calendar on your behalf.
- **Syllabus Documents:** PDF files you upload for parsing. These are processed to extract assignment due dates, exam dates, quiz dates, and other course deadlines.
- **Calendar Events:** The parsed event data (titles, dates, descriptions, and event types) generated from your syllabi.

## 3. How We Use Your Data

- **Authentication:** Your Google account information is used to identify you and maintain your session.
- **Syllabus Parsing:** Uploaded PDF content is sent to Google's Gemini API to extract structured calendar event data. We do not retain the raw PDF content after processing.
- **Calendar Syncing:** Your OAuth credentials are used to create events in your Google Calendar on your behalf. Events are added as all-day entries to your primary calendar.
- **Account Management:** Your email address serves as your unique account identifier in our system.

## 4. Third-Party Services

Plannr relies on the following Google services to function:

- **Google OAuth 2.0** — for authentication
- **Google Calendar API** — for creating calendar events
- **Google Gemini API** — for analyzing syllabus content and extracting dates

Your data is handled in accordance with [Google's Privacy Policy](https://policies.google.com/privacy). We do not sell, share, or distribute your data to any other third parties.

## 5. Data Storage

- Account information and OAuth credentials are stored on our backend server in a local database.
- The iOS app stores only your name and email locally on your device.
- We do not use analytics services or third-party tracking tools.

## 6. Data Retention

Your data is retained for as long as your account exists. Syllabus content is processed in memory and is not stored persistently after events have been extracted.

## 7. Requesting Data Deletion

You may request complete deletion of your account and all associated data at any time by contacting us at **plannr.ucsb@gmail.com**. Upon receiving your request, we will:

- Delete your account record and stored OAuth credentials from our database
- Remove any calendar or syllabus data associated with your account

Please note that events already synced to your Google Calendar will remain in your calendar unless you delete them manually, as they belong to your Google account.

## 8. Revoking Access

You can revoke Plannr's access to your Google account at any time by visiting your [Google Account Permissions](https://myaccount.google.com/permissions) page and removing Plannr.

## 9. Children's Privacy

Plannr is intended for university students and is not directed at children under 13. We do not knowingly collect data from children under 13.

## 10. Changes to This Policy

We may update this privacy policy from time to time. Any changes will be reflected by the "Last updated" date at the top of this page.
