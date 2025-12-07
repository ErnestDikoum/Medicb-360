#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for database..."
sleep 3

echo "Running migrations..."
php artisan migrate --force || true

exec "$@"
