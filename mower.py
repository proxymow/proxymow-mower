import os
import socket
import umotion_lib # needed to allow process to call functions
from umotion_lib import led
from utils import log, checks
from time import sleep
from utime import ticks_ms, ticks_diff, time
import machine as m
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
            log(msg)
        cmd_parts = cmd.split('(')
        if (len(cmd_parts) == 1):
            log('Error in cmd: ' + cmd)
        else:
            instr = cmd_parts[0]
            param_str = cmd_parts[1][:-1]
            params = []
            if param_str != '':
                if ',' not in param_str:
                    if trace:
                        log('Single parameter: ' + param_str)
                    params = [param_str]
                else:
                    if trace:
                        log('Splitting Multiple parameters...')
                    params = [float(x) for x in param_str.split(',')]
            result = getattr(umotion_lib, instr)(*params)
            if trace:
                log('Result: ' + str(result))
    except Exception as e:
        result = str(e)
    return result
    
log('Initialising socket...')
# initialise socket
HOST = '0.0.0.0'   # Standard loopback interface address (localhost)
PORT = 5005        # UDP Port to listen on (non-privileged ports are > 1023)
ACK = 'ACK'
TIMEOUT = 30       # 30 seconds between checks if offline

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind((HOST, PORT))
s.settimeout(TIMEOUT)
log('listening on UDP Port ' + str(PORT))
keep_going = True

timeout_count = 0
checks() # boot checks to get online
        
while keep_going:
    try:
        line, addr = s.recvfrom(1024)
        if line:
            cmd = line.decode("utf-8").strip()
            if cmd[0] == '>':
                # Synchronous Request - process before replying
                cmd = cmd[1:]
                is_pose_cmd = 'pose' in cmd
                if not is_pose_cmd:
                    log('Incoming synchronous request: ' + cmd + ' from: ' + str(addr))
                result = process_cmd(cmd, False)
                if not is_pose_cmd:
                    log('Processed result: ' + str(result))
                response = str(result).encode()
                s.sendto(response, addr)
                if not is_pose_cmd:
                    log('Sent response')
            else:
                # ASynchronous Request - process after replying ack
                log('Incoming asynchronous request: ' + cmd + ' from: ' + str(addr))
                s.sendto(ACK, addr)
                log('Sent acknowledgement')            
                result = process_cmd(cmd, True)
                log('Processed result: ' + str(result))
        else:
            log('Incoming request breaking!')
        led(100)
    except OSError as err:
        msg = 'mower comms timeout - performing checks'
        log(msg)
        timeout_count += 1
        led(500)
        if timeout_count > 3:
            led(10)
            msg = 'mower comms timeout count exceeded - performing reset...'
            log(msg)
            m.reset()
        else:
            checks()
    except Exception as err:
        msg = 'mower error: ' + str(err)
        log(msg)