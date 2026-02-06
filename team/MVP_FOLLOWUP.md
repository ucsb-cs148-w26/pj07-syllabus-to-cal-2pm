# MVP_FOLLOWUP.md  
**Project:** Plannr (Syllabus Parsing App)  
**Date:** 2026-02-06  
**Team:** Plannr  

## 1. Feedback Grouped and Sorted

### A. Strong Value Proposition & Core Workflow
**What users liked**
- Clear value: saves time parsing syllabi and populating calendars
- Smooth Google OAuth + Google Calendar sync
- Clean, intuitive UI; ability to preview/edit before syncing
- Mobile-first experience is appreciated
- Color-coded events and per-course coloring are helpful

**Assessment**
- Our core MVP workflow (Upload → Parse → Review → Sync) is validated.
- This confirms strong product–market fit for students.

---

### B. Platform & Accessibility Gaps
**Feedback**
- Requests for:
  - Web app version (laptop-first workflow for syllabi)
  - Cross-platform support
  - Apple Calendar / Outlook support
  - Export formats (.ics, CSV)
- Many users download syllabi on laptops, not phones.

**Assessment**
- Limiting Plannr to iOS + Google Calendar restricts adoption.
- Cross-platform access is a major growth lever.

---

### C. Input & Parsing Limitations
**Feedback**
- Support more formats:
  - DOCX, screenshots, HTML
  - Non-PDF syllabi
- Edge cases:
  - Poorly formatted syllabi
  - Tentative dates
  - Recurring assignments
  - Date ranges in natural language
  - Syllabi with missing info
- Handle invalid uploads (not a syllabus)

**Assessment**
- Parsing robustness is a critical risk area.
- Need better error handling, format flexibility, and fallback UX.

---

### D. Multi-Course & Bulk Workflows
**Feedback**
- Upload multiple syllabi at once
- View syllabus history
- Remove a syllabus
- One-click re-sync
- Bulk edit (e.g., all midterms, all exams)
- Add missed events manually

**Assessment**
- Current workflow is too linear for real student use cases.
- Multi-course management is a core feature for real adoption.

---

### E. Calendar & Event Management
**Feedback**
- Flag conflicts/overlaps
- Recurring events (homework, weekly labs)
- Filter by event type (homework, exams, lectures)
- Custom naming (avoid “HW 1” ambiguity)
- Tag events added by Plannr
- Toggle which events are saved (avoid clutter)
- List view for urgent vs future tasks
- Final exam schedules & conflict warnings

**Assessment**
- Calendar management is the main differentiator vs just “dumping events into GCal”.
- Smart event organization = major product opportunity.

---

### F. Customization & UX Polish
**Feedback**
- Light/dark themes
- Custom colors per event type
- Cleaner upload page UI
- Tagging system
- In-app calendar view
- Summary view (e.g., “3 midterms in Week 5”)

**Assessment**
- Customization improves retention and perceived quality.
- Some UX polish can be done quickly with high impact.

---

### G. Integrations (Canvas, Gradescope, GOLD, etc.)
**Feedback**
- Canvas integration
- Gradescope, Kattis, Piazza, EdStem
- Sync with GOLD (auto-remove dropped classes)
- Auto-update when syllabus changes

**Concerns**
- Privacy concerns about Canvas social features

**Assessment**
- Integrations are a powerful long-term differentiator.
- Must design with privacy-first constraints and opt-in permissions.

---

### H. Notifications & Intelligence
**Feedback**
- In-app reminders
- Notifications for due dates
- Smart suggestions:
  - Schedule study sessions before exams
  - Alert on conflicting events
- Summary dashboards

**Assessment**
- This moves Plannr from “parser tool” → “planning assistant”.
- Strong future direction for premium features.

---

## 2. Response Actions (Action Items + User Stories)

### High Priority (MVP+ / Next Iteration)

