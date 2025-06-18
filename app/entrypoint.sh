#!/bin/sh
set -ex

echo "Applying database migrations..."
python manage.py migrate

echo "Creating superuser..."
python manage.py createsuperuser --noinput

echo "Starting server..."
exec "$@"
