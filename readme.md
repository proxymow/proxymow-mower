# Proxymow Automated Robot Lawn Mower (Mower)
## What the project does
Proxymow is a robotic lawn mower system that uses computer vision to locate and guide the mower. This repository contains the MicroPython source code for the mower device. The sister repository [Proxymow Server](https://github.com/proxymow/proxymow-server) contains the source code for the server.

## Why the project is useful
Proxymow differs from many robotic mowers:
* Does not rely on vulnerable boundary wires
* Does not use GPS or Bollards
* Does not need to be taught a route, supports plug-in mowing patterns
* Employs very low cost technology: Rasperry Pi, NodeMCU

## Getting started
Clone or Download the repo and change directory to the installation folder.

Edit utils.py to set up Wi-Fi access, and schematic.py to *wire up* your mower.

Use Thonny, or rshell to deploy the following MicroPython files to your device:
* main.py
* mower.py
* schematic.py
* utils.py
* shared_utils.py
* artic.py
* umotion_lib.py

Reset the device and use the test client to issue some commands:
```
    cd clients; python udp_client.py 
```

## Getting help
Read the documentation [module information](https://proxymow.co.uk/mower).

## Who maintains and contributes to the project
info@proxymow.co.uk
