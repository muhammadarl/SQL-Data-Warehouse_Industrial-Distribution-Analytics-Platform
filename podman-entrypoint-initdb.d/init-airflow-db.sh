#!/bin/bash
set -e

# PostgreSQL Multi-Database Initialization Script
# Automatically creates the Airflow metadata database and Industrial DW database if they do not exist.

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE airflow'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'airflow')\gexec

    SELECT 'CREATE DATABASE industrial_db'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'industrial_db')\gexec

    GRANT ALL PRIVILEGES ON DATABASE airflow TO "$POSTGRES_USER";
    GRANT ALL PRIVILEGES ON DATABASE industrial_db TO "$POSTGRES_USER";
EOSQL
