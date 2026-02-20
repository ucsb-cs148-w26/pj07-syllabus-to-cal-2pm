from fastapi import FastAPI, File, UploadFile, Query, Body
from fastapi.responses import JSONResponse, RedirectResponse
import google.generativeai as genai
from PyPDF2 import PdfReader
import os
import time
import secrets
from io import BytesIO
from dotenv import load_dotenv
from google_auth_oauthlib.flow import Flow
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from database.db_manager import init_db, fetch_user_creds, update_creds
import json
from pydantic import BaseModel
from typing import List, Optional


class CalendarEvent(BaseModel):
    title: str
    date: str
    description: Optional[str] = ""
    type: Optional[str] = "other"


class CalendarSyncRequest(BaseModel):
    events: List[CalendarEvent]

# Load environment variables from .env file
load_dotenv()

# Configure Gemini API
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable not set. Please add it to your .env file.")

genai.configure(api_key=GEMINI_API_KEY)

# Google OAuth Configuration
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")
GOOGLE_CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET")
GOOGLE_REDIRECT_URI = os.getenv("GOOGLE_REDIRECT_URI", "http://localhost:8000/auth/callback")

SCOPES = [
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/calendar.events',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
    'openid'
]

# In-memory OAuth state store: {state_token: created_timestamp}
_oauth_states: dict[str, float] = {}
OAUTH_STATE_TTL = 300  # 5 minutes


def _cleanup_expired_states():
    """Remove expired OAuth state tokens."""
    now = time.time()
    expired = [s for s, t in _oauth_states.items() if now - t > OAUTH_STATE_TTL]
    for s in expired:
        del _oauth_states[s]


# Initialize database on startup
init_db()

app = FastAPI(
    title='Plannr API',
    description='Upload your syllabus, the API parses it and uploads the relevant time slots to your Google Calendar'
)


def get_oauth_flow():
    """Create OAuth flow with client config"""
    client_config = {
        "web": {
            "client_id": GOOGLE_CLIENT_ID,
            "client_secret": GOOGLE_CLIENT_SECRET,
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "redirect_uris": [GOOGLE_REDIRECT_URI]
        }
    }
    flow = Flow.from_client_config(client_config, scopes=SCOPES)
    flow.redirect_uri = GOOGLE_REDIRECT_URI
    return flow


@app.get('/auth/google', tags=['OAuth'])
async def google_auth():
    """Start OAuth flow - redirects to Google sign-in"""
    if not GOOGLE_CLIENT_ID or not GOOGLE_CLIENT_SECRET:
        return JSONResponse(
            status_code=500,
            content={"error": "Google OAuth credentials not configured. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET in .env"}
        )

    _cleanup_expired_states()

    state = secrets.token_urlsafe(32)
    _oauth_states[state] = time.time()

    flow = get_oauth_flow()
    authorization_url, _ = flow.authorization_url(
        access_type='offline',
        include_granted_scopes='true',
        prompt='consent',
        state=state
    )
    return RedirectResponse(url=authorization_url)


@app.get('/auth/callback', tags=['OAuth'])
async def auth_callback(code: str = Query(...), state: str = Query(None), redirect_to_app: bool = Query(True)):
    """Handle OAuth callback from Google"""
    try:
        # Validate the OAuth state parameter to prevent CSRF attacks
        from urllib.parse import quote as _quote
        if not state or state not in _oauth_states:
            error_url = f"plannr://auth/callback?error={_quote('Invalid or missing OAuth state. Please try signing in again.')}"
            return RedirectResponse(url=error_url)

        created_at = _oauth_states.pop(state)  # Single-use: delete immediately
        if time.time() - created_at > OAUTH_STATE_TTL:
            error_url = f"plannr://auth/callback?error={_quote('OAuth session expired. Please try signing in again.')}"
            return RedirectResponse(url=error_url)

        flow = get_oauth_flow()
        flow.fetch_token(code=code)

        credentials = flow.credentials

        # Get user info
        from googleapiclient.discovery import build
        user_info_service = build('oauth2', 'v2', credentials=credentials)
        user_info = user_info_service.userinfo().get().execute()
        email = user_info.get('email')
        name = user_info.get('name', '')

        # Store credentials in database
        creds_data = {
            'token': credentials.token,
            'refresh_token': credentials.refresh_token,
            'token_uri': credentials.token_uri,
            'client_id': credentials.client_id,
            'client_secret': credentials.client_secret,
            'scopes': credentials.scopes
        }

        # Ensure user exists and update credentials
        fetch_user_creds(email)  # This creates user if not exists
        update_creds(email, creds_data)

        # Redirect to iOS app with custom URL scheme
        from urllib.parse import quote
        app_callback_url = f"plannr://auth/callback?email={quote(email)}&name={quote(name)}"
        return RedirectResponse(url=app_callback_url)

    except Exception as e:
        print(f"OAuth callback error: {e}")
        import traceback
        traceback.print_exc()
        # Redirect to app with error
        from urllib.parse import quote
        error_url = f"plannr://auth/callback?error={quote(str(e))}"
        return RedirectResponse(url=error_url)
        


