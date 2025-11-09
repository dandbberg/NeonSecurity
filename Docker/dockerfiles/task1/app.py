import http.server
import ssl
import socket

class PodInfoHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        pod_name = socket.gethostname()
        pod_ip = socket.gethostbyname(pod_name)
        response = f"Pod: {pod_name}, IP: {pod_ip}"
        
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(response.encode("utf-8"))

server_address = ("0.0.0.0", 8443)
httpd = http.server.HTTPServer(server_address, PodInfoHandler)
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile="/server.crt", keyfile="/server.key")
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
print("Serving on https://0.0.0.0:8443")
httpd.serve_forever()