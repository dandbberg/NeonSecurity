#!/usr/bin/env python3
import http.server
import json
import os
import ssl
import sys
from typing import Iterable

import psycopg2
from psycopg2.extras import RealDictCursor


def get_env(name: str, default: str | None = None) -> str:
    value = os.environ.get(name, default)
    if value is None:
        raise RuntimeError(f"Environment variable '{name}' is required")
    return value


def get_connection() -> psycopg2.extensions.connection:
    return psycopg2.connect(
        host=get_env("POSTGRES_HOST"),
        port=get_env("POSTGRES_PORT", "5432"),
        dbname=get_env("POSTGRES_DB"),
        user=get_env("POSTGRES_USER"),
        password=get_env("POSTGRES_PASSWORD"),
        sslmode=os.environ.get("POSTGRES_SSLMODE", "require"),
    )


def ensure_table(cur: psycopg2.extensions.cursor) -> None:
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS NeonSecurityTask_messages (
            id SERIAL PRIMARY KEY,
            message TEXT NOT NULL,
            created_at TIMESTAMPTZ DEFAULT NOW()
        );
        """
    )


def insert_message(cur: psycopg2.extensions.cursor) -> dict[str, str]:
    cur.execute(
        "INSERT INTO NeonSecurityTask_messages (message) VALUES (%s) RETURNING id, created_at;",
        (os.environ.get("NEONSECURITYTASK_MESSAGE", "Fallback message"),),
    )
    inserted = cur.fetchone()
    print(
        f"Inserted message id={inserted['id']} at {inserted['created_at']:%Y-%m-%d %H:%M:%S%z}",
        flush=True,
    )
    return inserted


def fetch_messages(cur: psycopg2.extensions.cursor, limit: int = 10) -> list[dict[str, str]]:
    cur.execute(
        "SELECT id, message, created_at FROM NeonSecurityTask_messages ORDER BY id DESC LIMIT %s;",
        (limit,),
    )
    rows = cur.fetchall()
    return rows


def render_html(messages: Iterable[dict[str, str]]) -> bytes:
    messages_list = list(messages)
    items = "\n".join(
        f"<li><strong>#{row['id']}</strong> {row['message']} "
        f"<em>@ {row['created_at']:%Y-%m-%d %H:%M:%S%z}</em></li>"
        for row in messages_list
    )
    last_access = (
        f"Your last acccess is logged! @ {messages_list[0]['created_at']:%Y-%m-%d %H:%M:%S%z}"
        if messages_list
        else "Your last acccess is logged!"
    )
    html = f"""<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>NeonSecurityTask</title>
    <style>
      body {{ font-family: sans-serif; margin: 2rem; background: #0d0d16; color: #f0f0ff; }}
      h1 {{ color: #7f5af0; }}
      em {{ color: #94a1b2; font-size: 0.9rem; }}
    </style>
  </head>
  <body>
    <h1>NeonSecurity: I'M READY TO SERVER YOU MY MASTER! :-)</h1>
    <ul>
      {items}
    </ul>
    <p>{last_access}</p>
  </body>
</html>"""
    return html.encode("utf-8")


class NeonSecurityTaskHandler(http.server.BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(self) -> None:  # noqa: N802
        try:
            path = self.path.split("?", 1)[0]
            if path == "/healthz":
                self._respond(200, b"ok", "text/plain")
                return

            with get_connection() as conn:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    ensure_table(cur)

                    # Insert on each hit except for /messages
                    if path not in {"/messages"}:
                        insert_message(cur)

                    rows = fetch_messages(cur, limit=20)

            if path == "/messages":
                payload = json.dumps(rows, default=str).encode("utf-8")
                self._respond(200, payload, "application/json")
            else:
                payload = render_html(rows)
                self._respond(200, payload, "text/html; charset=utf-8")
        except Exception as exc:  # noqa: BLE001
            print(f"ERROR handling request: {exc}", file=sys.stderr, flush=True)
            self._respond(500, b"internal error", "text/plain")

    def log_message(self, fmt: str, *args: object) -> None:  # noqa: D401
        """Suppress default logging (already using stdout prints)."""
        print(f"[HTTP] {self.address_string()} {self.command} {self.path} -> {fmt % args}", flush=True)

    def _respond(self, status: int, payload: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


def main() -> None:
    port = int(os.environ.get("PORT", "8443"))
    cert_file = os.environ.get("TLS_CERT_FILE", "/app/server.crt")
    key_file = os.environ.get("TLS_KEY_FILE", "/app/server.key")

    server_address = ("0.0.0.0", port)
    httpd = http.server.HTTPServer(server_address, NeonSecurityTaskHandler)

    if os.path.exists(cert_file) and os.path.exists(key_file):
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain(certfile=cert_file, keyfile=key_file)
        httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
        scheme = "https"
    else:
        print("WARNING: TLS certificates not found, serving over HTTP", file=sys.stderr)
        scheme = "http"

    print(f"Serving on {scheme}://0.0.0.0:{port}", flush=True)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down...", flush=True)
    finally:
        httpd.server_close()


if __name__ == "__main__":
    main()