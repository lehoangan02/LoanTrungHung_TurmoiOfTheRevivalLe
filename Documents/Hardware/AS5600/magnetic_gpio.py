import smbus
import time
from collections import deque

bus = smbus.SMBus(1)
AS5600_ADDR = 0x36

def read_angle():
    # Use block read for atomic 2-byte read to avoid mid-update reads
    data = bus.read_i2c_block_data(AS5600_ADDR, 0x0C, 2)  # Read RAW ANGLE (0x0C-0x0D)
    raw = (data[0] << 8) | data[1]
    return raw * 360.0 / 4096.0

def read_status():
    """Check magnet detection status"""
    status = bus.read_byte_data(AS5600_ADDR, 0x0B)
    md = (status >> 5) & 1  # Magnet detected
    ml = (status >> 4) & 1  # Magnet too weak
    mh = (status >> 3) & 1  # Magnet too strong
    return md, ml, mh

# Track statistics
readings = deque(maxlen=20)
prev_angle = None

print("AS5600 Diagnostic - Wobble Detection")
print("=" * 60)

while True:
    angle = read_angle()
    md, ml, mh = read_status()
    
    status_str = ""
    if ml:
        status_str = " ⚠️  WEAK"
    elif mh:
        status_str = " ⚠️  STRONG"
    elif not md:
        status_str = " ❌ NO MAG"
    
    # Calculate delta
    delta = ""
    if prev_angle is not None:
        diff = angle - prev_angle
        # Handle wraparound
        if diff > 180:
            diff -= 360
        elif diff < -180:
            diff += 360
        delta = f" | Δ={diff:+7.2f}°"
    
    readings.append(angle)
    
    # Calculate statistics over last 20 readings
    if len(readings) >= 10:
        avg = sum(readings) / len(readings)
        variance = sum((x - avg) ** 2 for x in readings) / len(readings)
        std_dev = variance ** 0.5
        range_val = max(readings) - min(readings)
        stats = f" | StdDev={std_dev:5.2f}° Range={range_val:6.2f}°"
    else:
        stats = ""
    
    print(f"{angle:7.2f}°{status_str}{delta}{stats}")
    
    prev_angle = angle
    time.sleep(0.05)  # Faster sampling to catch wobble
