import sqlite3
import json # I assume we are gonna use json for calendar info storage
import os
import pathlib
from dotenv import load_dotenv

load_dotenv()
current_dir = pathlib.Path(__file__).parent.resolve()
DB_NAME = current_dir / os.getenv("DB_FILEPATH", "SAMPLE.db")


def init_db():
    '''
    Initialize a new 'users' table if none exists.
    Can be also used for database connection testing.

    Table Attributes:
        email: user's email address, primary key to the table
        google_credentials: tokens used for OAuth, stored as text in json format
        calendar: user's calendar data, stored as text in json format
        syllabi: user's parsed syllabi data, stored as text in json format


    Raise:
        Exception: if failed to connect to the database
    '''
    try:
        with sqlite3.connect(DB_NAME) as conn:
            cursor = conn.cursor()

            cursor.execute('''
                create table if not exists users(
                    email text unique not null,
                    google_credentials text,
                    calendar text,
                    syllabi text
                )
            ''')
            
            conn.commit()
            print(f"Database Initialization Successful.")

    except sqlite3.Error as e:
        raise Exception(f"Database Connection Error: {e}")

def fetch_user_creds(email):
    '''
    Fetch user's google credentials based on their email.
    If the user already exist, auto-create a new user profile in the database.

    Args:
        email: user's email
    
    Returns:
        User's google credentials as string, None if user does not exist

    Raise:
        Exception: if failed to connect to the database
    '''
    try:
        with sqlite3.connect(DB_NAME) as conn:
            cursor = conn.cursor()

            cursor.execute("select google_credentials from users where email = ?", (email,))
            row = cursor.fetchone()

        if row is None:
            add_user(email)
            print(f"New user auto-created. No credentials acquired.")
            return None
        print(f"User {email} credentials acquired.")
        return row[0]
    
    except sqlite3.Error as e:
        raise Exception(f"Failed to fetch user {email} credentials: {e}")

def add_user(email):
    '''
    Create a new user profile with their email address only.

    Args:
        email: user's email
    
    Raise:
        Exception: if failed to connect to the database, or if the user already exists
    '''
    try:
        with sqlite3.connect(DB_NAME) as conn:
            cursor = conn.cursor()

            cursor.execute('''
                            insert into users(email, google_credentials, calendar, syllabi)
                            values (?, NULL, NULL, NULL)
                    ''', (email,))
            
            conn.commit()
            print(f"New User Created: {email}")
    
    except sqlite3.IntegrityError as e:
        raise Exception(f"User Already Exists: {e}")
    except sqlite3.Error as e:
        raise Exception(f"Failed to add the user {email}: {e}")

def remove_user(email):
    '''
    Remove an user from the database.

    Args:
        email: user's email
    
    Raise:
        Exception: if failed to connect to the database, or if the user does not exist
    '''
    try:
        with sqlite3.connect(DB_NAME) as conn:
            cursor = conn.cursor()

            cursor.execute('delete from users where email = ?', (email,))
            
            if cursor.rowcount > 0:
                conn.commit()
                print(f"User {email} removed.")
            else:
                raise Exception(f"Failed to remove the user as user {email} does not exist.")
            
    except sqlite3.Error as e:
        raise Exception(f"Failed to remove the user {email}: {e}")
    
    

def update_creds(email, new_creds):
    '''
    Update the google credentials of an existing user.

    Args:
        email: user's email
        new_creds: google credentials of that user
    
    Raise:
        Exception: if failed to connect to the database, or if the user does not exist
    '''
    try:
        with sqlite3.connect(DB_NAME) as conn:
            cursor = conn.cursor()
            cursor.execute('select syllabi from users where email = ?', (email,))
            row = cursor.fetchone()
            
            if row:
                new_data_json = json.dumps(new_creds)
                cursor.execute('''
                    update users 
                    set google_credentials = ?
                    where email = ?
                ''', (new_data_json,email))
                conn.commit()
                print(f"Google Credentials updated for {email}.")
            else:
                raise Exception(f"Failed to update user {email} credentials as the user does not exist.")

    except sqlite3.Error as e:
        raise Exception(f"Failed to update user {email}'s credentials: {e}")


def update_syllabi(email, new_syllabus_data):
    '''
    Update the syllabi info of an existing user.

    Args:
        email: user's email
        new_syllabus_data: parsed syllabi text of that user
    
    Raise:
        Exception: if failed to connect to the database, or if the user does not exist
    '''
    try:
        with sqlite3.connect(DB_NAME) as conn:
            cursor = conn.cursor()
            cursor.execute('select syllabi from users where email = ?', (email,))
            row = cursor.fetchone()
            
            if row:
                new_data_json = json.dumps(new_syllabus_data)
                cursor.execute('''
                    update users 
                    set syllabi = ? 
                    where email = ?
                ''', (new_data_json, email))
                conn.commit()
                print(f"Syllabi updated for {email}.")
            else:
                raise Exception(f"Failed to update user {email} credentials as the user does not exist.")

    except sqlite3.Error as e:
        raise Exception(f"Failed to update user {email}'s syllabi: {e}")
    
def update_calendar(email, new_calendar):
    '''
    Update the calendar info of an existing user.

    Args:
        email: user's email
        new_calendar: calendar info of that user
    
    Raise:
        Exception: if failed to connect to the database, or if the user does not exist
    '''
    try:
        with sqlite3.connect(DB_NAME) as conn:
            cursor = conn.cursor()
            cursor.execute('select calendar from users where email = ?', (email,))
            row = cursor.fetchone()
            
            if row:
                new_data_json = json.dumps(new_calendar)
                cursor.execute('''
                    update users 
                    set calendar = ? 
                    where email = ?
                ''', (new_data_json, email))
                conn.commit()
                print(f"Calendar updated for {email}.")
            else:
                raise Exception(f"Failed to update user {email} calendar as the user does not exist.")

    except sqlite3.Error as e:
        raise Exception(f"Failed to update user {email}'s calendar: {e}")


# --- Verification Block ---
if __name__ == "__main__":
    init_db()

    # 1. Test Adding a User
    # We pass a fake dictionary for credentials
    mock_creds = {"token": "abc-123", "refresh_token": "xyz-789"}
    fetch_user_creds("student@test.edu")
    update_creds("student@test.edu",mock_creds)

    # 2. Test Updating Syllabi
    # This matches the JSON structure we designed earlier
    syllabus_data = [
        {
            "course": "CS101",
            "events": [
                {"title": "Midterm", "date": "2023-10-25"},
                {"title": "Final", "date": "2023-12-15"}
            ]
        }
    ]
    update_syllabi("student@test.edu", syllabus_data)

    # 3. Verify Data was Stored as JSON
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT syllabi FROM users WHERE email='student@test.edu'")
    stored_json = c.fetchone()[0]
    print("\n--- Raw Stored JSON ---")
    print(stored_json)
    
    # 4. Remove User
    #remove_user("student@test.edu")