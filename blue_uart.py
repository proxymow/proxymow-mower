from machine import Timer
from time import sleep_ms
import ubluetooth
import struct
import socket
from micropython import schedule
from utils import log

class BLE:
    """
    BLE UART helper class.

    Handles:
      - BLE initialization & advertising
      - Connection / disconnection callbacks
      - GATT service registration (Proxymow UART Service)
      - Reading incoming commands and sending notifications
    """
    def __init__(self, name, led_pin, tim1, tim2):
        """
            Initialize the BLE device.
        """
        self.name = name
        self.request = None
        self.flag = False
        self.rx_buffer = bytearray(100)
        self.ble = ubluetooth.BLE()
        self.ble.active(True)
        self.ble.config(mtu=255)

        # LED pin
        self.led = led_pin

        # Two timers for blinking the LED when disconnected
        self.timer1 = tim1
        self.timer2 = tim2

        # Start with disconnected blink pattern
        self.disconnected()

        # Register IRQ callback before registering services
        self.ble.irq(self.ble_irq)

        # Setup Proxymow UART GATT service
        self.register()

        # Begin advertising
        self.advertiser()
        
    def deinit(self):
        # deinitialise
        self.ble.gap_advertise(None)
        self.timer1.deinit()
        self.timer2.deinit()
        self.led(1)
        log("deinit")
        
    def connected(self):
        """
        Called when a central device connects.
        Stops the blink timers so the LED can stay solid.
        """
        self.timer1.deinit()
        self.timer2.deinit()

    def disconnected(self, rate_ms=1000):
        """
        Called when no central is connected.
        Starts two timers to blink the LED:
          - Timer1 sets LED on every second
          - Timer2 clears LED every second, offset by 200ms
        """
        self.timer1.init(period=rate_ms, mode=Timer.PERIODIC,
                         callback=lambda t: self.led(1))
        sleep_ms(200)
        self.timer2.init(period=rate_ms, mode=Timer.PERIODIC,
                         callback=lambda t: self.led(0))

    def restart(self):
        self.disconnected()  # restart blink pattern
        self.advertiser()    # resume advertising

    def ble_irq(self, event, data):
        """
            BLE interrupt request handler.
            IRQ (DO NOT DO REAL WORK HERE)
        """
        if event == 1:
            # _IRQ_CENTRAL_CONNECT: a central has connected
            self.cx, _, _ = data
            log("connection with handle: {}".format(self.cx))
            self.connected()
            self.led(1)  # solid on to indicate connection
        elif event == 2:
            # _IRQ_CENTRAL_DISCONNECT: central has disconnected
            log("disconnection...")
            self.restart()
        elif event == 3:
            # _IRQ_GATTS_WRITE: client has written to RX characteristic
            # Copy data OUT of BLE buffer immediately
            self.rx_buffer = self.ble.gatts_read(self.rx)
            # Schedule safe handler
            schedule(BLE._request, self)
                
    @staticmethod
    def _request(self):
        data = self.rx_buffer
        self.request = data
        self.flag = True
        
    def register(self):
        """
        Register the Nordic UART Service (NUS) with two characteristics:
          - TX (notify) for sending data to central
          - RX (write) for receiving data from central
        """
        # NUS base UUID and characteristic UUIDs
        NUS_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
        TX_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" # Notify
        RX_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" # Write
        
        BLE_NUS = ubluetooth.UUID(NUS_UUID)
        BLE_RX  = (ubluetooth.UUID(RX_UUID), ubluetooth.FLAG_WRITE)
        BLE_TX  = (ubluetooth.UUID(TX_UUID), ubluetooth.FLAG_NOTIFY)

        # Define the service tuple
        BLE_UART  = (BLE_NUS, (BLE_TX, BLE_RX, ))
        SERVICES  = (BLE_UART,)

        # Register GATT services and save characteristic handles
        ((self.tx, self.rx, ),) = self.ble.gatts_register_services(SERVICES)
        self.ble.gatts_set_buffer(self.rx, 255)

    def send(self, data):
        """
            Send a notification on the TX characteristic.
        """
        self.ble.gatts_notify(self.cx, self.tx, data)

    def advertiser(self):
        """
        Start BLE advertising with the given device name.
        Uses a simple connectable advertisement packet every 100ms.
        """
        log("advertising...")
        name_bytes = bytes(self.name, 'utf-8')
        adv_payload = bytearray('\x02\x01\x06', 'utf-8') + bytearray((len(name_bytes) + 1, 0x09)) + name_bytes
        self.ble.gap_advertise(100_000, adv_payload) # microseconds
        