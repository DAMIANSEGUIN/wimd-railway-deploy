#!/usr/bin/env python3
"""
Lightweight message broker for AI-to-AI communication
Runs a local HTTP server that agents can POST/GET messages from
"""

import json
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime
from pathlib import Path

MESSAGES_FILE = Path(".ai-agents/broker_messages.json")
MESSAGES_FILE.parent.mkdir(exist_ok=True)

# In-memory message queue
messages = []
message_lock = threading.Lock()

def load_messages():
    """Load persisted messages on startup"""
    global messages
    if MESSAGES_FILE.exists():
        with open(MESSAGES_FILE) as f:
            messages = json.load(f)

def save_messages():
    """Persist messages to disk"""
    with open(MESSAGES_FILE, 'w') as f:
        json.dump(messages, f, indent=2)

class AgentBrokerHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        """Custom logging"""
        print(f"[{datetime.now().strftime('%H:%M:%S')}] {format % args}")

    def do_GET(self):
        """Get messages for an agent"""
        if self.path.startswith('/messages/'):
            agent_name = self.path.split('/')[2]

            with message_lock:
                # Get messages for this agent
                agent_messages = [m for m in messages if m['to_agent'] == agent_name and m['status'] == 'PENDING']

            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(agent_messages, indent=2).encode())

        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'status': 'ok', 'messages': len(messages)}).encode())

        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        """Post a new message or mark message as read"""

        if self.path.startswith('/messages/') and '/ack' in self.path:
            # Mark message as read (no body required)
            msg_id = self.path.split('/')[2]

            with message_lock:
                for msg in messages:
                    if msg['id'] == msg_id:
                        msg['status'] = 'READ'
                        save_messages()
                        print(f"✓ Message {msg_id} marked as read")
                        break

            self.send_response(200)
            self.end_headers()
            return

        # For new messages, require Content-Length
        content_length = self.headers.get('Content-Length')
        if not content_length:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b'{"error": "Missing Content-Length header"}')
            return

        content_length = int(content_length)
        post_data = self.rfile.read(content_length)

        if self.path == '/messages':
            # New message
            try:
                message = json.loads(post_data)
                message['timestamp'] = datetime.now().isoformat()
                message['status'] = message.get('status', 'PENDING')
                message['id'] = f"msg_{int(time.time())}_{len(messages)}"

                with message_lock:
                    messages.append(message)
                    save_messages()

                print(f"📨 New message: {message['from_agent']} → {message['to_agent']}")

                self.send_response(201)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'id': message['id'], 'status': 'created'}).encode())

            except Exception as e:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(e)}).encode())

        else:
            self.send_response(404)
            self.end_headers()

    def do_OPTIONS(self):
        """Handle CORS preflight"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

def run_broker(port=8765):
    """Start the message broker server"""
    load_messages()

    server = HTTPServer(('localhost', port), AgentBrokerHandler)
    print(f"""
╔══════════════════════════════════════════════════════════╗
║  AI Agent Message Broker                                  ║
║  Listening on http://localhost:{port}                       ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  Endpoints:                                              ║
║  • GET  /health                   - Check status         ║
║  • GET  /messages/{{agent}}         - Get messages       ║
║  • POST /messages                 - Send message         ║
║  • POST /messages/{{id}}/ack        - Mark as read       ║
║                                                          ║
║  Press Ctrl+C to stop                                    ║
╚══════════════════════════════════════════════════════════╝
    """)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Broker shutting down...")
        save_messages()

if __name__ == '__main__':
    run_broker()
