import smbus
import time

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

while True:
    angle = read_angle()
    md, ml, mh = read_status()
    status_str = ""
    if ml:
        status_str = " ⚠️  MAGNET TOO WEAK"
    elif mh:
        status_str = " ⚠️  MAGNET TOO STRONG"
    elif not md:
        status_str = " ❌ NO MAGNET DETECTED"
    
    print(f"{angle:.2f}°{status_str}")
    time.sleep(0.1)
