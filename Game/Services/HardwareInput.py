from signal import pause
from KY040 import KY040Encoder
from UdpInputTransport import UdpInputTransport

def main():
    transport = UdpInputTransport(port=5005)

    KY040Encoder(
        clk=17,
        dt=18,
        sw=22,
        transport=transport
    )

    print("HardwareInputService running (event-per-rotation)")
    pause()


if __name__ == "__main__":
    main()