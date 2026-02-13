# Backend - Database Testing

## Testing Library Selection

### Frameworks Explored

**1. unittest**

* **Background**: The standard library testing framework included with Python.
* **Consideration**: No installation required, but syntax is verbose (Java-style classes) and lacks advanced fixture management.
* **Decision**: Not suitable for rapid iteration; requires too much boilerplate code.

**2. pytest** *Selected*

* **Why pytest?**
* **Fixtures**: Powerful dependency injection (`conftest.py` style) to handle database setup and teardown automatically.
* **Plugins**: Extensive ecosystem (e.g., `pytest-cov` for coverage).
* **Parametrization**: Allows running the same test logic with multiple inputs using `@pytest.mark.parametrize`.
* **Readability**: Uses simple `assert` statements rather than `self.assertEqual`.



**Final Choice**: We chose **pytest** because its fixture system simplifies database mocking, and its parametrization feature significantly reduces code duplication when testing similar update functions.

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