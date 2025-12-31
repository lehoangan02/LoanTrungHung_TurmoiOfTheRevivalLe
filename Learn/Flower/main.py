from screen_driver import ST7789Screen
from rotary_driver import KY040Encoder
import cv2

def main():
    global screen
    screen = ST7789Screen()
    video_path = "./Water_lily_opening_bloom_20fps.mp4"
    # load a video
    global cap
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
            raise RuntimeError("Cannot open video")
    global total_frames 
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    print(f"Total frames in video: {total_frames}")

    encoder = KY040Encoder()
    encoder.on_rotate = on_rotate

    screen.clear()

def on_rotate(steps):
    print(f"Rotated to step: {steps}")
    frame_number = steps % total_frames
    print(f"Displaying frame number: {frame_number}/{total_frames}")
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    ret, frame = cap.read()
    if ret:
        screen.display_frame(frame)



if __name__ == "__main__":
    main()