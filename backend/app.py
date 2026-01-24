from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import google.generativeai as genai
from PyPDF2 import PdfReader
import os
from io import BytesIO
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Configure Gemini API
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable not set. Please add it to your .env file.")

genai.configure(api_key=GEMINI_API_KEY)

app = FastAPI(
    title='Plannr API',
    description='Upload your syllabus, the API parses it and uploads the relevant time slots to your Google Calendar'
)


@app.post('/google-oauth-login', tags=['OAuth'])
async def google_oauth_login():
    ...


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


@app.post('/calendar', tags=['Plannr'])
async def add_to_calendar():
    ...
