from gpiozero import RotaryEncoder, Button

class KY040Encoder:
    def __init__(self, clk=17, dt=18, button_pin=22, on_rotate=None, on_press=None):
        self.encoder = RotaryEncoder(a=clk, b=dt, max_steps=0)
        self.button = Button(button_pin)

        self.on_rotate = on_rotate
        self.on_press = on_press

        self.encoder.when_rotated = self._rotated
        self.button.when_pressed = self._pressed

    def _rotated(self):
        if self.on_rotate:
            self.on_rotate(self.encoder.steps)

    def _pressed(self):
        self.encoder.steps = 0
        if self.on_press:
            self.on_press()
