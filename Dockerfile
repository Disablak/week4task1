# ----------- BUILD STAGE -------------
FROM python:3.13.5-slim-bookworm AS builder

WORKDIR /usr/src/app
COPY ./app .

# install libpq-dev for psycopg2-binary from requirements.txt
RUN apt-get update && apt-get install -y libpq-dev gcc

RUN pip install --upgrade pip

# install requirements apps but not copy file
RUN --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    pip install --prefix=/install --requirement /tmp/requirements.txt 

ENV PYTHONPATH="/install/lib/python3.13/site-packages:\$PYTHONPATH"

RUN python manage.py collectstatic --noinput

# ----------- FINAL STAGE -------------
FROM python:3.13.5-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app .
COPY --from=builder /install /usr/local

RUN addgroup --system appuser && adduser --system --ingroup appuser appuser
RUN chown -R appuser:appuser /usr/src/app
USER appuser

EXPOSE 8000
CMD ["gunicorn", "mysite.wsgi:application", "--bind", "0.0.0.0:8000"]