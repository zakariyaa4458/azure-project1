# first stage in multi-stage build
FROM python:3.12-alpine AS builder
RUN apk upgrade --no-cache
RUN apk add --no-cache curl
RUN adduser --disabled-password appuser 
WORKDIR /app
COPY app.py requirements.txt ./
RUN pip install --no-cache-dir --target=/app/packages -r requirements.txt
COPY . .
USER appuser
EXPOSE 3000

# second stage in multi-stage build
FROM python:3.12-alpine
RUN apk upgrade --no-cache
RUN apk add --no-cache curl
RUN adduser --disabled-password appuser
WORKDIR /app
COPY --from=builder /app /app
ENV PYTHONPATH=/app/packages
USER appuser
CMD ["python", "app.py"]