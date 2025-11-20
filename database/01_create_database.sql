-- ============================================
-- Bill Scanner App - PostgreSQL Database Setup
-- ============================================
-- This script creates the database and all required tables
-- Run this script as a PostgreSQL superuser

-- Create Database
CREATE DATABASE bill_scanner_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Connect to the database
\c bill_scanner_db;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pgcrypto for password hashing
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

COMMENT ON DATABASE bill_scanner_db IS 'Bill Scanner Application Database - Stores users, bills, and related data';

