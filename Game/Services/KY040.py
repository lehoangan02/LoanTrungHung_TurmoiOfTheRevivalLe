from gpiozero import RotaryEncoder, Button
from UdpInputTransport import UdpInputTransport

class KY040Encoder:
    def __init__(self, transport: UdpInputTransport, clk=17, dt=18, sw=22):
        self.encoder = RotaryEncoder(a=clk, b=dt, max_steps=0, bounce_time=0.0005)
        self.button = Button(sw)
        self.transport = transport

        self.encoder.when_rotated_clockwise = self._on_right
        self.encoder.when_rotated_counter_clockwise = self._on_left
        self.button.when_pressed = self._on_press

    def _on_left(self):
        self.transport.send("ENCODER_LEFT")
        print("Left")

    def _on_right(self):
        self.transport.send("ENCODER_RIGHT")
        print("Right")

    def _on_press(self):
        self.transport.send("ENCODER_BUTTON")
        print("Button Pressed")