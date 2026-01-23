import sqlite3
import json # I assume we are gonna use json for calendar info storage

DB_NAME = "DBNAME.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
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
    conn.close()
    print(f"Database Initialization Successful.")

def fetch_user_creds(email):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute("select google_credentials from users where email = ?", (email,))
    row  = cursor.fetchone()
    if row is None:
        add_user(email)
        print(f"New user added. No credentials acquired.")
        return None
    print(f"User {email} credentials acquired.")
    return row[0]

def add_user(email):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute('''
                       insert into users(email, google_credentials, calendar, syllabi)
                       values (?, NULL, NULL, NULL)
            ''', (email,))
    
    conn.commit()
    conn.close()

def remove_user(email):
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute('delete from users where email = ?', (email,))
    
    if cursor.rowcount > 0:
        conn.commit()
        print(f"User {email} removed.")
    else:
        print(f"User {email} not found.")
    
    conn.close()

def update_creds(email, new_creds):
    conn = sqlite3.connect(DB_NAME)
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
        print(f"Error: User {email} not found.")

    conn.close()


def update_syllabi(email, new_syllabus_data):
    conn = sqlite3.connect(DB_NAME)
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
        print(f"Error: User {email} not found.")

    conn.close()


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
    remove_user("student@test.edu")