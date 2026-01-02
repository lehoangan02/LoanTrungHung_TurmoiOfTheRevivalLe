import socket

class UdpInputTransport:
    def __init__(self, ip="127.0.0.1", port=5005):
        self.addr = (ip, port)
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def send(self, event: str):
        self.sock.sendto(event.encode(), self.addr)