**1. Multi-Syllabus Upload + Management**
- _Action_: Support uploading multiple syllabi, deleting syllabi, and viewing syllabus history.
- _User Story_:  
  > As a student, I want to upload multiple syllabi at once and manage them in one place so that I can set up my whole quarter in one workflow.

**2. Conflict Detection & Overlap Warnings**
- _Action_: Detect overlapping events and warn users before syncing.
- _User Story_:  
  > As a student, I want to be warned when two events overlap so that I can resolve conflicts before they clutter my calendar.

**3. Recurring Events Support**
- _Action_: Parse and/or allow manual creation of recurring events (weekly homework, labs).
- _User Story_:  
  > As a student, I want recurring assignments to be automatically created so I don’t have to manually add weekly tasks.

**4. Better Event Naming + Tagging**
- _Action_: Prefix events with course name and event type; tag events as “Added by Plannr”.
- _User Story_:  
  > As a student, I want events to include the course name and type so I can quickly identify what each deadline is for.

**5. Export Formats (.ics / CSV)**
- _Action_: Add export to .ics and CSV.
- _User Story_:  
  > As a student, I want to export my schedule so I can use Plannr with Apple Calendar or Outlook.

---

### Medium Priority (Growth Features)

**6. Web App Version**
- _Action_: Build lightweight web upload + parsing interface.
- _User Story_:  
  > As a student, I want to upload my syllabi from my laptop so I don’t have to transfer files to my phone.

**7. More File Types + OCR**
- _Action_: Support DOCX, images (OCR), and HTML syllabi.
- _User Story_:  
  > As a student, I want to upload any syllabus format so I’m not blocked by file type.

**8. Bulk Editing & Filters**
- _Action_: Bulk edit by type (e.g., edit all exams), filter by homework/exams.
- _User Story_:  
  > As a student, I want to filter and bulk-edit events so I can quickly adjust multiple deadlines.

**9. Syllabus Parsing Error Handling**
- _Action_: Add validation for “not a syllabus” uploads and low-confidence parsing warnings.
- _User Story_:  
  > As a student, I want to be notified when Plannr isn’t confident about parsed data so I can double-check important deadlines.

---

### Long-Term / Stretch

**10. Canvas / Gradescope / GOLD Integrations**
- _Action_: Research APIs, privacy constraints, opt-in design.
- _User Story_:  
  > As a student, I want Plannr to pull deadlines directly from Canvas so that updates are reflected automatically.

**11. Smart Planning Suggestions**
- _Action_: Suggest study sessions before exams, highlight heavy weeks.
- _User Story_:  
  > As a student, I want Plannr to suggest study blocks before exams so I can plan ahead more effectively.

**12. Notifications & Task View**
- _Action_: Add in-app notifications + “urgent tasks” list view.
- _User Story_:  
  > As a student, I want reminders and a task list so I don’t forget important deadlines.

---

## 3. Next Steps (Prioritized Roadmap)

### Sprint 1 (MVP+ Stability)
- [ ] Multi-syllabus upload + delete
- [ ] Conflict detection + warnings
- [ ] Recurring events
- [ ] Event renaming (course + type)
- [ ] Event tagging (“Added by Plannr”)

### Sprint 2 (Cross-Platform & Parsing)
- [ ] .ics / CSV export
- [ ] Web upload MVP
- [ ] DOCX + OCR support
- [ ] Bulk edit + filters
- [ ] Error handling for bad syllabi

### Sprint 3 (Intelligence & Integrations)
- [ ] In-app reminders
- [ ] Summary views (busy weeks)
- [ ] Canvas integration exploration
- [ ] Study session suggestions

---

## 4. Key Takeaways

- **Core MVP is validated**: students strongly resonate with the idea and UX.
- **Main weaknesses**: limited platforms, limited formats, weak multi-course workflows.
- **Big opportunity**: evolve Plannr from a “syllabus parser” into a **smart academic planning assistant**.
- **Roadmap direction**:  
  MVP+ (robust parsing + calendar management) → Cross-platform → Intelligent planning assistant.
