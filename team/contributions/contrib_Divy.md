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