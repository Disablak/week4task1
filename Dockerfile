# ----------- BUILD STAGE -------------
FROM python:3.13.5-slim-bookworm AS builder

WORKDIR /usr/src/app
COPY ./app .

ENV PYTHONPATH="/install/lib/python3.13/site-packages:\$PYTHONPATH"

RUN apt-get update && \
    apt-get install -y libpq-dev gcc && \
    pip install --upgrade pip && \
    pip install --prefix=/install --requirement requirements.txt && \
    python manage.py collectstatic --noinput

# ----------- FINAL STAGE -------------
FROM python:3.13.5-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app .
COPY --from=builder /install /usr/local

RUN addgroup --system appuser && \
    adduser --system --ingroup appuser appuser && \
    chown -R appuser:appuser /usr/src/app

USER appuser

EXPOSE 8000
CMD ["gunicorn", "mysite.wsgi:application", "--bind", "0.0.0.0:8000"]