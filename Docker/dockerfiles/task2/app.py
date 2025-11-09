import http.server
import ssl

server_address = ("0.0.0.0", 8443)
handler = http.server.SimpleHTTPRequestHandler
handler.directory = "/"
httpd = http.server.HTTPServer(server_address, handler)
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile="/server.crt", keyfile="/server.key")
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
print("Serving on https://0.0.0.0:8443")
httpd.serve_forever()
EOF