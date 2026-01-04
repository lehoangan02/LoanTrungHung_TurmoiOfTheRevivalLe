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
Connect the components to the Raspberry Pi GPIO header. This setup ensures no conflicts between the devices using your specific pin requirements.



### ST7789 (TFT Display)
| ST7789 Pin | Raspberry Pi Pin | GPIO Number | Function |
| :--- | :--- | :--- | :--- |
| **VCC** | Pin 1 or 17 | 3.3V | Power |
| **GND** | Pin 6, 9, etc. | GND | Ground |
| **SCL / SCK** | Pin 23 | GPIO 11 | SPI0 SCLK |
| **SDA / MOSI** | Pin 19 | GPIO 10 | SPI0 MOSI |
| **RES / RST** | Pin 22 | GPIO 25 | Reset |
| **DC** | Pin 18 | GPIO 24 | Data/Command |
| **CS** | Pin 24 | GPIO 8 | SPI0 CE0 |
| **BLK** | Pin 16 | GPIO 23 | Backlight (can leave floating or 3.3V) |

### KY-040 (Rotary Encoder)
| KY-040 Pin | Raspberry Pi Pin | Function |
| :--- | :--- | :--- |
| **GND** | GND (Physical Pin 6, 9, etc.) | Ground |
| **+ (VCC)** | 3.3V (Physical Pin 1 or 17) | Power |
| **SW** | GPIO 22 (Physical Pin 15) | Button Switch |
| **DT** | GPIO 18 (Physical Pin 12) | Direction Signal |
| **CLK** | GPIO 17 (Physical Pin 11) | Clock Signal |

### VL53L0X (Distance Sensor)
| VL53L0X Pin | Raspberry Pi Pin | Pin Number (Physical) | Function |
| :--- | :--- | :--- | :--- |
| **VCC / VIN** | 3.3V | Pin 1 | Power |
| **GND** | GND | Pin 6 | Ground |
| **SDA** | GPIO 2 | Pin 3 | Data (I2C) |
| **SCL** | GPIO 3 | Pin 5 | Clock (I2C) |

---

## 3. Software & Libraries
You will need Python libraries to drive these components and `lua-socket` for UDP communication.

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

# Install UDP support for Lua
sudo apt install lua-socket