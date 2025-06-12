FROM python:3.12.11-slim-bullseye

# Prevents Python from writing pyc files to disk
ENV PYTHONDONTWRITEBYTECODE=1
# Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

ENV DEVELOPMENT_MODE=True

WORKDIR /app

COPY ./app .

# install libpq-dev for psycopg2-binary from requirements.txt
RUN apt-get update && apt-get install -y libpq-dev gcc

RUN pip install --upgrade pip

# install requirements apps but not copy file
RUN --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    pip install --requirement /tmp/requirements.txt

RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]