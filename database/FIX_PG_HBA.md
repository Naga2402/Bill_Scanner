# Fixing PostgreSQL pg_hba.conf for Network Connections

## Problem

Error: `no pg_hba.conf entry for host "192.168.0.110", user "postgres", database "bill_scanner_db", no encryption`

This means PostgreSQL is not configured to accept connections from your backend server's IP address.

## Solution

### Step 1: Edit pg_hba.conf

The file is located at:
```
C:\Program Files\PostgreSQL\17\data\pg_hba.conf
```

**IMPORTANT:** You need administrator privileges to edit this file!

### Step 2: Add Connection Entry

Add this line after the IPv4 local connections section:

```
host    all             all             192.168.0.110/32        md5
```

Or for the entire local network (192.168.0.0 - 192.168.0.255):

```
host    all             all             192.168.0.0/24          md5
```

### Step 3: Reload PostgreSQL Configuration

After saving the file, you need to reload PostgreSQL configuration. You can do this in one of these ways:

#### Option A: Using pgAdmin
1. Right-click on your server in pgAdmin
2. Select "Reload Configuration"

#### Option B: Using Command Line (as Administrator)
```powershell
# Find PostgreSQL service name
Get-Service | Where-Object {$_.Name -like "*postgresql*"}

# Reload configuration (replace service name)
Restart-Service postgresql-x64-17
# OR just reload without restart:
& "C:\Program Files\PostgreSQL\17\bin\pg_ctl.exe" reload -D "C:\Program Files\PostgreSQL\17\data"
```

#### Option C: Using SQL
```sql
SELECT pg_reload_conf();
```

### Step 4: Verify Connection

Test the connection from your backend:

```python
python -c "import psycopg2; conn = psycopg2.connect(host='192.168.0.110', port=5432, database='bill_scanner_db', user='postgres', password='your_password'); print('Connection successful!'); conn.close()"
```

## Connection Entry Format

```
TYPE    DATABASE    USER        ADDRESS         METHOD
host    all         all         192.168.0.110/32    md5
```

- **TYPE**: `host` = TCP/IP connection (allows both SSL and non-SSL)
- **DATABASE**: `all` = all databases
- **USER**: `all` = all users
- **ADDRESS**: `192.168.0.110/32` = specific IP, or `192.168.0.0/24` = entire subnet
- **METHOD**: 
  - `md5` = password authentication (encrypted)
  - `scram-sha-256` = more secure (PostgreSQL 10+)
  - `trust` = no password (NOT recommended for production)

## Security Notes

1. **For Development**: Using `md5` or `scram-sha-256` with specific IP is fine
2. **For Production**: 
   - Use `scram-sha-256` instead of `md5`
   - Consider using SSL/TLS connections
   - Restrict to specific IPs, not entire subnets
   - Use firewall rules in addition to pg_hba.conf

## Alternative: Use localhost

If your backend is on the same machine as PostgreSQL, you can:

1. Change backend `.env` to use `localhost` instead of `192.168.0.110`:
   ```env
   DB_HOST=localhost
   ```

2. This will use the existing `127.0.0.1/32` entry in pg_hba.conf

## Troubleshooting

### Still getting connection errors?

1. **Check PostgreSQL is listening on the network interface:**
   - Edit `postgresql.conf` (in same directory as pg_hba.conf)
   - Set: `listen_addresses = '*'` or `listen_addresses = '192.168.0.110'`
   - Restart PostgreSQL service

2. **Check Windows Firewall:**
   - Allow port 5432 for PostgreSQL

3. **Verify IP address:**
   - Make sure 192.168.0.110 is the correct IP of your backend server
   - Check with: `ipconfig` (Windows) or `ifconfig` (Linux/Mac)

