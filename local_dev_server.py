#!/usr/bin/env python3
"""
Minimal local development server for testing modularized frontend.
Proxies API requests to Railway production backend.
Run with: python3 local_dev_server.py
"""
import json
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

RAILWAY_API = "https://what-is-my-delta-site-production.up.railway.app"
PORT = 3000

class DevProxyHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/config':
            self.send_config()
        elif self.path.startswith('/wimd/') or self.path.startswith('/auth/'):
            self.proxy_to_railway()
        else:
            # Serve static files from mosaic_ui/
            self.directory = os.path.join(os.getcwd(), 'mosaic_ui')
            super().do_GET()

    def do_POST(self):
        if self.path.startswith('/wimd/') or self.path.startswith('/auth/'):
            self.proxy_to_railway()
        else:
            self.send_error(404)

    def send_config(self):
        """Send config pointing to this local server"""
        config = {
            "apiBase": f"http://localhost:{PORT}",
            "schemaVersion": "v1"
        }
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(config).encode())

    def proxy_to_railway(self):
        """Proxy request to Railway backend"""
        try:
            # Read request body for POST
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length) if content_length > 0 else None

            # Build Railway URL
            url = f"{RAILWAY_API}{self.path}"

            # Forward headers
            headers = {
                'Content-Type': self.headers.get('Content-Type', 'application/json'),
                'X-Session-ID': self.headers.get('X-Session-ID', '')
            }

            # Make request to Railway
            req = Request(url, data=body, headers=headers, method=self.command)
            response = urlopen(req, timeout=30)

            # Send response back
            self.send_response(response.status)
            for key, value in response.headers.items():
                if key.lower() not in ['transfer-encoding', 'connection']:
                    self.send_header(key, value)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(response.read())

        except HTTPError as e:
            self.send_response(e.code)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(e.read())
        except URLError as e:
            self.send_error(503, f"Backend unavailable: {e}")
        except Exception as e:
            self.send_error(500, f"Proxy error: {e}")

    def do_OPTIONS(self):
        """Handle CORS preflight"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, X-Session-ID')
        self.end_headers()

if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    server = HTTPServer(('localhost', PORT), DevProxyHandler)
    print(f"🚀 Local dev server running on http://localhost:{PORT}")
    print(f"📡 Proxying API requests to {RAILWAY_API}")
    print(f"📁 Serving static files from mosaic_ui/")
    print(f"\n✅ Open http://localhost:{PORT} in your browser")
    server.serve_forever()