@app.post('/google-oauth-login', tags=['OAuth'])
async def google_oauth_login():
    """Legacy endpoint - use /auth/google instead"""
    return RedirectResponse(url='/auth/google')


@app.post('/syllabus', tags=['Plannr'])
async def parse_syllabus(file: UploadFile = File(...)):
    try:
        print(f"\n=== NEW UPLOAD ===")
        print(f"Filename: {file.filename}")
        
        # Read the uploaded file
        contents = await file.read()
        print(f"File size: {len(contents)} bytes")
        
        # Extract text from PDF
        pdf_text = extract_text_from_pdf(contents)
        print(f"\n=== EXTRACTED PDF TEXT ===")
        print(f"Text length: {len(pdf_text)} characters")
        print(pdf_text[:500])  # First 500 characters
        
        if not pdf_text:
            return JSONResponse(
                status_code=400,
                content={"error": "Could not extract text from PDF"}
            )
        
        # Send to Gemini for parsing
        parsed_events = await parse_with_gemini(pdf_text)
        
        print(f"\n=== FINAL RESPONSE ===")
        print(f"Events parsed: {len(parsed_events.get('events', []))}")
        
        return JSONResponse(
            status_code=200,
            content={
                "message": "Syllabus received and parsed",
                "filename": file.filename,
                "size": len(contents),
                "events": parsed_events.get('events', [])
            }
        )
    except Exception as e:
        print(f"\n=== ERROR IN /SYLLABUS ===")
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return JSONResponse(
            status_code=400,
            content={"error": str(e)}
        )


def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """Extract text from PDF bytes"""
    try:
        pdf_file = BytesIO(pdf_bytes)
        pdf_reader = PdfReader(pdf_file)
        text = ""
        for page in pdf_reader.pages:
            text += page.extract_text()
        return text
    except Exception as e:
        print(f"Error extracting PDF text: {e}")
        return ""


