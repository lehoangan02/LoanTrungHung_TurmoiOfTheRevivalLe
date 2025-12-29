import st7789
from PIL import Image

disp = st7789.ST7789(
    port=0,
    cs=0,
    dc=25,
    rst=27,
    backlight=18,
    width=240,
    height=240,
    rotation=0,
    spi_speed_hz=80000000
)

disp.init()

img = Image.open("image.png").convert("RGB")

disp.display(img)
