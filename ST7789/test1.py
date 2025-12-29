import sys
import ST7789
from PIL import Image, ImageDraw, ImageFont

# --- Configuration ---
# specific display settings (check your display's resolution)
WIDTH = 240
HEIGHT = 240

# GPIO Pins (BCM numbering) matching the wiring table above
SPI_PORT = 0
SPI_CS = 0    # CE0 (GPIO 8)
DC_PIN = 9
RST_PIN = 25

print("Initializing Display...")

# Create the display instance
disp = ST7789.ST7789(
    port=SPI_PORT,
    cs=SPI_CS,
    dc=DC_PIN,
    rst=RST_PIN,
    width=WIDTH,
    height=HEIGHT,
    rotation=90,      # Rotate 90 degrees if needed (0, 90, 180, 270)
    spi_speed_hz=80 * 1000 * 1000
)

# Initialize display
disp.begin()

# Create a blank image (RGB mode) with the screen dimensions
image = Image.new("RGB", (WIDTH, HEIGHT), (0, 0, 0)) # (0,0,0) is black background
draw = ImageDraw.Draw(image)

# --- Draw Text ---
text_to_display = "OK"

# Load a font. 
# We try to load a nice Truetype font, failing that we load the default simple font.
try:
    # This path is standard on Raspberry Pi OS
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 60)
except IOError:
    print("Default font not found, using simple generic font.")
    font = ImageFont.load_default()

# Calculate text position to center it
# getbbox returns (left, top, right, bottom)
left, top, right, bottom = font.getbbox(text_to_display)
text_width = right - left
text_height = bottom - top

x_pos = (WIDTH - text_width) // 2
y_pos = (HEIGHT - text_height) // 2

# Draw the text: (x, y), "Text", fill=(R, G, B), font object
draw.text((x_pos, y_pos), text_to_display, fill=(255, 255, 255), font=font)

# --- Display Image ---
print("Displaying Image...")
disp.display(image)

print("Done!")
