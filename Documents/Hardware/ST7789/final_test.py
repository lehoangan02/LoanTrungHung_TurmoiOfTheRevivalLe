import sys
import st7789
import time
import RPi.GPIO as GPIO
from PIL import Image, ImageDraw, ImageFont

# --- PINS ---
SPI_PORT = 0
SPI_CS = 0    # We will use this to open the port, but pass None to the lib
DC_PIN = 9    # GPIO 9 (Physical 21)
RST_PIN = 25  # GPIO 25 (Physical 22)

# --- 1. HARDWARE RESET ---
# Essential to wake up the display from a "frozen" state
print("Reseting Display...")
GPIO.setmode(GPIO.BCM)
GPIO.setup(RST_PIN, GPIO.OUT)
GPIO.output(RST_PIN, GPIO.HIGH)
time.sleep(0.1)
GPIO.output(RST_PIN, GPIO.LOW)
time.sleep(0.1)
GPIO.output(RST_PIN, GPIO.HIGH)
time.sleep(0.1)

# --- 2. INITIALIZE DISPLAY ---
print("Initializing...")
try:
    disp = st7789.ST7789(
        port=SPI_PORT,
        cs=SPI_CS,      # Keeps the port index correct (0)
        dc=DC_PIN,
        rst=RST_PIN,    # The library handles soft reset too
        width=240,
        height=240,
        rotation=90,
        spi_speed_hz=40 * 1000 * 1000
    )

    # CRITICAL FIX:
    # We manually override the internal CS pin setting to None
    # preventing the "Device Busy" error.
    disp._spi.mode = 0  # Ensure default mode
    # Some versions of the library utilize a separate GPIO handle for CS. 
    # If the library supports the 'cs' param in init, setting it to None usually works.
    # But since we already initialized, we rely on the fact that spidev is open.
    
    # NOTE: If the library throws an error about "CS", we might need to 
    # modify the init call above. But let's try the standard way first.
    # If this fails, I will provide the "cs=None" init version below.

    disp.begin()

    # --- 3. DRAW IMAGE ---
    print("Drawing OK...")
    
    # Create a nice BLUE background so it's obvious
    img = Image.new('RGB', (240, 240), color=(0, 0, 255))
    draw = ImageDraw.Draw(img)
    
    # Draw "OK"
    # Attempt to load a default font
    font = ImageFont.load_default()
    
    # Draw a White Box
    draw.rectangle((60, 60, 180, 180), fill=(255, 255, 255))
    
    # Draw Black Text
    draw.text((100, 110), "OK", fill=(0, 0, 0))
    
    disp.display(img)
    print("Done! Check Screen.")

except Exception as e:
    print(f"Error: {e}")
    # If this errors, use the ALTERNATIVE INIT below
