#----------BUILD STAGE-----------
FROM python:3.13.5-alpine3.22 AS builder

WORKDIR /usr/src/app
COPY ./app .

RUN set -ex \
    && apk add --no-cache --virtual .build-deps curl postgresql-dev build-base \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && /root/.local/bin/uv pip install --system -r requirements.txt \
    && python manage.py collectstatic --noinput \
    && apk del .build-deps

#----------FINAL STAGE-----------
FROM python:3.13.5-alpine3.22

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app .
COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

RUN addgroup --system appuser \
    && adduser --system --ingroup appuser appuser \
    && chown -R appuser:appuser /usr/src/app

USER appuser

EXPOSE 8000
CMD ["gunicorn", "mysite.wsgi:application", "--bind", "0.0.0.0:8000"]