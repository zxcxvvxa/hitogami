import os
import urllib.request
import base64
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler

logging.basicConfig(level=logging.INFO, format='%(asctime)s - [SubServer] - %(message)s')

# Fixed proxy configurations
SNI = "firebaseremoteconfigrealtime.googleapis.com"
PORT = "443"
UUID = "hitogami"
PATH = "%2Fhitogami"  # URL-encoded /hitogami

def get_server_host():
    """Dynamically determine the host address or .run.app domain."""
    # Check environment variable overrides (common in Cloud Run / K8s)
    env_host = os.environ.get("SERVER_HOST") or os.environ.get("K_SERVICE")
    if env_host:
        if not env_host.endswith(".run.app") and not "." in env_host:
            env_host = f"{env_host}.a.run.app"
        return env_host

    # Query internal Cloud Run metadata service if deployed on GCP
    try:
        req = urllib.request.Request(
            "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity?audience=https://container.googleapis.com",
            headers={"Metadata-Flavor": "Google"}
        )
        with urllib.request.urlopen(req, timeout=1) as response:
            token = response.read().decode('utf-8')
            # Extract domain if present
    except Exception:
        pass

    # Fallback to public IP detection
    try:
        with urllib.request.urlopen("https://api.ipify.org", timeout=2) as response:
            return response.read().decode('utf-8').strip()
    except Exception:
        pass

    return "127.0.0.1"


class SubHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/sub':
            # Auto-detect domain from incoming request header if available
            host_header = self.headers.get('Host')
            if host_header:
                server_address = host_header.split(':')[0]
            else:
                server_address = get_server_host()

            # Construct VLESS Link with TLS and custom SNI
            vless_link = (
                f"vless://{UUID}@{server_address}:{PORT}"
                f"?type=ws&security=tls&sni={SNI}&path={PATH}#VLESS-SingBox"
            )

            # Base64 encode for standard proxy subscription clients
            encoded_sub = base64.b64encode(vless_link.encode('utf-8')).decode('utf-8')

            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(encoded_sub.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

def run(server_class=HTTPServer, handler_class=SubHandler, port=9000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    logging.info(f"Subscription server listening on port {port}...")
    httpd.serve_forever()

if __name__ == "__main__":
    run()
