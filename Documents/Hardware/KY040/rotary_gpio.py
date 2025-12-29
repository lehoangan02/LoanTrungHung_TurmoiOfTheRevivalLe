from gpiozero import RotaryEncoder, Button
from signal import pause

# Define the pins
# "a" is CLK, "b" is DT
rotor = RotaryEncoder(a=17, b=18, max_steps=0)
button = Button(22)

def rotate():
    print(f"Current Value: {rotor.steps}")

def press():
    print("Button Pressed!")
    rotor.steps = 0  # Reset counter on press

# Attach events
rotor.when_rotated = rotate
button.when_pressed = press

print("Rotate the knob or press the button...")

# Keep the script running
pause()