# Configuration for ST7789, KY-040, & VL53L0X on Raspberry Pi

To run the **ST7789** (TFT Display), **KY-040** (Rotary Encoder), and **VL53L0X** (Time-of-Flight Distance Sensor) simultaneously on a Raspberry Pi, you need to configure the **SPI**, **I2C**, and **GPIO** interfaces.

## 1. System Configuration (Enable Interfaces)
Before wiring, enable the necessary communication protocols in the Raspberry Pi OS.

1.  Open the terminal and run:
    ```bash
    sudo raspi-config
    ```
2.  Navigate to **Interface Options**.
3.  **Enable SPI** (for the ST7789 display).
4.  **Enable I2C** (for the VL53L0X sensor).
5.  Select **Finish** and **Reboot** your Pi.

---

## 2. Wiring Configuration (Pinout)
Connect the components to the Raspberry Pi GPIO header. This setup ensures no conflicts between the devices.

| Device | Pin Name | RPi Pin # | RPi GPIO Function | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **ST7789** | VCC | 2 or 4 | 5V / 3.3V | Check screen specs (usually 3.3V) |
| *(Display)* | GND | 6 | GND | Ground |
| | SCL / SCK | 23 | GPIO 11 (SPI0 SCLK) | SPI Clock |
| | SDA / MOSI | 19 | GPIO 10 (SPI0 MOSI) | SPI Data |
| | RES / RST | 22 | GPIO 25 | Reset (Configurable) |
| | DC | 18 | GPIO 24 | Data/Command (Configurable) |
| | BLK / BL | -- | -- | (Optional) Backlight control |
| | CS | 24 | GPIO 8 (SPI0 CE0) | Chip Select |
| **VL53L0X** | VIN / VCC | 1 | 3.3V | Voltage Input |
| *(Sensor)* | GND | 9 | GND | Ground |
| | SDA | 3 | GPIO 2 (I2C1 SDA) | I2C Data |
| | SCL | 5 | GPIO 3 (I2C1 SCL) | I2C Clock |
| **KY-040** | VCC / + | 17 | 3.3V | Encoder Power |
| *(Encoder)* | GND | 20 | GND | Ground |
| | DT | 29 | GPIO 5 | Signal A (Configurable) |
| | CLK | 31 | GPIO 6 | Signal B (Configurable) |
| | SW | 33 | GPIO 13 | Button Switch (Optional) |

> **Note:** The ST7789 often comes without a CS pin (meaning it is always selected). If yours has no CS pin, you can skip connecting GPIO 8, but ensure no other SPI device shares the bus.

---

## 3. Software & Libraries
You will need Python libraries to drive these components. The standard is to use **CircuitPython** libraries (via Blinka) for the sensors/display and `RPi.GPIO` or `gpiozero` for the encoder.

**Install the dependencies:**

```bash
# Update system
sudo apt-get update
sudo apt-get install python3-pip

# Install setup tools for SPI/I2C/GPIO
sudo pip3 install --upgrade RPi.GPIO
sudo pip3 install --upgrade adafruit-blinka

# Install Display Library (ST7789)
sudo pip3 install adafruit-circuitpython-st7789

# Install Sensor Library (VL53L0X)
sudo pip3 install adafruit-circuitpython-vl53l0x

# Install Image processing (required for display)
sudo apt-get install python3-pil
sudo pip3 install pillow
```