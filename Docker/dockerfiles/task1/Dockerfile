FROM alpine:latest

RUN apk add --no-cache python3 py3-openssl openssl curl

COPY app.py /app.py

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /server.key \
  -out /server.crt \
  -subj "/CN=localhost"

EXPOSE 8443

CMD ["python3", "/app.py"]