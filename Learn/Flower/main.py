from screen_driver import ScreenDriver

def main():
    screen = ScreenDriver()
    path = "./Water_lily_opening_bloom_20fps.ogv"
    screen.display_video(path, loop=False)
    screen.clear()