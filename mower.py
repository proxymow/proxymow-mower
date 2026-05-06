from sys import print_exception, platform # esp32 | rp2
import os
import socket
import select
import re
import utils as ut
from time import sleep
from utime import ticks_ms, ticks_diff
import machine as m

import umotion_lib # needed to allow process to call functions
from umotion_lib import led, cutter
import schematic as scm

def process_cmd(multi_cmd, trace=False):
    result = ''
    try:
        cmds = multi_cmd.split('!')
        for cmd in cmds:
            res = process(cmd, trace)
            result += str(res) + '!'
    except Exception as e:
        result = str(e)
    return result.rstrip('!')
        
def process(cmd, trace):
    # determine instruction and make call
    result = 'None'
    try:
        msg = 'Processing: ' + cmd
        if trace:
            ut.log(msg)
        cmd_parts = cmd.split('(')
        if (len(cmd_parts) == 1):
            ut.log('Error in cmd: ' + cmd)
        else:
            instr = cmd_parts[0]
            param_str = cmd_parts[1][:-1]
            params = []
            if param_str != '':
                if ',' not in param_str:
                    if trace:
                        ut.log('Single parameter: ' + param_str)
                    params = [param_str]
                else:
                    if trace:
                        ut.log('Splitting Multiple parameters...')
                    params = [float(x) for x in param_str.split(',')]
            result = getattr(umotion_lib, instr)(*params)
            if trace:
                ut.log('Result: ' + str(result))
    except Exception as e:
        result = str(e)
    return result

try:
    # Create and start BLE UART service
    from blue_uart import BLE
    ut.log('Starting BLE UART...')
    ble = BLE(
        scm.mower_name,
        scm.out_pins['act_led'],
        scm.led_on_timer,
        scm.led_off_timer
    )
except Exception as e:
    ut.log('Problem launching blue uart')
HOST = '0.0.0.0'        # All addresses interface address
PORT = 5005             # UDP Port to listen on (non-privileged ports are > 1023)
ACK = 'ACK'
MAX_POLL_TIMEOUT = 1000 # 1 second
MIN_POLL_TIMEOUT = 100 # 100 msecs
CHECK_MS = 60000 # ms between checks if offline
NUM_CHECKS_RST = 3 # Number of checks before rebooting
last_num_re = re.compile('[,()\s]+')

ut.log('Initialising udp socket...')
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind((HOST, PORT))
pollerObject = select.poll()
pollerObject.register(s, select.POLLIN)
ut.log('listening on UDP Port: ({})'.format(PORT))
keep_going = True
timeout = MAX_POLL_TIMEOUT
num_checks = 0
last_req = ticks_ms()
ut.checks() # boot checks to get online
bt = None
while keep_going:
    try:
        events = pollerObject.poll(timeout)
        line = None
        if len(events) > 0:
            bt = False
            timeout = MAX_POLL_TIMEOUT
            event = events[0]
            line, addr = s.recvfrom(64)
        elif ble.flag:
            line = ble.request
            ble.flag = False
            bt = True
            timeout = MIN_POLL_TIMEOUT
        if bt is True:
            ut.telem['essid'] = 'bluetooth'
            ut.telem['rssi'] = -50
        elif bt is False:
            rssi = ut.get_rssi()
            ut.telem['rssi'] = rssi
            essid = ut.get_essid()
            ut.telem['essid'] = essid
        if line:
            last_req = ticks_ms()
            num_checks = 0
            led(100)
            cmd = line.decode("utf-8").strip()
            if cmd[0] == '>':
                # Synchronous Request - process before replying
                cmd = cmd[1:]
                is_pose_cmd = 'pose' in cmd
                if not is_pose_cmd:
                    ut.log('Synchronous {} request: {}'.format(
                        'bluetooth' if bt else 'network', cmd))
                result = process_cmd(cmd, False)
                if not is_pose_cmd:
                    ut.log('Processed result: ' + str(result))
                response = str(result).encode()
                if bt:
                    try:
                        ble.send(response)
                    except:
                        ut.log('ble response failed')    
                else:
                    s.sendto(response, addr)
                if not is_pose_cmd:
                    ut.log('Sent response')
            else:
                # Asynchronous Request - process after replying ack
                ut.log('Asynchronous {} request: {}'.format(
                    'bluetooth' if bt else 'network', cmd))
                resp = last_num_re.split(cmd)
                response = ACK + '#' + resp[-2:][0]
                if bt:
                    ble.send(response)
                else:
                    s.sendto(response, addr)
                ut.log('Sent acknowledgement')            
                result = process_cmd(cmd, True)
                ut.log('Processed result: ' + str(result))
        else:
            # no incoming request
            timeout = int((timeout + MAX_POLL_TIMEOUT) / 2)
        if ticks_diff(ticks_ms(), last_req) > CHECK_MS:
            num_checks += 1
            if num_checks >= NUM_CHECKS_RST:
                ut.log('no contact - performing reset...')
                # disable cutters to reduce emi
                cutter(0, -1)
                sleep(5)
                m.reset()
            ut.log('no contact - performing checks {}'.format(num_checks))
            sleep(5)
            ut.checks()
            last_req = ticks_ms()
    except Exception as err:
        msg = 'mower error: ' + str(err)
        ut.log(msg)
        raise(err)