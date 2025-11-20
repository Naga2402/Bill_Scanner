# Bill Scanner - Backend API Server

Python Flask REST API server for PostgreSQL database access. This backend enables Flutter web apps to connect to PostgreSQL through HTTP endpoints.

## 🏗️ Architecture

- **Web (Flutter)**: Uses this backend API via HTTP requests
- **Mobile/Desktop (Flutter)**: Uses direct PostgreSQL connection (no backend needed)

## 📋 Prerequisites

1. **Python 3.8+** installed
2. **PostgreSQL** database running (see `database/` folder for setup)
3. **Database created** with tables (run `database/Bills_Scanner_ConsolidatedScripts.sql`)

## 🚀 Setup Instructions

### Step 1: Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### Step 2: Configure Environment

Copy `.env.example` to `.env` and update with your database credentials:

```bash
cp .env.example .env
```

Edit `.env`:
```env
DB_HOST=192.168.0.110
DB_PORT=5432
DB_NAME=bill_scanner_db
DB_USER=postgres
DB_PASSWORD=your_password_here
```

### Step 3: Run the Server

```bash
python app.py
```

The server will start on `http://localhost:5000`

## 📡 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/signup` - User registration
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password with token

### Users
- `GET /api/users/<user_id>` - Get user by ID

### Bills
- `GET /api/bills/<user_id>` - Get user's bills (with filters)
- `POST /api/bills` - Create new bill

### Categories
- `GET /api/categories` - Get categories (optionally filtered by user_id)

### Settings
- `GET /api/settings/<user_id>` - Get user settings
- `PUT /api/settings/<user_id>` - Update user settings

### Health Check
- `GET /api/health` - Check server and database status

## 🔧 Configuration

Update `backend/app.py` or `.env` file to change:
- Database connection settings
- Server port (default: 5000)
- CORS settings

## 🌐 CORS

CORS is enabled for all origins. In production, restrict this:

```python
CORS(app, resources={r"/api/*": {"origins": "https://yourdomain.com"}})
```

## 🔒 Security Notes

1. **JWT Secret**: Change `JWT_SECRET` in production
2. **Password Reset**: Currently returns token in response (for testing). In production, send via email.
3. **HTTPS**: Use HTTPS in production
4. **Rate Limiting**: Add rate limiting for production (e.g., Flask-Limiter)

## 🐛 Troubleshooting

### Database Connection Error
- Check PostgreSQL is running
- Verify credentials in `.env`
- Check firewall allows connections

### Port Already in Use
- Change port in `app.py`: `app.run(port=5001)`
- Update `web_api_service.dart` base URL accordingly

## 📝 Example Requests

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@billscanner.com","password":"demo123"}'
```

### Get Bills
```bash
curl http://localhost:5000/api/bills/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11
```

## 🚀 Production Deployment

For production:
1. Use a production WSGI server (e.g., Gunicorn)
2. Set up reverse proxy (Nginx)
3. Enable HTTPS
4. Use environment variables for secrets
5. Add logging and monitoring
6. Implement rate limiting
7. Add authentication middleware (JWT)

Example with Gunicorn:
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

