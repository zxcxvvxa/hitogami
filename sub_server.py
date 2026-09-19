import os
import base64
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler

logging.basicConfig(level=logging.INFO, format='%(asctime)s - [SubServer] - %(message)s')

SNI = "firebaseremoteconfigrealtime.googleapis.com"
PORT = "443"
UUID = "hitogami"
PATH = "%2Fhitogami"

class SubHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/sub':
            # Extract domain from request headers or default to request host
            host_header = self.headers.get('Host', 'hitogami-688095604935.us-central1.run.app')
            server_address = host_header.split(':')[0]

            vless_link = (
                f"vless://{UUID}@{server_address}:{PORT}"
                f"?type=ws&security=tls&sni={SNI}&path={PATH}#VLESS-SingBox"
            )

            encoded_sub = base64.b64encode(vless_link.encode('utf-8')).decode('utf-8')

            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(encoded_sub.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

def run(port=9000):
    server_address = ('127.0.0.1', port)
    httpd = HTTPServer(server_address, SubHandler)
    logging.info(f"Subscription server listening on 127.0.0.1:{port}...")
    httpd.serve_forever()

if __name__ == "__main__":
    run()
