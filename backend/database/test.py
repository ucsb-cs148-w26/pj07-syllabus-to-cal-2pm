import pytest
import sqlite3
import json
from unittest.mock import patch
import db_manager

# --- Fixtures (Setup) ---

@pytest.fixture
def mock_db(tmp_path, monkeypatch):
    """
    Creates a temporary database file and redirects your code to use it.
    Runs init_db() to ensure tables exist before every test.
    """
    test_db_file = tmp_path / "test_users.db"
    
    monkeypatch.setattr(db_manager, "DB_NAME", test_db_file)
    
    db_manager.init_db()
    
    return test_db_file

@pytest.fixture
def sample_user(mock_db):
    """
    Adds a sample user to the DB and returns their email.
    Useful for tests that need an existing user.
    """
    email = "test@example.com"
    db_manager.add_user(email)
    return email

# --- Functionality ---

def test_init_db_creates_table(mock_db):
    """Verify table creation works."""
    with sqlite3.connect(mock_db) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")
        assert cursor.fetchone() is not None

def test_add_and_fetch_new_user(mock_db):
    """Test adding a user and fetching them."""
    email = "new@example.com"
    
    creds = db_manager.fetch_user_creds(email)
    assert creds is None

    with sqlite3.connect(mock_db) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT email FROM users WHERE email=?", (email,))
        assert cursor.fetchone()[0] == email

def test_fetch_existing_user_creds(mock_db, sample_user):
    """Test fetching creds for a user that already has them."""
    creds_data = {"token": "abc-123"}
    db_manager.update_creds(sample_user, creds_data)
    
    fetched_creds = db_manager.fetch_user_creds(sample_user)
    assert json.loads(fetched_creds) == creds_data

@pytest.mark.parametrize("update_func, col_name, payload", [
    (db_manager.update_creds, "google_credentials", {"access_token": "token_123"}),
    (db_manager.update_syllabi, "syllabi", {"course": "CS101"}),
    (db_manager.update_calendar, "calendar", {"event": "Interview"}),
])
def test_update_functions(mock_db, sample_user, update_func, col_name, payload):
    """
    Parametrized test to cover all update functions.
    Checks if the correct column is updated with the correct JSON.
    """
    update_func(sample_user, payload)

    with sqlite3.connect(mock_db) as conn:
        cursor = conn.cursor()
        cursor.execute(f"SELECT {col_name} FROM users WHERE email=?", (sample_user,))
        row = cursor.fetchone()
        assert json.loads(row[0]) == payload

def test_remove_user(mock_db, sample_user):
    """Test user removal."""
    db_manager.remove_user(sample_user)
    
    with sqlite3.connect(mock_db) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE email=?", (sample_user,))
        assert cursor.fetchone() is None

# --- Exception & Edge Case Tests ---

def test_add_duplicate_user_raises_error(mock_db, sample_user):
    """Ensure we can't add the same email twice."""
    with pytest.raises(Exception, match="User Already Exists"):
        db_manager.add_user(sample_user)

def test_remove_nonexistent_user_raises_error(mock_db):
    """Ensure removing a fake user raises an error."""
    with pytest.raises(Exception, match="does not exist"):
        db_manager.remove_user("fake@example.com")

@pytest.mark.parametrize("func", [
    db_manager.update_creds,
    db_manager.update_syllabi,
    db_manager.update_calendar
])
def test_update_nonexistent_user_raises_error(mock_db, func):
    """Ensure updating a fake user raises an error."""
    with pytest.raises(Exception, match="does not exist"):
        func("fake@example.com", {"data": "test"})

def test_init_db_connection_error():
    """Simulate a critical DB connection failure during init."""
    with patch('sqlite3.connect', side_effect=sqlite3.Error("Disk full")):
        with pytest.raises(Exception, match="Database Connection Error"):
            db_manager.init_db()

def test_add_user_generic_db_error(mock_db):
    """Simulate a generic DB error during add_user."""
    with patch('sqlite3.connect', side_effect=sqlite3.Error("Disk full")):
        with pytest.raises(Exception, match="Failed to add the user"):
            db_manager.add_user("example@gmail.com")