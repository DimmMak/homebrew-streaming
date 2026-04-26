#!/bin/bash
# captions-server.sh — tiny HTTP server that serves the latest whisper transcript
# as JSON to the OBS browser source (live-captions.html).
#
# OBS browser sources can't read local files (CORS); this is the bridge.
# Reads ~/voice/logs/transcripts.jsonl, returns last line at /latest endpoint,
# serves the HTML at /.

PORT=8765
TRANSCRIPTS="$HOME/voice/logs/transcripts.jsonl"
HTML="$HOME/stream/obs/browser-sources/live-captions.html"

cd "$HOME/stream/obs/browser-sources" || exit 1

python3 - "$PORT" "$TRANSCRIPTS" "$HTML" <<'PYEOF'
import sys, json, os
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = int(sys.argv[1])
TRANSCRIPTS = sys.argv[2]
HTML = sys.argv[3]

class CaptionHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):  # silence access log noise
        pass

    def do_GET(self):
        if self.path == '/latest':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-store')
            self.end_headers()
            try:
                with open(TRANSCRIPTS, 'rb') as f:
                    # Seek to end, walk back to find last line
                    f.seek(0, 2)
                    size = f.tell()
                    chunk = min(size, 4096)
                    f.seek(-chunk, 2)
                    data = f.read().decode('utf-8', errors='ignore')
                    lines = [l for l in data.splitlines() if l.strip()]
                    if lines:
                        last = json.loads(lines[-1])
                        self.wfile.write(json.dumps(last).encode())
                        return
            except (FileNotFoundError, json.JSONDecodeError):
                pass
            self.wfile.write(b'{}')
        else:
            # Serve the HTML
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.send_header('Cache-Control', 'no-store')
            self.end_headers()
            with open(HTML, 'rb') as f:
                self.wfile.write(f.read())

print(f"Captions server listening on http://localhost:{PORT}")
print(f"  Tailing: {TRANSCRIPTS}")
print(f"  HTML:    {HTML}")
print(f"  In OBS:  Add Browser Source, URL = http://localhost:{PORT}")
HTTPServer(('localhost', PORT), CaptionHandler).serve_forever()
PYEOF
