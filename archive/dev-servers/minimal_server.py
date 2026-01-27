import http.server
import socketserver

PORT = 3000
Handler = http.server.SimpleHTTPRequestHandler

try:
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print("--- Minimal server serving at port", PORT)
        httpd.serve_forever()
except Exception as e:
    print("--- MINIMAL SERVER FAILED TO START ---")
    print(e)
