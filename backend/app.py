from fastapi import FastAPI, File, UploadFile, Query, Body
from fastapi.responses import JSONResponse, RedirectResponse
import google.generativeai as genai
from PyPDF2 import PdfReader
import os
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

    flow = get_oauth_flow()
    authorization_url, state = flow.authorization_url(
        access_type='offline',
        include_granted_scopes='true',
        prompt='consent'
    )
    return RedirectResponse(url=authorization_url)


@app.get('/auth/callback', tags=['OAuth'])
async def auth_callback(code: str = Query(...), state: str = Query(None), redirect_to_app: bool = Query(True)):
    """Handle OAuth callback from Google"""
    try:
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
        You are an AI assistant helping students manage their coursework. The user has uploaded the full syllabus of a university course. Your job is to read the syllabus and extract a structured list of **assignments, quizzes, and exams**, along with **what is due**, **when it's due**, and any relevant notes or policies.

## Instructions:
- Each syllabus will be from a non-specified quarter, figure out which quarter it is for, either Fall, Winter, or Spring. Then infer which day of the week that starts for, Winter starts on the Jan 3 2026 this year for reference 
. If the syllabus mentions **Week 1**, assume it starts on that date and calculate calendar dates accordingly.
- Some items may be listed by **week number**, **specific date**, or **relative terms** like “final exam” or “Week 4 quiz.”
- Ignore general policies, grading breakdowns, and university resource sections unless they are tied to due dates.
- If given explicit directions, such as having TWO due dates for one assignment (regrades, initial attempt vs. revision) use advanced reasoning to schedule each hwk assignment.
- sometimes, due dates might not be as simple, read, and understand the text such that you can make an educated inference. for example if theres a table that has each wk, closely look to see if there is anything due and list everything due
- particularly look for end of lab, section, etc. keywords
- Return your answer as a **structured JSON object** with this format:
        {{
            "events": [
                {{
                    "title": "event name",
                    "date": "YYYY-MM-DD",
                    "type": "homework/exam/quiz/lab/other",
                    "description": "brief description"
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
