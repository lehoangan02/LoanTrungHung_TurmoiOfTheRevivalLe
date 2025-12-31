import time
import digitalio
import board
from PIL import Image
from adafruit_rgb_display import st7789

try:
    import cv2
    OPENCV_AVAILABLE = True
except ImportError:
    OPENCV_AVAILABLE = False
    print("Warning: 'opencv-python' not found. display_video() will not work.")

class ST7789Screen:
    def __init__(self, rotation=270, baudrate=64000000):
        self.width = 240
        self.height = 240
        self.rotation = rotation

        self.cs_pin = digitalio.DigitalInOut(board.D8)
        self.dc_pin = digitalio.DigitalInOut(board.D24)
        self.reset_pin = digitalio.DigitalInOut(board.D25)
        self.spi = board.SPI()

        self.disp = st7789.ST7789(
            self.spi,
            cs=self.cs_pin,
            dc=self.dc_pin,
            rst=self.reset_pin,
            baudrate=baudrate,
            width=self.width,
            height=self.height,
            x_offset=0,
            y_offset=80,
            rotation=self.rotation
        )

        self.backlight = None
        try:
            self.backlight = digitalio.DigitalInOut(board.D23)
            self.backlight.switch_to_output(value=True)
        except Exception:
            pass

    def display_video(self, video_path, loop=False):
        if not OPENCV_AVAILABLE:
            return

        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            return

        frame_count = 0
        fps_timer = time.time()

        try:
            while True:
                ret, frame = cap.read()

                if not ret:
                    if loop:
                        cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
                        continue
                    break

                frame = cv2.resize(frame, (self.width, self.height))
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                image = Image.fromarray(frame)
                self.disp.image(image)

                frame_count += 1
                now = time.time()
                if now - fps_timer >= 1.0:
                    fps = frame_count / (now - fps_timer)
                    print(f"FPS: {fps:.2f}")
                    fps_timer = now
                    frame_count = 0

        except KeyboardInterrupt:
            pass
        finally:
            cap.release()

    def clear(self):
        self.disp.image(Image.new("RGB", (self.width, self.height), (0, 0, 0)))

    def turn_on_backlight(self):
        if self.backlight:
            self.backlight.value = True

    def turn_off_backlight(self):
        if self.backlight:
            self.backlight.value = False

    def close(self):
        self.clear()
        self.turn_off_backlight()
