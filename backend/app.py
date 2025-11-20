"""
Bill Scanner App - Backend API Server
Python Flask REST API for PostgreSQL database access
Supports web clients (Flutter web) with CORS
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import bcrypt
import os
from datetime import datetime, timezone
from dotenv import load_dotenv
import uuid
import jwt
from functools import wraps
import traceback

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
    """Get PostgreSQL database connection"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        raise


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
    """User login endpoint - accepts email or username"""
    try:
        data = request.get_json()
        # Support both 'email' and 'email_or_username' for backward compatibility
        email_or_username = (data.get('email_or_username') or data.get('email') or '').strip()
        password = data.get('password') or ''

        if not email_or_username or not password:
            return jsonify({'error': 'Email/username and password are required'}), 400

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Get user by email or username
        cursor.execute(
            '''
            SELECT user_id, email, username, password_hash, full_name, created_at, 
                   last_login, is_active, email_verified
            FROM users 
            WHERE (email = %s OR username = %s) AND is_active = TRUE
            ''',
            (email_or_username, email_or_username)
        )

        user = cursor.fetchone()

        if not user:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Invalid email/username or password'}), 401

        # Verify password
        password_valid = verify_password(password, user['password_hash'])
        
        # Debug logging (remove in production)
        if not password_valid:
            print(f"Password verification failed for: {email_or_username}")
            print(f"Stored hash: {user['password_hash'][:20]}...")
            print(f"Password length: {len(password)}")
        
        if not password_valid:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Invalid email/username or password'}), 401

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
            'username': user['username'],
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
    conn = None
    cursor = None
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Request body is required'}), 400
            
        # Handle None values from JSON (null in JSON becomes None in Python)
        email = (data.get('email') or '').strip()
        password = data.get('password') or ''
        username_raw = data.get('username')
        username = username_raw.strip() if username_raw else None
        full_name_raw = data.get('full_name')
        full_name = full_name_raw.strip() if full_name_raw else None

        if not email or not password:
            return jsonify({'error': 'Email and password are required'}), 400

        if not username:
            return jsonify({'error': 'Username is required'}), 400

        if not full_name:
            return jsonify({'error': 'Full name is required'}), 400

        if len(password) < 6:
            return jsonify({'error': 'Password must be at least 6 characters'}), 400

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Check if email already exists
        cursor.execute('SELECT user_id FROM users WHERE email = %s', (email,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({'error': 'Email already exists'}), 409

        # Validate username (required)
        if len(username) < 3:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Username must be at least 3 characters'}), 400
        
        if not username.replace('_', '').isalnum():
            cursor.close()
            conn.close()
            return jsonify({'error': 'Username can only contain letters, numbers, and underscores'}), 400
        
        # Check if username already exists
        cursor.execute('SELECT user_id FROM users WHERE username = %s', (username,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({'error': 'Username already exists'}), 409

        # Hash password
        password_hash = hash_password(password)

        # Create user
        user_id = str(uuid.uuid4())
        cursor.execute(
            '''
            INSERT INTO users (user_id, email, username, password_hash, full_name, email_verified, is_active)
            VALUES (%s, %s, %s, %s, %s, TRUE, TRUE)
            RETURNING user_id, email, username, full_name, created_at, is_active, email_verified
            ''',
            (user_id, email, username, password_hash, full_name)
        )

        user = cursor.fetchone()
        
        if not user:
            conn.rollback()
            cursor.close()
            conn.close()
            return jsonify({'error': 'Failed to create user'}), 500

        # Create default user settings
        try:
            cursor.execute(
                '''
                INSERT INTO user_settings (user_id, currency, appearance_mode, default_category, push_notifications_enabled)
                VALUES (%s, 'USD', 'system', 'Uncategorized', TRUE)
                ON CONFLICT (user_id) DO NOTHING
                ''',
                (user_id,)
            )
        except Exception as settings_error:
            print(f"Warning: Failed to create user settings: {settings_error}")
            traceback.print_exc()
            # Settings creation failed, but user was created, so commit the user
            conn.commit()
            cursor.close()
            conn.close()
            # Return user without settings
            user_data = {
                'user_id': str(user['user_id']),
                'email': user['email'],
                'full_name': user['full_name'],
                'created_at': user['created_at'].isoformat() if user['created_at'] else None,
                'is_active': user['is_active'],
                'email_verified': user['email_verified'],
            }
            return jsonify({'user': user_data, 'warning': 'User created but settings could not be initialized'}), 201

        conn.commit()

        user_data = {
            'user_id': str(user['user_id']),
            'email': user['email'],
            'username': user['username'],
            'full_name': user['full_name'],
            'created_at': user['created_at'].isoformat() if user['created_at'] else None,
            'is_active': user['is_active'],
            'email_verified': user['email_verified'],
        }

        cursor.close()
        conn.close()

        return jsonify({'user': user_data}), 201

    except psycopg2.IntegrityError as e:
        if conn:
            conn.rollback()
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        print(f"Signup integrity error: {e}")
        error_msg = str(e)
        if 'email' in error_msg.lower() or 'unique' in error_msg.lower():
            return jsonify({'error': 'Email already exists'}), 409
        return jsonify({'error': f'Database constraint error: {error_msg}'}), 400
    except psycopg2.Error as e:
        if conn:
            conn.rollback()
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        print(f"Signup database error: {e}")
        traceback.print_exc()
        return jsonify({'error': f'Database error: {str(e)}'}), 500
    except Exception as e:
        if conn:
            conn.rollback()
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        print(f"Signup error: {e}")
        traceback.print_exc()
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500


@app.route('/api/auth/forgot-password', methods=['POST'])
def forgot_password():
    """Create password reset token"""
    try:
        data = request.get_json()
        email = data.get('email', '').strip()

        if not email:
            return jsonify({'error': 'Email is required'}), 400

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Get user
        cursor.execute(
            'SELECT user_id, is_active FROM users WHERE email = %s',
            (email,)
        )
        user = cursor.fetchone()

        if not user or not user['is_active']:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Email not found or account is inactive'}), 404

        # Generate reset token
        reset_token = str(uuid.uuid4())
        expires_at = datetime.now(timezone.utc).replace(hour=23, minute=59, second=59)

        # Store token
        cursor.execute(
            '''
            INSERT INTO password_reset_tokens (user_id, token, expires_at)
            VALUES (%s, %s, %s)
            ON CONFLICT (user_id) DO UPDATE SET
                token = EXCLUDED.token,
                expires_at = EXCLUDED.expires_at,
                created_at = CURRENT_TIMESTAMP
            ''',
            (user['user_id'], reset_token, expires_at)
        )

        conn.commit()
        cursor.close()
        conn.close()

        # In production, send email with reset link
        # For now, return token (remove in production!)
        return jsonify({
            'message': 'Password reset token created',
            'token': reset_token,  # Remove this in production!
            'note': 'In production, this token would be sent via email'
        }), 200

    except Exception as e:
        print(f"Forgot password error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/api/auth/reset-password', methods=['POST'])
def reset_password():
    """Reset password using token"""
    try:
        data = request.get_json()
        token = data.get('token', '')
        new_password = data.get('new_password', '')

        if not token or not new_password:
            return jsonify({'error': 'Token and new password are required'}), 400

        if len(new_password) < 6:
            return jsonify({'error': 'Password must be at least 6 characters'}), 400

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Get token
        cursor.execute(
            '''
            SELECT user_id, expires_at 
            FROM password_reset_tokens 
            WHERE token = %s AND expires_at > CURRENT_TIMESTAMP
            ''',
            (token,)
        )
        token_data = cursor.fetchone()

        if not token_data:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Invalid or expired token'}), 400

        # Update password
        password_hash = hash_password(new_password)
        cursor.execute(
            'UPDATE users SET password_hash = %s WHERE user_id = %s',
            (password_hash, token_data['user_id'])
        )

        # Delete token
        cursor.execute(
            'DELETE FROM password_reset_tokens WHERE token = %s',
            (token,)
        )

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'message': 'Password reset successfully'}), 200

    except Exception as e:
        print(f"Reset password error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


# ============================================
# USER ENDPOINTS
# ============================================

@app.route('/api/users/<user_id>', methods=['GET'])
def get_user(user_id):
    """Get user by ID"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        cursor.execute(
            '''
            SELECT user_id, email, full_name, created_at, last_login, is_active, email_verified
            FROM users 
            WHERE user_id = %s
            ''',
            (user_id,)
        )

        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if not user:
            return jsonify({'error': 'User not found'}), 404

        user_data = {
            'user_id': str(user['user_id']),
            'email': user['email'],
            'full_name': user['full_name'],
            'created_at': user['created_at'].isoformat() if user['created_at'] else None,
            'last_login': user['last_login'].isoformat() if user['last_login'] else None,
            'is_active': user['is_active'],
            'email_verified': user['email_verified'],
        }

        return jsonify({'user': user_data}), 200

    except Exception as e:
        print(f"Get user error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


# ============================================
# BILLS ENDPOINTS
# ============================================

@app.route('/api/bills/<user_id>', methods=['GET'])
def get_user_bills(user_id):
    """Get bills for a user"""
    try:
        # Query parameters
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')
        category_id = request.args.get('category_id')
        vendor_name = request.args.get('vendor_name')
        limit = int(request.args.get('limit', 50))
        offset = int(request.args.get('offset', 0))

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Build query
        query = '''
            SELECT 
                b.bill_id, b.user_id, b.vendor_name, b.amount, b.bill_date,
                b.description, b.image_path, b.currency, b.is_paid,
                b.created_at, b.updated_at,
                c.category_id, c.name as category_name, c.color as category_color
            FROM bills b
            LEFT JOIN categories c ON b.category_id = c.category_id
            WHERE b.user_id = %s
        '''
        params = [user_id]

        if start_date:
            query += ' AND b.bill_date >= %s'
            params.append(start_date)
        if end_date:
            query += ' AND b.bill_date <= %s'
            params.append(end_date)
        if category_id:
            query += ' AND b.category_id = %s'
            params.append(category_id)
        if vendor_name:
            query += ' AND b.vendor_name ILIKE %s'
            params.append(f'%{vendor_name}%')

        query += ' ORDER BY b.bill_date DESC LIMIT %s OFFSET %s'
        params.extend([limit, offset])

        cursor.execute(query, params)
        bills = cursor.fetchall()

        bills_list = []
        for bill in bills:
            bills_list.append({
                'bill_id': str(bill['bill_id']),
                'user_id': str(bill['user_id']),
                'vendor_name': bill['vendor_name'],
                'amount': float(bill['amount']),
                'bill_date': bill['bill_date'].isoformat() if bill['bill_date'] else None,
                'category_id': str(bill['category_id']) if bill['category_id'] else None,
                'category_name': bill['category_name'],
                'category_color': bill['category_color'],
                'description': bill['description'],
                'image_path': bill['image_path'],
                'currency': bill['currency'],
                'is_paid': bill['is_paid'],
                'created_at': bill['created_at'].isoformat() if bill['created_at'] else None,
                'updated_at': bill['updated_at'].isoformat() if bill['updated_at'] else None,
            })

        cursor.close()
        conn.close()

        return jsonify({'bills': bills_list}), 200

    except Exception as e:
        print(f"Get bills error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/api/bills', methods=['POST'])
def create_bill():
    """Create a new bill"""
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        vendor_name = data.get('vendor_name')
        amount = data.get('amount')
        bill_date = data.get('bill_date')
        category_id = data.get('category_id')
        description = data.get('description')
        image_path = data.get('image_path')
        currency = data.get('currency', 'USD')

        if not user_id or not vendor_name or not amount or not bill_date:
            return jsonify({'error': 'Missing required fields'}), 400

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        bill_id = str(uuid.uuid4())
        bill_date_obj = datetime.fromisoformat(bill_date.replace('Z', '+00:00'))

        cursor.execute(
            '''
            INSERT INTO bills (bill_id, user_id, vendor_name, amount, bill_date, 
                             category_id, description, image_path, currency, is_paid)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, FALSE)
            RETURNING bill_id, user_id, vendor_name, amount, bill_date, 
                     category_id, description, image_path, currency, is_paid,
                     created_at, updated_at
            ''',
            (bill_id, user_id, vendor_name, amount, bill_date_obj, category_id, 
             description, image_path, currency)
        )

        bill = cursor.fetchone()

        # Get category info if exists
        category_name = None
        category_color = None
        if category_id:
            cursor.execute(
                'SELECT name, color FROM categories WHERE category_id = %s',
                (category_id,)
            )
            cat = cursor.fetchone()
            if cat:
                category_name = cat['name']
                category_color = cat['color']

        conn.commit()

        bill_data = {
            'bill_id': str(bill['bill_id']),
            'user_id': str(bill['user_id']),
            'vendor_name': bill['vendor_name'],
            'amount': float(bill['amount']),
            'bill_date': bill['bill_date'].isoformat() if bill['bill_date'] else None,
            'category_id': str(bill['category_id']) if bill['category_id'] else None,
            'category_name': category_name,
            'category_color': category_color,
            'description': bill['description'],
            'image_path': bill['image_path'],
            'currency': bill['currency'],
            'is_paid': bill['is_paid'],
            'created_at': bill['created_at'].isoformat() if bill['created_at'] else None,
            'updated_at': bill['updated_at'].isoformat() if bill['updated_at'] else None,
        }

        cursor.close()
        conn.close()

        return jsonify({'bill': bill_data}), 201

    except Exception as e:
        print(f"Create bill error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


# ============================================
# CATEGORIES ENDPOINTS
# ============================================

@app.route('/api/categories', methods=['GET'])
def get_categories():
    """Get categories"""
    try:
        user_id = request.args.get('user_id')

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        if user_id:
            # Get user-specific and default categories
            cursor.execute(
                '''
                SELECT category_id, name, color, icon, is_default, created_at
                FROM categories
                WHERE user_id = %s OR is_default = TRUE
                ORDER BY is_default DESC, name ASC
                ''',
                (user_id,)
            )
        else:
            # Get all default categories
            cursor.execute(
                '''
                SELECT category_id, name, color, icon, is_default, created_at
                FROM categories
                WHERE is_default = TRUE
                ORDER BY name ASC
                '''
            )

        categories = cursor.fetchall()

        categories_list = []
        for cat in categories:
            categories_list.append({
                'category_id': str(cat['category_id']),
                'name': cat['name'],
                'color': cat['color'],
                'icon': cat['icon'],
                'is_default': cat['is_default'],
                'created_at': cat['created_at'].isoformat() if cat['created_at'] else None,
            })

        cursor.close()
        conn.close()

        return jsonify({'categories': categories_list}), 200

    except Exception as e:
        print(f"Get categories error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


# ============================================
# USER SETTINGS ENDPOINTS
# ============================================

@app.route('/api/settings/<user_id>', methods=['GET'])
def get_user_settings(user_id):
    """Get user settings"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        cursor.execute(
            '''
            SELECT currency, appearance_mode, default_category,
                   push_notifications_enabled, email_notifications_enabled,
                   bill_reminders_enabled
            FROM user_settings
            WHERE user_id = %s
            ''',
            (user_id,)
        )

        settings = cursor.fetchone()
        cursor.close()
        conn.close()

        if not settings:
            return jsonify({'error': 'Settings not found'}), 404

        settings_data = {
            'currency': settings['currency'],
            'appearance_mode': settings['appearance_mode'],
            'default_category': settings['default_category'],
            'push_notifications_enabled': settings['push_notifications_enabled'],
            'email_notifications_enabled': settings['email_notifications_enabled'],
            'bill_reminders_enabled': settings['bill_reminders_enabled'],
        }

        return jsonify({'settings': settings_data}), 200

    except Exception as e:
        print(f"Get settings error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@app.route('/api/settings/<user_id>', methods=['PUT'])
def update_user_settings(user_id):
    """Update user settings"""
    try:
        data = request.get_json()

        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Build update query dynamically
        updates = []
        params = []

        if 'currency' in data:
            updates.append('currency = %s')
            params.append(data['currency'])
        if 'appearance_mode' in data:
            updates.append('appearance_mode = %s')
            params.append(data['appearance_mode'])
        if 'default_category' in data:
            updates.append('default_category = %s')
            params.append(data['default_category'])
        if 'push_notifications_enabled' in data:
            updates.append('push_notifications_enabled = %s')
            params.append(data['push_notifications_enabled'])
        if 'email_notifications_enabled' in data:
            updates.append('email_notifications_enabled = %s')
            params.append(data['email_notifications_enabled'])
        if 'bill_reminders_enabled' in data:
            updates.append('bill_reminders_enabled = %s')
            params.append(data['bill_reminders_enabled'])

        if not updates:
            cursor.close()
            conn.close()
            return jsonify({'error': 'No fields to update'}), 400

        params.append(user_id)

        query = f'''
            UPDATE user_settings
            SET {', '.join(updates)}, updated_at = CURRENT_TIMESTAMP
            WHERE user_id = %s
        '''

        cursor.execute(query, params)
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({'message': 'Settings updated successfully'}), 200

    except Exception as e:
        print(f"Update settings error: {e}")
        return jsonify({'error': 'Internal server error'}), 500


# ============================================
# HEALTH CHECK
# ============================================

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
    print("Bill Scanner Backend API Server")
    print("=" * 50)
    print(f"Database: {DB_CONFIG['database']} @ {DB_CONFIG['host']}:{DB_CONFIG['port']}")
    print("Starting server on http://localhost:5000")
    print("API Base URL: http://localhost:5000/api")
    print("=" * 50)
    
    app.run(host='0.0.0.0', port=5000, debug=True)

