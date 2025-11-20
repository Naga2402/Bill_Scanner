# 🚀 Backend API Server Setup Guide

## Overview

The backend API server enables Flutter web apps to connect to PostgreSQL through HTTP REST endpoints.

**Architecture:**
- **Web (Flutter)**: Uses this Python Flask backend API → PostgreSQL
- **Mobile/Desktop (Flutter)**: Uses direct PostgreSQL connection (no backend needed)

## Quick Start

### Windows

1. Navigate to backend folder:
   ```bash
   cd backend
   ```

2. Run the setup script:
   ```bash
   start_server.bat
   ```
   This will:
   - Create virtual environment
   - Install dependencies
   - Create `.env` file if needed
   - Start the server

3. Edit `.env` file with your database credentials:
   ```env
   DB_HOST=192.168.0.110
   DB_PORT=5432
   DB_NAME=bill_scanner_db
   DB_USER=postgres
   DB_PASSWORD=your_password_here
   ```

4. Restart the server if you changed `.env`

### Linux/Mac

1. Navigate to backend folder:
   ```bash
   cd backend
   ```

2. Make script executable and run:
   ```bash
   chmod +x start_server.sh
   ./start_server.sh
   ```

3. Edit `.env` file with your database credentials

## Manual Setup

### Step 1: Install Python Dependencies

```bash
cd backend
pip install -r requirements.txt
```

Or use virtual environment (recommended):

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Step 2: Configure Environment

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Edit `.env` with your PostgreSQL credentials:

```env
DB_HOST=192.168.0.110
DB_PORT=5432
DB_NAME=bill_scanner_db
DB_USER=postgres
DB_PASSWORD=postgres
```

### Step 3: Start Server

```bash
python app.py
```

Server will start on `http://localhost:5000`

## Verify Setup

1. **Check server is running:**
   ```bash
   curl http://localhost:5000/api/health
   ```
   Should return: `{"status": "healthy", "database": "connected"}`

2. **Test login:**
   ```bash
   curl -X POST http://localhost:5000/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"demo@billscanner.com","password":"demo123"}'
   ```

## Update Flutter App

The Flutter app is already configured to use `http://localhost:5000/api` by default.

If your backend is on a different host/port, update:
- File: `Bills_Scanner/bill_scanner_app/lib/services/web_api_service.dart`
- Line: `final String _baseUrl = 'http://localhost:5000/api';`

For network access (e.g., from another device):
```dart
final String _baseUrl = 'http://192.168.0.110:5000/api';
```

## API Endpoints

All endpoints are under `/api/`:

- `POST /api/auth/login` - Login
- `POST /api/auth/signup` - Register
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password
- `GET /api/users/<user_id>` - Get user
- `GET /api/bills/<user_id>` - Get bills
- `POST /api/bills` - Create bill
- `GET /api/categories` - Get categories
- `GET /api/settings/<user_id>` - Get settings
- `PUT /api/settings/<user_id>` - Update settings
- `GET /api/health` - Health check

## Troubleshooting

### Database Connection Error

1. Check PostgreSQL is running
2. Verify credentials in `.env`
3. Check firewall allows connections
4. Test connection manually:
   ```bash
   psql -h 192.168.0.110 -U postgres -d bill_scanner_db
   ```

### Port Already in Use

Change port in `app.py`:
```python
app.run(host='0.0.0.0', port=5001, debug=True)
```

Update Flutter app's `_baseUrl` accordingly.

### CORS Errors

CORS is enabled for all origins. If you see CORS errors:
- Check backend server is running
- Verify the URL in `web_api_service.dart` matches backend URL
- Check browser console for exact error

## Production Deployment

For production, use a production WSGI server:

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

Or use systemd service, Docker, etc.

## Security Notes

1. Change `JWT_SECRET` in `.env` for production
2. Use HTTPS in production
3. Restrict CORS origins
4. Add rate limiting
5. Implement proper authentication middleware

