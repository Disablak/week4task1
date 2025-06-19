#!/bin/sh
set -x

if [ "$MIGRATE_AND_CREATE_USER_ON_STARTUP" = "True" ]
then
    echo "Applying database migrations..."
    python manage.py migrate

    echo "Creating superuser..."
    python manage.py createsuperuser --noinput

    echo "Starting server..."
fi

exec "$@"