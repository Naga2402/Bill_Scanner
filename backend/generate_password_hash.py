"""
Generate a new password hash for demo123
"""
import bcrypt

password = 'demo123'
hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

print("=" * 60)
print("New password hash for 'demo123':")
print("=" * 60)
print(hash)
print()
print("SQL to update the database:")
print("=" * 60)
print(f"UPDATE users SET password_hash = '{hash}' WHERE email = 'demo@billscanner.com';")
print("=" * 60)

