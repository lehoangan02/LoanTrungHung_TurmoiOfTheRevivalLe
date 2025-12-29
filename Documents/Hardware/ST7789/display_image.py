import time
import digitalio
import board
from PIL import Image, ImageOps
from adafruit_rgb_display import st7789

# --- Configuration for 1.54" 240x240 Display ---

# Define pins
cs_pin = digitalio.DigitalInOut(board.D8)
dc_pin = digitalio.DigitalInOut(board.D24)
reset_pin = digitalio.DigitalInOut(board.D25)

# Config for SPI
BAUDRATE = 24000000  # 24 MHz
spi = board.SPI()

# Initialize Display
# Note: Some generic displays require rotation=90 or offsets.
# If colors are wrong, try invert=True or False.
disp = st7789.ST7789(
    spi,
    cs=cs_pin,
    dc=dc_pin,
    rst=reset_pin,
    baudrate=BAUDRATE,
    width=240,
    height=240,
    x_offset=0,  # Try 0 or 80 if image is shifted
    y_offset=80,   # Try 0 or 80 if image is shifted
    rotation=90,
)

# Initialize backlight (if connected to D23)
try:
    backlight = digitalio.DigitalInOut(board.D23)
    backlight.switch_to_output()
    backlight.value = True
except:
    pass # Backlight might be hardwired to VCC

# Create blank image for drawing
# Make sure to create an image with the same dimensions as the display
width = disp.width
height = disp.height

# --- Load and Process Image ---

image_path = "image.jpeg"

try:
    print(f"Loading {image_path}...")
    image = Image.open(image_path)

    # Resize the image to fit the screen (240x240)
    # ANTIALIAS is renamed to Resampling.LANCZOS in newer Pillow versions
    try:
        resample_filter = Image.Resampling.LANCZOS
    except AttributeError:
        resample_filter = Image.ANTIALIAS
        
    image = image.resize((width, height), resample_filter)

    # Display the image
    print("Displaying image...")
    disp.image(image)

except FileNotFoundError:
    print(f"Error: Could not find {image_path}. Please check the filename.")

# Keep the script running so the image stays up
while True:
    time.sleep(1)