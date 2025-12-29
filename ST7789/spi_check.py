import spidev
import errno

print("Testing SPI0.0 access...")
spi = spidev.SpiDev()
try:
    # Try to open Bus 0, Device 0 (CS0)
    spi.open(0, 0)
    print("SUCCESS: SPI Port opened! The issue is likely the library.")
    spi.close()
except OSError as e:
    if e.errno == errno.EBUSY:
        print("FAILURE: Device Busy. The Kernel is blocking access.")
    else:
        print(f"FAILURE: {e}")
