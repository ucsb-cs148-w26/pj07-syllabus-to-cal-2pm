# Jiaming

Uses ChatGPT for syntax lookup, debugging, and suggestions.

However, ChatGPT, or any LLM in general, is still prone to hallucination. Thus, I need to double check every code it says to make sure it doesn't break the code. And, I do not trust Codex to directly edit my files, so I manually prompt ChatGPT and copy paste useful code snippets back to my code.

# Matt

## Tool Used
Claude Code (Claude Opus 4.6)

## Experiment
I used Claude to perform a security audit of our OAuth integration with Google. Specifically, I pointed it at our `/auth/google` and `/auth/callback` endpoints in `backend/app.py` and asked it to identify vulnerabilities, document them, and implement fixes.

## Outcomes
Claude identified a CSRF (Cross-Site Request Forgery) vulnerability in our OAuth flow: the backend was generating a `state` parameter during the authorization request but never storing it, and the callback handler accepted the `state` from Google but never validated it. This meant an attacker could potentially forge a callback request and trick a user into authenticating with the attacker's account.

Claude then implemented a fix:
- Added an in-memory state store with a 5-minute TTL to `app.py`
- Modified `/auth/google` to generate a cryptographically secure state token (`secrets.token_urlsafe`) and store it before redirecting to Google
- Modified `/auth/callback` to validate the returned state, reject missing/invalid/expired tokens, and enforce single-use (preventing replay attacks)
- Created a test suite (`backend/tests/test_oauth_state.py`) with 8 tests covering valid state, missing state, invalid state, expired state, and replay prevention — all passing

No iOS changes were needed since `ASWebAuthenticationSession` manages the browser session end-to-end and the state round-trip happens entirely between the backend and Google.

## Reflections

**Usefulness:** Claude was very effective for this type of security-focused task. It understood OAuth 2.0 well enough to immediately spot the missing state validation — something that's easy to overlook when the flow "works" without it. Having it generate both the fix and comprehensive tests saved significant time compared to manually researching the vulnerability, writing the patch, and building test coverage from scratch. Going forward, using AI for security audits of authentication flows seems like a strong use case since these vulnerabilities follow well-documented patterns (OWASP) that LLMs are trained on.


**Ensuring correctness:** I reviewed the generated code diff line-by-line before staging it. I verified that the state token was generated with `secrets.token_urlsafe` (cryptographically secure) rather than something predictable, confirmed the TTL and single-use logic were sound, and ran all 8 tests to validate the behavior. I also checked that the error handling redirected back to the iOS app with meaningful error messages rather than silently failing.

# Divya

**Google Stitch**:

I used Google Stitch to design the layout and flow of the PDF upload process. Instead of keeping the single PDF upload page, I wanted to transform adding a class/syllabus into a multi-screen process.

* Consulted Google Stitch to produce sample wireframes and UI components that matched our current design aesthetic
* Used the tool to quickly blend our existing layout with my ideas for organizing the class adding process
* Whenever designs didn't meet my requirements, I iteratively kept remixing the output with specific details about features I wanted to change or add
* Found this planning approach valuable, and I will continue using this tool for design planning prior to implementing features

**Claude**:

I also used Claude to assist me in implementing certain frontend features, which significantly accelerated my development process.

* Helped me to find solutions quickly and better understand Swift syntax and patterns
* Helped bridge knowledge gaps as I learned the framework
* Required testing and validation —> I needed to run and test code after implementing each feature, as Claude occasionally made assumptions about available properties or methods
* Developed a workflow of implementation followed by verification to ensure compatibility with our codebase

# Yuhang

## Tool usedd
Google Gemini 3.0 Pro

## Experiment
I used Gemini to generate a pytest suite for the `db_manager.py` to verify the functionalities and exception handling cases of the database utilities. Gemini generated a full set of testing verifying the correctness with both valid input and invalid input. I reviewed the generated code line by line and passed all tests when I ran them, confirming the correctness of the test functions and robustness of the `db_manager.py` utilities facing unexpected inputs.

However, Genmini failed to recognize the connection error that may happen during each of the database funcitons, so I wrote the pytest functions for "database connection error" type exception to make sure all lines in `db_manager.py` are covered. I also had to explicitly tell Gemini to use @pytest.mark.parametrize to reduce the size of the testing program, so the testings for numerous edges cases aligned better with a clear view.

While it can be seen that Gemini has the capability of producing general codes when the prompt is clear, it is also prone to missing some edges cases when getting into the details, especially when the context gets too long. I have to be aware of its pros and cons, and be cautious on checking AI-generated codes.

# Arya


## AI Tool Used

**Google Stitch** – AI UI generation / prototyping tool

## What I Did

I used Google Stitch to generate a redesigned **Sign In page UI** for our app. The goal was to quickly explore cleaner layouts, better visual hierarchy, and improved placement of form inputs and OAuth buttons compared to our original design.

## Outputs

* A complete sign-in page mockup
* Clear separation of primary (sign in) and secondary (OAuth / forgot password) actions
* Layouts that could be easily translated into React/Tailwind components

## Usefulness

This tool was very effective for **rapid UI ideation**. It significantly reduced the time needed to explore multiple design directions and helped the team align on a cleaner UX before implementation. Going forward, it’s best used early in development to guide design decisions, not as final production output.

## Validation & Fair Use

* All AI-generated designs were manually reviewed and modified
* No code or UI was copied directly into production
* Accessibility, feasibility, and consistency with our stack were checked
* Outputs were used as inspiration, ensuring fair use

## Takeaway

Google Stitch is a strong design accelerator for frontend work when paired with human judgment and manual implementation.

# Divy

I used Claude AI to help generate unit tests and documentation for this assignment. Specifically, I used it to familiarize myself with XCTest, the native iOS/Swift testing framework, as my prior testing experience was primarily with Jest. Claude helped me select the appropriate framework and generate tests for our event preview page. I verified the generated code by reviewing it for correctness and consistency, then running the tests to confirm they passed


