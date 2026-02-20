# Testing Documentation - Plannr

# Frontend - Preview Testing

## Testing Library Selection

### Frameworks Explored

**1. Jest**
- **Background**: I have prior experience with Jest from previous JavaScript/React projects and work
- **Consideration**: Familiar syntax and workflow
- **Decision**: Not suitable for Swift/iOS development - Jest is JavaScript-specific

**2. XCTest**  *Selected*
- **Why XCTest?**
  - Native to iOS/Swift development - no setup required
  - Integrated directly into Xcode
  - Industry standard for iOS apps
  - Zero external dependencies
  - Recommended by Claude for Apple's framework

**Final Choice**: Based on Claude's recommendation and research, I chose **XCTest** because it's specifically made for Apple's frameworks and doesn't require any additional configuration or external dependencies.

## Approaches Tested

I did unit testing using the AAA testing pattern for our event management logic in the CalendarPreviewView component.

## Unit Tests Implemented

### Test File: `CalendarPreviewViewTests.swift`

We implemented the following unit tests for the `CalendarPreviewView` component:

#### 1. **testFilterAcceptedEvents()**
- **What it tests**: Filters events by "accepted" status
- **Why it matters**: The sync functionality only syncs accepted events to Google Calendar. This test ensures we're filtering correctly.
- **Test data**: Mix of pending, accepted, and declined events
- **Expected result**: Only 2 accepted events returned

#### 2. **testFilterAcceptedEventsWhenNoneAccepted()**
- **What it tests**: Edge case when no events are accepted
- **Why it matters**: Prevents sync errors when user hasn't accepted anything
- **Expected result**: Empty array returned

#### 3. **testToggleAcceptedEventToPending()**
- **What it tests**: Toggling an accepted event back to pending
- **Why it matters**: Tests the accept/decline button toggle functionality
- **Expected result**: Event status changes from accepted to pending

#### 4. **testAcceptAllEvents()**
- **What it tests**: "Accept All" button functionality
- **Why it matters**: Ensures bulk operations work correctly
- **Expected result**: All events have accepted status

#### 5. **testDeclineAllEvents()**
- **What it tests**: "Decline All" button functionality
- **Expected result**: All events have declined status

## Running the Tests

### In Xcode:
1. Open your project in Xcode
2. Press `Cmd + U` to run all tests
3. Or click the diamond icon next to individual test methods

### Viewing Results:
- Open Test Navigator: `Cmd + 6`
- Green checkmarks = passing tests
- Red X = failing tests


# Backend - Database Testing

### Testing Library Explored

**1. unittest**

* **Background**: The standard library testing framework included with Python.
* **Consideration**: No installation required, but syntax is verbose (Java-style classes) and lacks advanced fixture management.
* **Decision**: Not suitable for rapid iteration; requires too much boilerplate code.
* **Patch**: Create `side_effect` to test edge cases like db connection errors

**2. pytest**

* **Fixtures**: Powerful dependency injection (`conftest.py` style) to handle database setup and teardown automatically.
* **Plugins**: Extensive ecosystem (e.g., `pytest-cov` for coverage).
* **Parametrization**: Allows running the same test logic with multiple inputs using `@pytest.mark.parametrize`.
* **Readability**: Uses simple `assert` statements rather than `self.assertEqual`.

## Approaches Tested

I implemented unit testing using the AAA (Arrange, Act, Assert) pattern. Special attention was paid to **Mocking** and **Fixtures** to ensure tests run against a temporary, isolated SQLite database rather than the production file.

## Unit Tests Implemented

### Test File: `test_db_manager.py`

We implemented the following unit tests for the `db_manager.py` module:

#### 1. **test_init_db_creates_table()**

* **What it tests**: Verifies that the `users` table is correctly created in the database schema.
* **Why it matters**: Ensures the application cannot start in a broken state without the necessary storage structure.
* **Expected result**: Querying `sqlite_master` confirms the existence of the table.

#### 2. **test_add_and_fetch_new_user()**

* **What it tests**: The complete lifecycle of creating a user and retrieving their basic profile.
* **Why it matters**: Validates the core CRUD functionality; without this, user onboarding fails.
* **Expected result**: The email inserted matches the email retrieved.

#### 3. **test_update_functions()** (Parametrized)

* **What it tests**: Dynamically tests `update_creds`, `update_syllabi`, and `update_calendar` in a single function.
* **Why it matters**: Ensures that JSON payloads are correctly serialized and stored in their respective columns without writing three separate, redundant tests.
* **Expected result**: The database column contains the exact JSON payload passed to the function.

