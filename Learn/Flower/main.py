from screen_driver import ST7789Screen

def main():
    screen = ST7789Screen()
    path = "./Water_lily_opening_bloom_20fps.ogv"
    screen.display_video(path, loop=False)
    screen.clear()

if __name__ == "__main__":
    main()