import time
import cv2

from screen_driver import ST7789Screen
from rotary_driver import KY040Encoder


screen = None
cap = None
total_frames = 0

desired_frame = 0
frame_dirty = False


def on_rotate(steps):
    global desired_frame, frame_dirty, total_frames

    if total_frames == 0:
        return

    desired_frame = steps % total_frames
    frame_dirty = True


def main():
    global screen, cap, total_frames, frame_dirty

    screen = ST7789Screen()
    screen.clear()

    video_path = "./Water_lily_opening_bloom_20fps.mp4"
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        raise RuntimeError("Cannot open video")

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    print("Total frames:", total_frames)

    encoder = KY040Encoder(
        clk=17,
        dt=18,
        button_pin=22,
        on_rotate=on_rotate
    )

    cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
    ret, frame = cap.read()
    if ret:
        screen.display_frame(frame)

    try:
        while True:
            if frame_dirty:
                frame_dirty = False

                cap.set(cv2.CAP_PROP_POS_FRAMES, desired_frame)
                ret, frame = cap.read()
                if ret:
                    screen.display_frame(frame)

            time.sleep(0.01)

    except KeyboardInterrupt:
        pass
    finally:
        cap.release()
        screen.close()


if __name__ == "__main__":
    main()
