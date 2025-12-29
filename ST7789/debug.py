import sys
import st7789
import time
import RPi.GPIO as GPIO
from PIL import Image, ImageDraw

# --- CONFIGURATION ---
SPI_PORT = 0
SPI_CS = 0    # CE0 (GPIO 8 / Pin 24)
DC_PIN = 9    # GPIO 9 (Pin 21)
RST_PIN = 25  # GPIO 25 (Pin 22)

# --- 1. FORCE HARD RESET ---
# This manually toggles the reset pin to ensure the display controller wakes up
GPIO.setmode(GPIO.BCM)
GPIO.setup(RST_PIN, GPIO.OUT)
GPIO.output(RST_PIN, GPIO.HIGH)
time.sleep(0.1)
GPIO.output(RST_PIN, GPIO.LOW)
time.sleep(0.1)
GPIO.output(RST_PIN, GPIO.HIGH)
time.sleep(0.1)
print("Hardware Reset Complete.")

# --- 2. INITIALIZE DISPLAY ---
try:
    print("Initializing ST7789...")
    disp = st7789.ST7789(
        port=SPI_PORT,
        cs=SPI_CS,
        dc=DC_PIN,
        rst=RST_PIN,
        width=240,
        height=240,
        rotation=90,
        # Lower speed to 10MHz to rule out bad wiring quality
        spi_speed_hz=10 * 1000 * 1000
    )

    disp.begin()

    # --- 3. DRAW VISUAL TEST ---
    # We draw a BLUE background with a WHITE 'X'
    # This is high contrast and easy to see
    print("Drawing Test Pattern...")
    img = Image.new('RGB', (240, 240), color=(0, 0, 255)) # Blue
    draw = ImageDraw.Draw(img)
    
    # Draw a big X
    draw.line((0, 0, 240, 240), fill=(255, 255, 255), width=5)
    draw.line((0, 240, 240, 0), fill=(255, 255, 255), width=5)
    
    disp.display(img)
    print("Done. Check screen.")

except Exception as e:
    print(f"Error: {e}")
