# User Feedback Needs

### Core Metric: Syllabus Parsing Success Rate

**Definition:**  
% of syllabus uploads that result in a usable, correctly parsed schedule with no major missing or incorrect items.

**Why this represents user value:**  
Our core value proposition is converting syllabi into actionable schedules. If parsing fails or produces incorrect output, the product fails to deliver user value.

**How to test during demo:**  
1. Upload a syllabus file.  
2. Display the auto-generated schedule.  
3. Ask the tester:  
   “Does this schedule correctly reflect your syllabus with no major missing or incorrect items?” (Yes / No)

**What to record:**  
- Successful parse (Yes/No)  
- Number of missing or incorrect items (if applicable)

**Success criteria:**  
- Long-term success: ≥ 90% successful parses  
- Target for 2/26 demo: ≥ 60–70% successful parses

## 1. AI Parsing Accuracy Satisfaction (Highest Priority)

**What we want to know:** How satisfied are users with the accuracy of events extracted from their syllabi by our AI (Gemini)?

**Why it matters:** This is the core value proposition of Plannr. If the AI misses events, extracts wrong dates, or invents events that don't exist, the app fails its primary purpose. We suspect accuracy varies significantly depending on syllabus format (structured vs. dense prose, PDF quality, table layouts, etc.), but we don't yet know how often users encounter errors or how severe those errors are in practice.

**How to measure:** After a user completes their first sync, prompt them to rate: (a) the percentage of events they had to manually correct or decline, and (b) overall satisfaction with the extraction on a 1–5 scale. Also collect open-ended feedback on what went wrong.

---

## 2. Overall Onboarding & First-Use Satisfaction (Ongoing)

**What we want to know:** How smooth and understandable is the end-to-end flow for a first-time user — from signing in with Google, to uploading a syllabus, to seeing events appear and syncing to their calendar?

**Why it matters:** The app involves non-trivial steps (Google OAuth, file/camera upload, AI processing wait time, reviewing results) and targets students who may abandon it the first time something is confusing or slow. We want to identify where users drop off or feel uncertain so we can prioritize UX improvements.

**How to measure:** Conduct think-aloud usability sessions with 3–5 students who have never used the app. Ask them to add one of their actual syllabi from scratch. Observe where they hesitate, make mistakes, or express frustration, and collect a post-task satisfaction score (SUS or a simple 1–5 rating).

---

## 3. Desire for Multi-Quarter / Returning User Features

**What we want to know:** Do students want to re-use Plannr every quarter, and if so, what friction do they hit when starting a new quarter? Would features like saved class colors, re-import from previous quarter's class list, or bulk-upload for multiple syllabi at once meaningfully increase their likelihood to return?

**Why it matters:** Plannr's current design is optimized for a single onboarding flow. If retention across quarters is a goal, we need to understand whether returning users feel the setup cost is worth repeating and what would make it easier. This shapes whether we invest in persistence/account features or keep the app intentionally lightweight.

**How to measure:** Survey users at the end of the current quarter: "How likely are you to use Plannr again next quarter?" (1–5) and "What, if anything, would make it easier to set up next quarter?" Also ask whether they'd find a "copy last quarter's classes" feature useful.