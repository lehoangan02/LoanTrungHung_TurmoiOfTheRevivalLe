import digitalio
import board
from PIL import Image
from adafruit_rgb_display import st7789

# --- Setup Pins ---
cs_pin = digitalio.DigitalInOut(board.D8)
dc_pin = digitalio.DigitalInOut(board.D24)
reset_pin = digitalio.DigitalInOut(board.D25)
spi = board.SPI()

# --- Initialize Display ---
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

# --- Turn Off Backlight ---
# If your BLK pin is connected to GPIO 23, this cuts the light.
try:
    backlight = digitalio.DigitalInOut(board.D23)
    backlight.switch_to_output()
    backlight.value = False  # OFF
    print("Backlight turned off.")
except Exception:
    print("Could not control backlight (Check wiring on Pin 23).")

# --- clear Screen (Draw Black) ---
# We create a purely black image and send it to the screen.
print("Clearing screen...")
black_image = Image.new("RGB", (disp.width, disp.height), (0, 0, 0))
disp.image(black_image)

print("Screen is now off (sleeping).")