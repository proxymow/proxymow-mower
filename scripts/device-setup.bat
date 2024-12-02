REM erase flash
echo 'Erasing...'
esptool --chip esp8266 erase_flash
REM write interpreter
echo 'Writing MicroPython...'
cd %~dp0
esptool --chip esp8266 write_flash --flash_size=detect 0 ESP8266_GENERIC-20241025-v1.24.0.bin
echo 'Try CTRL-X to quit rshell...'
REM copy Proxymow files
cd %~dp0..\
rshell -p COM3 -b 115200 cp shared_utils.py /pyboard
rshell -p COM3 -b 115200 cp utils.py /pyboard
rshell -p COM3 -b 115200 cp schematic.py /pyboard
rshell -p COM3 -b 115200 cp artic.py /pyboard
rshell -p COM3 -b 115200 cp umotion_lib.py /pyboard
rshell -p COM3 -b 115200 cp mower.py /pyboard
rshell -p COM3 -b 115200 cp main.py /pyboard
rshell -p COM3 -b 115200 ls /pyboard
REM Enable Station Interface and Connect to base Wi-Fi
REM rshell -d -p COM3 -b 115200 repl ~ import network ~ sta_if=network.WLAN(network.STA_IF) ~ sta_if.active(True) ~ sta_if.connect('SSID', 'password') ~
REM Enable Web REPL - Interactive!
rshell -d -p COM3 -b 115200 repl ~ import webrepl_setup
pause