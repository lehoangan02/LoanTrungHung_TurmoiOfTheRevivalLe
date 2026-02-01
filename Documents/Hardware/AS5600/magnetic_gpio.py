import smbus
import time

bus = smbus.SMBus(1)
AS5600_ADDR = 0x36

def read_angle():
    data = bus.read_i2c_block_data(AS5600_ADDR, 0x0C, 2)
    raw = (data[0] << 8) | data[1]
    return raw * 360.0 / 4096.0

def read_status():
    status = bus.read_byte_data(AS5600_ADDR, 0x0B)
    md = (status >> 5) & 1
    ml = (status >> 4) & 1
    mh = (status >> 3) & 1
    return md, ml, mh

while True:
    angle = read_angle()
    md, ml, mh = read_status()

    signal = ""
    if ml:
        signal = "WEAK"
    elif mh:
        signal = "STRONG"
    elif not md:
        signal = "NO MAG"
    else:
        signal = "OK"

    print(f"{angle:7.2f}° {signal}")

    time.sleep(0.05)
