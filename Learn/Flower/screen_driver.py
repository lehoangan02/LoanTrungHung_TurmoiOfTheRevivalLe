import time
import digitalio
import board
from PIL import Image, ImageDraw
from adafruit_rgb_display import st7789

# Try importing OpenCV for video; handle failure gracefully if not installed
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
        
        # --- Hardware Setup ---
        self.cs_pin = digitalio.DigitalInOut(board.D8)
        self.dc_pin = digitalio.DigitalInOut(board.D24)
        self.reset_pin = digitalio.DigitalInOut(board.D25)
        self.spi = board.SPI()

        # --- Display Initialization ---
        # Using the specific offsets you requested for your hardware
        self.disp = st7789.ST7789(
            self.spi,
            cs=self.cs_pin,
            dc=self.dc_pin,
            rst=self.reset_pin,
            baudrate=baudrate,
            width=self.width,
            height=self.height,
            x_offset=0,
            y_offset=80,  # Critical fix for your 1.3" display
            rotation=self.rotation
        )

        # --- Backlight Setup ---
        self.backlight = None
        try:
            self.backlight = digitalio.DigitalInOut(board.D23)
            self.backlight.switch_to_output(value=True) # Turn ON by default
        except Exception:
            print("Warning: Could not initialize backlight on D23.")

    def display_image(self, image_path):
        """Loads an image, resizes it, and displays it."""
        try:
            image = Image.open(image_path)
            
            # Handle resizing for different Pillow versions
            try:
                resample_filter = Image.Resampling.LANCZOS
            except AttributeError:
                resample_filter = Image.ANTIALIAS

            # Resize to fit screen
            image = image.resize((self.width, self.height), resample_filter)
            
            # Display
            self.disp.image(image)
            print(f"Displayed image: {image_path}")

        except FileNotFoundError:
            print(f"Error: File {image_path} not found.")
        except Exception as e:
            print(f"Error displaying image: {e}")

    def display_video(self, video_path, loop=False):
        """Plays a video file. Set loop=True to repeat indefinitely."""
        if not OPENCV_AVAILABLE:
            print("Error: OpenCV is not installed. Cannot play video.")
            return

        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            print(f"Error: Could not open video {video_path}")
            return

        print(f"Playing video: {video_path}...")
        
        try:
            while True:
                ret, frame = cap.read()
                
                # Handle end of video
                if not ret:
                    if loop:
                        cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
                        continue
                    else:
                        break

                # Resize and Convert (OpenCV BGR -> RGB)
                frame = cv2.resize(frame, (self.width, self.height))
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                
                # Convert to PIL and Display
                image = Image.fromarray(frame)
                self.disp.image(image)
                
        except KeyboardInterrupt:
            print("Video stopped by user.")
        finally:
            cap.release()

    def clear(self):
        """Fills the screen with black."""
        black_image = Image.new("RGB", (self.width, self.height), (0, 0, 0))
        self.disp.image(black_image)

    def turn_on_backlight(self):
        if self.backlight:
            self.backlight.value = True

    def turn_off_backlight(self):
        if self.backlight:
            self.backlight.value = False
            
    def close(self):
        """Cleans up resources: Clears screen and turns off backlight."""
        print("Closing display resources...")
        self.clear()
        self.turn_off_backlight()