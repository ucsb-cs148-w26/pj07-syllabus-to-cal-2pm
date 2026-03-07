# Contributions -- Divya Subramonian


## Frontend: Homepage and App Structure

- Built the initial homepage `ContentView`, replacing the placeholder Hello World screen with a functional landing UI (d32a5a1)
- Redesigned main page layout to support multiple classes/syllabi, enabling users to manage more than one course at a time (`AddClassView.swift`, `SyllabusUploadView.swift`, `ClassManager.swift`) (2f379d1)
- Fixed main page edge case when no classes exist yet (2d23ea2)
- These structural changes formed the backbone of the app’s multi-syllabus flow, splitting our application into distinct, navigable screens (architectural contribution that allowed the rest of the team to build on top of the frontend)

 
## PDF Upload Feature

- Implemented the baseline PDF upload feature, allowing users to select and submit syllabus documents from their device for processing (`PDFUploadView.swift`) (9a68161)


## Calendar Preview: Event Editing and Color Selection

- Added per-event accept, decline, and edit options on the Calendar Preview page (`CalenderPreviewView.swift`), giving users control over which parsed events to keep and how to modify them (9bafda7)
- Built a color selector feature so users can assign custom colors to events on the Calendar Preview page, improving visual organization (865a925, 9a05513)
- These features made the preview page an editing surface rather than a read-only list (a UX improvement that lets users fine-tune their calendar before syncing)


## Miscellaneous - Documentation and Merging
 
- Drafted and improved team agreements document, establishing norms for collaboration (8731c17, 9f11919)
- Added user journey to team documentation to guide product direction (dcd109e)
- Maintained and updated `README` with current project information (dbd8bb6, 5d3cae2)
- Contributed team members' learning reflections to `LEARNING.md` and updated the file (6fcfd21, a3425e1)
- Updated `AI_CODING.md` with reflections on AI-assisted development practices (91ceea1, a6f2ff3, 01cc74c)
- Updated `LEADERSHIP.md` to document team leadership (11084b2, 5c9a32d)
- Wrote and expanded `MANUAL.md` with documentation covering all major app features and purposes (cac8891, 23cfc84)
