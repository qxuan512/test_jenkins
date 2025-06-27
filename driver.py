import os
from http.server import HTTPServer, BaseHTTPRequestHandler
import json


class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    value = "0"

    def do_GET(self):
        if self.path == "/value":
            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(self.value.encode())
        elif self.path == "/status":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            status = {"server": "running", "current_value": self.value}
            self.wfile.write(json.dumps(status).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == "/push":
            content_length = int(self.headers["Content-Length"])
            post_data = self.rfile.read(content_length).decode()
            if post_data in ["0", "1"]:
                self.__class__.value = post_data
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"Value set successfully")
            else:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b"Invalid value. Must be '0' or '1'")
        else:
            self.send_response(404)
            self.end_headers()


def run_server():
    port = int(os.environ.get("DEVICE_PORT", 11111))
    server_address = ("", port)
    httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)
    print(f"Server running on port {port}")
    httpd.serve_forever()


if __name__ == "__main__":
    run_server()