#### 4. **test_remove_user()**

* **What it tests**: The deletion of a user record.
* **Why it matters**: implementation of "Right to be Forgotten" and general data hygiene.
* **Expected result**: Querying the user after deletion returns `None`.

#### 5. **Exception Handling Tests**

* **Tests included**: `test_add_duplicate_user_raises_error`, `test_remove_nonexistent_user_raises_error`
* **What it tests**: Guardrails against invalid operations.
* **Why it matters**: Prevents database corruption or silent failures when the frontend sends invalid requests.
* **Expected result**: Specific Exceptions (e.g., "User Already Exists") are raised.

#### 6. **Infrastructure Failure Tests**

* **Tests included**: `test_init_db_connection_error`
* **What it tests**: Simulates a disk error or permission issue using `unittest.mock.patch`.
* **Why it matters**: Ensures the system handles critical infrastructure failures gracefully rather than crashing with obscure errors.
* **Expected result**: A "Database Connection Error" is raised and caught.

## Running the Tests

### In Terminal:

1. Navigate to the database directory.
2. Run the full suite:
```bash
pytest

```


3. Run with verbose output (to see individual test names):
```bash
pytest -v

```



### Viewing Results:

* **Green dots/text**: Passing tests.
* **Red F/text**: Failing tests (includes a stack trace pointing to the assertion failure).


---

# Backend - Component / Integration Testing

## Testing Library

**pytest + FastAPI TestClient** (backed by `httpx`)

FastAPI's `TestClient` sends real HTTP requests through the full application stack (routing, request parsing, validation, business logic, and response serialization) without requiring a live server. Only the database and external OAuth services are mocked with `unittest.mock.patch`. This makes it a component test: the HTTP endpoint is exercised end-to-end, but external I/O is controlled.

## Component Tests Implemented

### Test File: `test_oauth_state.py`

Tests the OAuth CSRF state machine at the HTTP level.

#### 1. **test_cleanup_removes_expired_states()**
- Verifies that expired state tokens are purged and fresh ones are kept.

#### 2. **test_missing_state_rejected() / test_invalid_state_rejected()**
- Confirms that `/auth/callback` redirects with an error when the `state` parameter is absent or was never issued.

#### 3. **test_expired_state_rejected()**
- Confirms that states older than the TTL are rejected even if they exist in the store.

#### 4. **test_state_is_single_use()**
- Confirms that a valid state token cannot be replayed — the second request is rejected.

#### 5. **test_google_auth_stores_state() / test_each_request_generates_unique_state()**
- Confirms that each call to `/auth/google` stores a new unique state token and includes it in the redirect URL.

---

### Test File: `test_export.py`

Tests the `/export` endpoint end-to-end.

#### 1. **test_export_ics_valid()**
- Authenticated POST with real events returns `text/calendar` with a valid iCalendar body containing `BEGIN:VEVENT` entries.

#### 2. **test_export_csv_valid()**
- Authenticated POST returns `text/csv` with correct column headers and event rows.

#### 3. **test_export_invalid_format()**
- Unsupported `format` parameter returns 400 with an error message referencing "format".

#### 4. **test_export_unauthenticated()**
- Email with no stored credentials returns 401 with "authenticated" in the error.

#### 5. **test_export_empty_events()**
- Authenticated POST with an empty events list returns 400 with "no events" in the error.

## Running the Component Tests

```bash
cd backend
pytest tests/test_oauth_state.py tests/test_export.py -v
```

---

# Plans Going Forward

## Unit Tests

We will continue adding pytest unit tests for new backend modules as they are introduced (e.g. new DB functions, utility helpers). On the Swift side, XCTest will cover pure logic that does not require a running app — event filtering, status toggling, URL construction. We are not targeting 100% coverage given the scope of the project, but critical business logic (sync filtering, auth state) will remain covered.

## Higher-Level / Component Tests

We will continue using FastAPI's `TestClient` pattern for any new HTTP endpoints. Component tests give us the best return on investment: they are fast, require no live infrastructure, and catch integration bugs (routing, serialization, auth checks) that unit tests miss. We have no plans for full end-to-end UI tests (e.g. Appium, XCUITest automation) — the overhead of mobile UI test infrastructure is not justified at this stage, and the component + unit combination covers our backend thoroughly.
