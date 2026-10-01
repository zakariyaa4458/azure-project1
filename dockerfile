# first stage in multi-stage build
FROM python:3.12-slim AS builder
RUN add user --disabled-password appuser
WORKDIR /app
COPY flask_app.py requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
USER appuser

# second stage in multi-stage build
FROM python:3.12-slim
RUN add user --disabled-password appuser
WORKDIR /app
COPY --from=builder /app /app
USER appuser
CMD ["python", "flask_app.py"]