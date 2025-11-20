"""
Bill Scanner App - Backend API Server (pg8000 version)
Alternative version using pg8000 (pure Python, no compilation needed)
Use this if psycopg2-binary installation fails on Windows
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import pg8000
from pg8000 import Connection
import bcrypt
import os
from datetime import datetime, timezone
from dotenv import load_dotenv
import uuid
import jwt
from functools import wraps

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', '192.168.0.110'),
    'port': int(os.getenv('DB_PORT', 5432)),
    'database': os.getenv('DB_NAME', 'bill_scanner_db'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'postgres'),
}

# JWT Secret (in production, use a secure random key)
JWT_SECRET = os.getenv('JWT_SECRET', 'your-secret-key-change-in-production')


def get_db_connection():
    """Get PostgreSQL database connection using pg8000"""
    try:
        conn = pg8000.connect(
            host=DB_CONFIG['host'],
            port=DB_CONFIG['port'],
            database=DB_CONFIG['database'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password']
        )
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        raise


def row_to_dict(cursor, row):
    """Convert database row to dictionary"""
    if row is None:
        return None
    columns = [desc[0] for desc in cursor.description]
    return dict(zip(columns, row))


def hash_password(password: str) -> str:
    """Hash password using bcrypt"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')


def verify_password(password: str, hashed: str) -> bool:
    """Verify password against hash"""
    try:
        return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))
    except Exception as e:
        print(f"Password verification error: {e}")
        return False


# ============================================
# AUTHENTICATION ENDPOINTS
# ============================================

@app.route('/api/auth/login', methods=['POST'])
def login():
    """User login endpoint"""
    try:
        data = request.get_json()
        email = data.get('email', '').strip()
        password = data.get('password', '')

        if not email or not password:
            return jsonify({'error': 'Email and password are required'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        # Get user by email
        cursor.execute(
            '''
            SELECT user_id, email, password_hash, full_name, created_at, 
                   last_login, is_active, email_verified
            FROM users 
            WHERE email = %s AND is_active = TRUE
            ''',
            (email,)
        )

        row = cursor.fetchone()
        user = row_to_dict(cursor, row) if row else None

        if not user:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Invalid email or password'}), 401

        # Verify password
        if not verify_password(password, user['password_hash']):
            cursor.close()
            conn.close()
            return jsonify({'error': 'Invalid email or password'}), 401

        # Update last login
        cursor.execute(
            'UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = %s',
            (user['user_id'],)
        )
        conn.commit()

        # Return user data (without password hash)
        user_data = {
            'user_id': str(user['user_id']),
            'email': user['email'],
            'full_name': user['full_name'],
            'created_at': user['created_at'].isoformat() if user['created_at'] else None,
            'last_login': datetime.now(timezone.utc).isoformat(),
            'is_active': user['is_active'],
            'email_verified': user['email_verified'],
        }

        cursor.close()
        conn.close()

        return jsonify({'user': user_data}), 200

    except Exception as e:
        print(f"Login error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/api/auth/signup', methods=['POST'])
def signup():
    """User registration endpoint"""
    try:
        data = request.get_json()
        email = data.get('email', '').strip()
        password = data.get('password', '')
        full_name = data.get('full_name', '').strip() or None

        if not email or not password:
            return jsonify({'error': 'Email and password are required'}), 400

        if len(password) < 6:
            return jsonify({'error': 'Password must be at least 6 characters'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if email already exists
        cursor.execute('SELECT user_id FROM users WHERE email = %s', (email,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({'error': 'Email already exists'}), 409

        # Hash password
        password_hash = hash_password(password)

        # Create user
        user_id = str(uuid.uuid4())
        cursor.execute(
            '''
            INSERT INTO users (user_id, email, password_hash, full_name, email_verified, is_active)
            VALUES (%s, %s, %s, %s, TRUE, TRUE)
            RETURNING user_id, email, full_name, created_at, is_active, email_verified
            ''',
            (user_id, email, password_hash, full_name)
        )

        row = cursor.fetchone()
        user = row_to_dict(cursor, row)

        # Create default user settings
        cursor.execute(
            '''
            INSERT INTO user_settings (user_id, currency, appearance_mode, default_category, push_notifications_enabled)
            VALUES (%s, 'USD', 'system', 'Uncategorized', TRUE)
            ON CONFLICT (user_id) DO NOTHING
            ''',
            (user_id,)
        )

        conn.commit()

        user_data = {
            'user_id': str(user['user_id']),
            'email': user['email'],
            'full_name': user['full_name'],
            'created_at': user['created_at'].isoformat() if user['created_at'] else None,
            'is_active': user['is_active'],
            'email_verified': user['email_verified'],
        }

        cursor.close()
        conn.close()

        return jsonify({'user': user_data}), 201

    except Exception as e:
        print(f"Signup error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


# Note: Other endpoints follow the same pattern - convert cursor results using row_to_dict()
# For brevity, I'm showing the pattern. The full implementation would convert all endpoints.

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT 1')
        cursor.close()
        conn.close()
        return jsonify({'status': 'healthy', 'database': 'connected'}), 200
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500


if __name__ == '__main__':
    print("=" * 50)
    print("Bill Scanner Backend API Server (pg8000 version)")
    print("=" * 50)
    print(f"Database: {DB_CONFIG['database']} @ {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print("Starting server on http://localhost:5000")
    print("API Base URL: http://localhost:5000/api")
    print("=" * 50)
    
    app.run(host='0.0.0.0', port=5000, debug=True)

