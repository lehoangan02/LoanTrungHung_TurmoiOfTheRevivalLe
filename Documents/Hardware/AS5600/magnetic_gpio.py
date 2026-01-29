import smbus
import time
from collections import deque
import math

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

def unwrap_angle(prev, curr):
    if prev is None:
        return curr
    diff = curr - (prev % 360)
    if diff > 180:
        diff -= 360
    elif diff < -180:
        diff += 360
    return prev + diff

window = deque(maxlen=20)
prev_unwrapped = None

print("AS5600 Diagnostic (Correct Circular Math)")
print("=" * 60)

while True:
    angle = read_angle()
    md, ml, mh = read_status()

    unwrapped = unwrap_angle(prev_unwrapped, angle)
    window.append(unwrapped)

    # delta
    delta = ""
    if prev_unwrapped is not None:
        delta_val = unwrapped - prev_unwrapped
        delta = f" | Δ={delta_val:+6.2f}°"

    # stats
    stats = ""
    if len(window) >= 10:
        mean = sum(window) / len(window)
        variance = sum((x - mean) ** 2 for x in window) / len(window)
        std = math.sqrt(variance)
        rng = max(window) - min(window)
        stats = f" | StdDev={std:5.2f}° Range={rng:5.2f}°"

    status = ""
    if ml:
        status = " ⚠️ WEAK"
    elif mh:
        status = " ⚠️ STRONG"
    elif not md:
        status = " ❌ NO MAG"

    print(f"{angle:7.2f}°{status}{delta}{stats}")

    prev_unwrapped = unwrapped
    time.sleep(0.05)
