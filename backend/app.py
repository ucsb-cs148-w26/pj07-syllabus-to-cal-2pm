from fastapi import FastAPI

app = FastAPI(
    title='Syllabus to Calendar API',
    description='Upload your syllabus, the API parses it and uploads the relevant time slots to your Google Calendar'
)


@app.post('/google-oauth-login', tags=['OAuth'])
async def google_oauth_login():
    ...


@app.post('/syllabus', tags=['Syllabus to Calendar'])
async def parse_syllabus():
    ...


@app.post('/calendar', tags=['Syllabus to Calendar'])
async def add_to_calendar():
    ...
