import sqlite3
import json # I assume we are gonna use json for calendar info storage

DB_NAME = "DBNAME.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    cursor.execute('''
        create table if not exist users(
            email text unique not null,
            google_credentials text,
            calendar text,
            syllabi text
        )
    ''')
    
    conn.commit()
    conn.close()
    print(f"Database Initialization Successful.")

def add_user():
    ...

def remove_user():
    ...

def update_syllai():
    ...
