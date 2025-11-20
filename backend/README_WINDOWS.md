# Windows Installation Guide

## Problem: psycopg2-binary Installation Fails

If you see this error:
```
error: Microsoft Visual C++ 14.0 or greater is required
```

## Solution Options

### Option 1: Install Microsoft C++ Build Tools (Recommended)

1. Download Microsoft C++ Build Tools:
   - Visit: https://visualstudio.microsoft.com/visual-cpp-build-tools/
   - Download "Build Tools for Visual Studio"
   - Run the installer
   - Select "C++ build tools" workload
   - Install (this is a large download, ~6GB)

2. Restart your computer

3. Try installing again:
   ```bash
   pip install -r requirements.txt
   ```

### Option 2: Use Pre-built Wheel (Easier)

Try installing with pre-built wheels only:

```bash
pip install --upgrade pip setuptools wheel
pip install psycopg2-binary --only-binary :all:
pip install -r requirements.txt
```

### Option 3: Use Alternative Package (pg8000 - Pure Python)

If you can't install build tools, use `pg8000` which is pure Python:

1. Update `requirements.txt`:
   ```txt
   Flask==3.0.0
   Flask-CORS==4.0.0
   pg8000>=1.31.0
   bcrypt==4.1.1
   python-dotenv==1.0.0
   PyJWT==2.8.0
   ```

2. Update `app.py` connection code:
   ```python
   import pg8000
   
   def get_db_connection():
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
   ```

3. Update cursor usage (pg8000 uses different syntax):
   ```python
   # Change from:
   cursor = conn.cursor(cursor_factory=RealDictCursor)
   
   # To:
   cursor = conn.cursor()
   # Then access results as tuples or convert to dict manually
   ```

### Option 4: Use Docker (Advanced)

Run PostgreSQL and backend in Docker containers (avoids Windows compilation issues).

## Quick Install Script

Run `install_windows.bat` which will:
1. Upgrade pip and setuptools
2. Try to install psycopg2-binary with pre-built wheels
3. Offer to use pg8000 if that fails

## Verification

After installation, test the connection:

```python
python -c "import psycopg2; print('psycopg2 installed successfully')"
```

Or if using pg8000:

```python
python -c "import pg8000; print('pg8000 installed successfully')"
```

