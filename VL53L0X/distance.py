import time
import board
import busio
import adafruit_vl53l0x

# Initialize I2C bus and sensor
i2c = busio.I2C(board.SCL, board.SDA)
vl53 = adafruit_vl53l0x.VL53L0X(i2c)

print("VL53L0X Distance Meter")
print("Press Ctrl+C to quit")

while True:
    try:
        # The sensor returns distance in millimeters
        print("Distance: {} mm".format(vl53.range))
        time.sleep(0.5)
    except RuntimeError:
        # Sometimes the sensor times out, just retry
        pass
