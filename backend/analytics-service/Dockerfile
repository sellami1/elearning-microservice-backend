FROM python:3.11.11-slim-bookworm AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1 \
	PIP_NO_CACHE_DIR=1

WORKDIR /build

COPY requirements.txt ./

RUN pip install --upgrade pip \
	&& pip wheel --wheel-dir /wheels -r requirements.txt

FROM python:3.11.11-slim-bookworm AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1 \
	PIP_NO_CACHE_DIR=1

WORKDIR /app

COPY --from=builder /wheels /wheels

RUN pip install --no-cache-dir --no-index --find-links=/wheels /wheels/* \
	&& rm -rf /wheels

COPY app ./app

RUN addgroup --system appgroup \
	&& adduser --system --ingroup appgroup appuser \
	&& chown -R appuser:appgroup /app

USER appuser

EXPOSE 8003

CMD ["python", "-m", "app.main"]
