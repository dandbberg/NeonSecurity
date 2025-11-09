FROM python:3.11-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install build dependencies for psycopg2 and openssl utilities
RUN apk add --no-cache gcc musl-dev postgresql-dev openssl

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Generate self-signed certificate for HTTPS
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /app/server.key \
  -out /app/server.crt \
  -subj "/CN=localhost"

EXPOSE 8443

CMD ["python", "app.py"]

