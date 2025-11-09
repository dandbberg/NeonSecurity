FROM alpine:latest

# Install Python and OpenSSL
RUN apk add --no-cache python3 py3-openssl openssl curl

# Create HTTPS content
RUN echo "Im ready to serve you my Master" > /index.html

COPY app.py /app.py

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /server.key \
  -out /server.crt \
  -subj "/CN=localhost"

EXPOSE 8443

WORKDIR /
# Start server
CMD ["python3", "/app.py"]