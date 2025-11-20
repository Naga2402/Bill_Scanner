# 🏗️ Bill Scanner App - Architecture Overview

## Platform-Specific Database Access

The app uses different database access methods based on the platform:

### 🌐 **Web (Flutter Web)**
- **Method**: HTTP REST API calls to Python Flask backend
- **Service**: `WebApiService` (in `lib/services/web_api_service.dart`)
- **Backend**: Python Flask server (`backend/app.py`)
- **Why**: Browsers don't support direct PostgreSQL connections (no native sockets)

### 📱 **Mobile/Desktop (Flutter Android/iOS/Windows/Linux/Mac)**
- **Method**: Direct PostgreSQL connection
- **Service**: `DatabaseService` (in `lib/services/database_service.dart`)
- **Backend**: Not needed - direct connection
- **Why**: Native platforms support socket connections

## How It Works

### Factory Pattern

The app uses `DatabaseServiceFactory` to automatically select the correct service:

```dart
// Automatically chooses the right service
final db = DatabaseServiceFactory.getService();

// On web: Returns WebApiService
// On mobile/desktop: Returns DatabaseService
```

### Service Selection Logic

```dart
if (kIsWeb) {
  return WebApiService();  // HTTP API calls
} else {
  return DatabaseService(); // Direct PostgreSQL
}
```

## File Structure

```
Bills_Scanner/bill_scanner_app/
├── lib/
│   ├── services/
│   │   ├── database_service_factory.dart  # Factory to select service
│   │   ├── database_service.dart          # Direct PostgreSQL (mobile/desktop)
│   │   └── web_api_service.dart          # HTTP API (web)
│   └── screens/
│       └── ... (all screens use DatabaseServiceFactory)

backend/
├── app.py                    # Flask REST API server
├── requirements.txt          # Python dependencies
├── .env                      # Database configuration
└── README.md                 # Backend setup guide
```

## API Endpoints (Backend)

All endpoints are under `/api/`:

- `POST /api/auth/login` - User authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/forgot-password` - Password reset request
- `POST /api/auth/reset-password` - Reset password
- `GET /api/users/<user_id>` - Get user
- `GET /api/bills/<user_id>` - Get user bills
- `POST /api/bills` - Create bill
- `GET /api/categories` - Get categories
- `GET /api/settings/<user_id>` - Get user settings
- `PUT /api/settings/<user_id>` - Update settings

## Configuration

### Web API Base URL

Edit `lib/services/web_api_service.dart`:
```dart
final String _baseUrl = 'http://localhost:5000/api';
```

For network access:
```dart
final String _baseUrl = 'http://192.168.0.110:5000/api';
```

### Direct PostgreSQL Connection

Edit `lib/services/database_service.dart`:
```dart
final String _host = '192.168.0.110';
final String _databaseName = 'bill_scanner_db';
final String _username = 'postgres';
final String _password = 'your_password';
```

## Setup Instructions

### For Web Development

1. **Start Backend Server:**
   ```bash
   cd backend
   pip install -r requirements.txt
   # Edit .env with database credentials
   python app.py
   ```

2. **Run Flutter Web:**
   ```bash
   cd Bills_Scanner/bill_scanner_app
   flutter run -d chrome
   ```

### For Mobile/Desktop Development

1. **No backend needed!** Just ensure PostgreSQL is accessible

2. **Update database credentials** in `database_service.dart`

3. **Run Flutter:**
   ```bash
   flutter run -d android  # or ios, windows, etc.
   ```

## Benefits

✅ **Web Support**: Can run in browsers via HTTP API  
✅ **Performance**: Mobile apps use direct connection (faster)  
✅ **Single Codebase**: Same Flutter code works on all platforms  
✅ **Automatic Selection**: Factory pattern handles platform detection  
✅ **Flexible**: Easy to switch between direct DB and API

## Testing

### Test Backend API

```bash
# Health check
curl http://localhost:5000/api/health

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@billscanner.com","password":"demo123"}'
```

### Test Direct Connection (Mobile/Desktop)

The app will automatically use direct PostgreSQL connection when running on mobile/desktop platforms.

## Production Considerations

### Web
- Deploy backend to a server (e.g., Heroku, AWS, DigitalOcean)
- Use HTTPS
- Update `_baseUrl` to production URL
- Enable CORS for your domain only

### Mobile/Desktop
- Ensure PostgreSQL is accessible from devices
- Use secure connection (SSL/TLS)
- Consider connection pooling for better performance

