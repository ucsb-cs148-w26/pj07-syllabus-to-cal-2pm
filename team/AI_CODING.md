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