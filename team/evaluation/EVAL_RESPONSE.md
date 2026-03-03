# Inter-Team Evaluation Response

**Project:** Plannr (Syllabus-to-Calendar)
**Date:** 2026-03-03
**Team:** pj07-syllabus-to-cal-2pm

---

## 1. Response to Feedback on USER_FEEDBACK_NEEDS.md

Our `USER_FEEDBACK_NEEDS.md` identified three core metrics we wanted to evaluate:

1. **AI Parsing Accuracy Satisfaction** (highest priority)
2. **Overall Onboarding & First-Use Satisfaction**
3. **Desire for Multi-Quarter / Returning User Features**

The reviewing team's feedback speaks most directly to metrics **1 and 2**:

- **Parsing accuracy / verification:** The reviewers specifically suggested adding a feature to verify whether extracted events are accurate — ideally a side-by-side view of the uploaded syllabus and the parsed events. This directly validates our concern that parsing accuracy is the core risk. We had already identified this as our highest-priority user feedback need. **Decision:** We will investigate a split-pane or overlay view that displays the original syllabus alongside the event list in `CalendarPreviewView`, so users can cross-check events before syncing.

- **Onboarding flow:** Reviewers found the app "pretty intuitive, really clean," which is a strong positive signal on metric 2. The one UX friction they flagged — not returning to the home page after upload — is a straightforward improvement. **Decision:** We will add navigation logic to return to the home/upload screen after a sync completes and add a clear "Upload another syllabus" path from the post-sync screen.

- **Returning user features:** The reviewers listed multiple features that would make people come back (colors, profile, clickable events, notifications, stats). This aligns directly with metric 3 — we had already flagged multi-quarter retention as an open question. **Decision:** We are adding event color customization as a near-term deliverable (it was already partially explored earlier in the project). Other features (profile pictures, usage stats, push notifications) are stretch goals for after code freeze, but the feedback confirms they are worth prioritizing in a future version.

---

## 2. Additional Decisions Based on Feedback

### From Section 2 — Features: Likes and Potential Improvements

The reviewers called out the following features they noticed and appreciated:
- Multiple upload methods (file picker, camera, URL)
- Google Calendar sync flow

Improvements suggested:
- **Event colors** — already partially implemented; we will expose color customization in the UI.
- **Clickable events** — make individual events in `CalendarPreviewView` tappable to edit or view details. **Decision:** We will add a detail sheet/popover on event tap so users can edit the event title, date, or time before syncing.
- **Shareable calendars** — sharing a generated .ics link or a view-only calendar. This is a stretch goal given the remaining timeline, but we will document it as a post-code-freeze feature.
- **Support for non-class events** — expand parsing prompts to capture office hours, study sessions, and other non-deadline events. **Decision:** We will update the Gemini prompt to optionally include recurring weekly events (office hours, lab sections) and give users a toggle to include or exclude them.
- **Profile picture and user profile page** — stretch goal; noted for a future sprint.
- **Usage stats and busy-week summaries** — longer-term intelligence feature; consistent with our MVP_FOLLOWUP.md roadmap (Section H: Notifications & Intelligence).
- **Notifications and reminders** — also a longer-term feature; we will note this as a post-code-freeze priority.

### From Section 3 — UI/UX and Robustness

- **"Pretty intuitive, really clean"** — confirms the core UI is well-received.
- **"Move back to the home page after uploading"** — we agree this is a clear UX gap. **Decision:** After sync completes, the app will navigate back to the upload screen with a success toast/banner, rather than leaving the user on a completed-state screen.
- **"Option to upload multiple syllabi"** — already in our roadmap (MVP_FOLLOWUP.md, Section D). **Decision:** We will add a "Add another syllabus" button on the post-sync screen to re-enter the upload flow without going back manually.
- **"UI doesn't look like it's built in React" (Kevin)** — taken as positive feedback: the native SwiftUI aesthetic is intentional and appreciated.

### From Section 4 — Deployment Instructions and Repo Organization

- **"Xcode takes a while to install. However, the instructions were very clear and easy to follow."** — We are glad the README/deployment instructions were clear. **Decision:** We will add a note to the README callout at the top warning new users that the initial Xcode download is large (~10 GB) and may take 20–30+ minutes, so they set expectations before starting.

### From Section 5 — Closing Thoughts

- **Liked:** The overall quality and range of upload options; clean, polished feel.
- **Most impactful opportunity:** The side-by-side syllabus + event verification view. This is our top agreed-upon action item from this review cycle.
- **Additional positive note:** The app being well done with thoughtful options was affirming for the team.

---

## Summary of Team Decisions

| Feedback | Source Section | Priority | Decision |
|---|---|---|---|
| Side-by-side syllabus / event verification view | 5 / USER_FEEDBACK_NEEDS #1 | High | Investigate split-pane view in CalendarPreviewView |
| Return to home after upload | 3 | High | Add post-sync navigation + "Add another" button |
| Clickable / editable events | 2 | High | Add tap-to-edit detail sheet in CalendarPreviewView |
| Event color customization | 2 | High | Expose color picker in UI (already partially built) |
| Non-class events (office hours, labs) | 2 | Medium | Update Gemini prompt + add toggle |
| Xcode install time warning | 4 | Low | Add note to top of README |
| Multiple syllabus upload | 3 | Medium | Already in roadmap; add "Upload another" CTA post-sync |
| Notifications / reminders | 2 | Stretch | Post-code-freeze feature |
| Usage stats / busy-week summary | 2 | Stretch | Post-code-freeze feature |
| Profile picture / user profile | 2 | Stretch | Post-code-freeze feature |
| Shareable calendars | 2 | Stretch | Post-code-freeze feature |
