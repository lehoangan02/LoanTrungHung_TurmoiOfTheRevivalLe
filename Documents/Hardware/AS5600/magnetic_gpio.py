import smbus
import time

bus = smbus.SMBus(1)
AS5600_ADDR = 0x36

def read_angle():
    high = bus.read_byte_data(AS5600_ADDR, 0x0E)
    low  = bus.read_byte_data(AS5600_ADDR, 0x0F)
    raw = (high << 8) | low
    return raw * 360.0 / 4096.0

while True:
    print(f"{read_angle():.2f}°")
    time.sleep(0.1)