async def parse_with_gemini(syllabus_text: str) -> dict:
    """Use Gemini to extract calendar events from syllabus text"""
    try:
        model = genai.GenerativeModel('gemini-2.5-flash-lite')
        
        prompt = f"""
        You are an AI assistant that parses university course syllabi into a structured list of **graded deliverables**. The user has provided the full syllabus text. Your job is to accurately extract **what is due**, **when it is due**, and **how it should be labeled**, using careful temporal and contextual reasoning.

Your primary objective is **correct due-date inference**, even when dates are implicit, relative, or described indirectly.

Firstly, ensure the uploaded document is a syllabus for a university course. If it does not appear to be a syllabus, respond with an error message stating such in the JSON output. 
If not a syllabus, make the "isSyllabus" field to FALSE. If it is a syllabus, this field should be TRUE. Do NOT attempt to extract events if the document is not a syllabus.
---

## Step 1: Academic Term & Year Inference (MANDATORY)

Before extracting any events, you must infer:
- **Academic year** (e.g., 2024–2025, 2025–2026)
- **Quarter** (Fall, Winter, or Spring)

You must infer the year using:
- Explicit years or date ranges in the syllabus (e.g., “Winter 2025”, “Spring Quarter 2024”)
- Contextual clues (file headers, footers, grading policies, references to holidays, finals week)
- If a date is written without a year (e.g., “Jan 15”), infer the year from the academic term

 Do NOT assume the current calendar year - only assume current year if no other information is available 
 Do NOT reuse years from prior examples or memory  
 All dates must be consistent with the inferred academic year

---

## Step 2: Quarter Start Date Inference

After determining the **quarter and year**, infer the **first instructional day** using standard university quarter conventions:

- **Winter Quarter**: early January
- **Spring Quarter**: late March or early April
- **Fall Quarter**: late September

If the syllabus explicitly states:
- “Week 1”
- “Classes begin on …”
- “Instruction starts …”

Use that as the authoritative anchor.

If not explicitly stated:
- Assume **Week 1 begins on the first Monday of the quarter’s instructional period**
- Use that date as the anchor for all week-based calculations

---

## Step 3: Temporal Reasoning Rules (CRITICAL)

You must resolve dates even when they are **implicit or relative**.

Examples:
- “Homework due at the end of lecture each week”
- “Lab due by the end of section”
- “Quiz every Friday”
- “Assignments due weekly”
- “Final exam during finals week”

Rules:
- Understand the **lecture and section schedule**, but **DO NOT output lectures or sections**
- Use lecture timing ONLY to infer due dates
- “End of lecture” → last lecture day of that week
- “End of section/lab” → the scheduled section or lab day for that week
- Finals week → use the university-standard finals window for the inferred quarter
- If an assignment is described as “weekly” or “every week”, assign it to the corresponding day each week (e.g., every Friday)
- For assignments with vague deadlines (e.g., “due next month”), use the **last instructional day of that month**

If a due date cannot be inferred with reasonable confidence, **omit the event** rather than guessing.

---

## Step 4: What to Extract

Extract ONLY graded or required deliverables:
- Homework assignments
- Labs
- Quizzes
- Midterms
- Final exams
- Projects, reports, checkpoints

Ignore:
- General policies
- Grading breakdowns
- Office hours
- Lectures or readings (unless graded)

---

## Step 5: Titles and Naming Discipline

- Preserve **canonical titles exactly as written**:
  - `HW1`, `Homework 3`, `Lab 2`, `Midterm 1`, `Final Exam`
- Do NOT invent names or normalize aggressively
- If an assignment has multiple graded submissions (draft/final, submission/regrade):
  - Create **separate events** with clear titles
- Be sure to take note of what the name of the course is that the student is taking ot output. Typically, this will be in the title, header, footer, etc. 
If none is found just put unknown DO not put error in that field. If available call the course by it's known name, such as CS101 as opposed to Computer Science Basics. 
Course codes over long wordy stuff.



---

## Step 6: Tables and Weekly Schedules

- Carefully inspect tables, calendars, and week-by-week schedules
- If a week lists **any due work**, extract it
- Assume items listed in structured schedules are graded unless explicitly stated otherwise

---

## Output Format (STRICT)

Return a **single JSON object** in this exact format:
        {{
            "events": [
                {{
                    "title": "event name",
                    "date": "YYYY-MM-DD",
                    "type": "homework/exam/quiz/lab/other",
                    "description": "brief description",
                    "Class": "The name of the class the user is taking here",
                    "isSyllabus": "True if syllabus false if not"
                }}
            ]
        }}
        
        Syllabus:
        {syllabus_text}
        """
        
        response = model.generate_content(prompt)
        
        # Parse the response (Gemini should return JSON)
        import json
        # Try to extract JSON from the response
        response_text = response.text
        
        print("\n=== GEMINI RAW RESPONSE ===")
        print(response_text)
        
        # Look for JSON in the response
        start_idx = response_text.find('{')
        end_idx = response_text.rfind('}') + 1
        if start_idx != -1 and end_idx > start_idx:
            json_str = response_text[start_idx:end_idx]
            print("\n=== EXTRACTED JSON STRING ===")
            print(json_str)
            
            parsed = json.loads(json_str)
            print("\n=== PARSED JSON ===")
            print(parsed)
            return parsed
        else:
            print("\n=== NO JSON FOUND IN RESPONSE ===")
            return {"events": []}
            
    except Exception as e:
        print(f"\n=== ERROR CALLING GEMINI ===")
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return {"events": []}


@app.post('/calendar', tags=['Syllabus to Calendar'])
async def add_to_calendar(email: str = Query(...), request: CalendarSyncRequest = Body(...)):
    """Add parsed syllabus events to user's Google Calendar"""
    try:
        # Get user credentials from database
        creds_json = fetch_user_creds(email)
        if not creds_json:
            return JSONResponse(
                status_code=401,
                content={"error": "User not authenticated. Please sign in with Google first."}
            )

        # Parse stored credentials
        creds_data = json.loads(creds_json)
        credentials = Credentials(
            token=creds_data.get('token'),
            refresh_token=creds_data.get('refresh_token'),
            token_uri=creds_data.get('token_uri'),
            client_id=creds_data.get('client_id'),
            client_secret=creds_data.get('client_secret'),
            scopes=creds_data.get('scopes')
        )

        # Build Calendar service
        service = build('calendar', 'v3', credentials=credentials)

        created_events = []
        for event in request.events:
            # Create calendar event
            calendar_event = {
                'summary': event.title,
                'description': event.description,
                'start': {
                    'date': event.date,  # All-day event format: YYYY-MM-DD
                },
                'end': {
                    'date': event.date,
                },
            }

            result = service.events().insert(calendarId='primary', body=calendar_event).execute()
            created_events.append({
                'title': event.title,
                'date': event.date,
                'calendar_event_id': result.get('id')
            })

        return JSONResponse(
            status_code=200,
            content={
                "message": f"Successfully added {len(created_events)} events to calendar",
                "events": created_events
            }
        )

    except Exception as e:
        print(f"Calendar sync error: {e}")
        import traceback
        traceback.print_exc()
        return JSONResponse(
            status_code=400,
            content={"error": f"Failed to add events to calendar: {str(e)}"}
        )
