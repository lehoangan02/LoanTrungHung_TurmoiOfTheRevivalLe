import time
import digitalio
import board
from PIL import Image
from adafruit_rgb_display import st7789

# --- Hardware Setup ---
cs_pin = digitalio.DigitalInOut(board.D8)
dc_pin = digitalio.DigitalInOut(board.D24)
reset_pin = digitalio.DigitalInOut(board.D25)
spi = board.SPI()

# --- Display Initialization ---
# Critical: 'y_offset=80' is required to fix the 
# static rainbow bar and aspect ratio on this specific 240x240 module.
disp = st7789.ST7789(
    spi,
    cs=cs_pin,
    dc=dc_pin,
    rst=reset_pin,
    baudrate=24000000,
    width=240,
    height=240,
    x_offset=0,
    y_offset=80, 
    rotation=90
)

# Attempt to turn on backlight (if wired to D23)
try:
    backlight = digitalio.DigitalInOut(board.D23)
    backlight.switch_to_output(value=True)
except Exception:
    pass

# --- Load & Display Image ---
image_path = "image.jpeg"
width = disp.width
height = disp.height

try:
    image = Image.open(image_path)
    
    # Handle resizing for different Pillow versions
    try:
        resample_filter = Image.Resampling.LANCZOS
    except AttributeError:
        resample_filter = Image.ANTIALIAS

    # Resize and display
    image = image.resize((width, height), resample_filter)
    disp.image(image)
    print(f"Displayed {image_path} successfully.")

except FileNotFoundError:
    print(f"Error: Could not find {image_path}")

# Keep script running
while True:
    time.sleep(1)