"""
Test password verification for demo user
"""
import bcrypt

# Password hash from database (from Bills_Scanner_ConsolidatedScripts.sql)
stored_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
password = 'demo123'

print("Testing password verification...")
print(f"Stored hash: {stored_hash}")
print(f"Password to test: {password}")

try:
    result = bcrypt.checkpw(password.encode('utf-8'), stored_hash.encode('utf-8'))
    print(f"Password verification result: {result}")
    
    if not result:
        print("\n❌ Password verification FAILED!")
        print("The password hash in the database might not match 'demo123'")
        print("\nTo fix this, you can:")
        print("1. Reset the password in the database")
        print("2. Or create a new hash for 'demo123'")
        
        # Generate a new hash
        new_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        print(f"\nNew hash for 'demo123': {new_hash}")
        print("\nUpdate SQL:")
        print(f"UPDATE users SET password_hash = '{new_hash}' WHERE email = 'demo@billscanner.com';")
    else:
        print("\n✅ Password verification SUCCESS!")
        print("The password hash is correct.")
        
except Exception as e:
    print(f"Error: {e}")

