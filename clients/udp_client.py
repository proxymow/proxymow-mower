import socket
import time

HOST = '127.0.0.1'  # The device's hostname or IP address
PORT = 5005         # The UDP port used by the device

print('e.g. >get_telemetry() or sweep(100, 100, 1000) for sweep(left[%], right[%], duration[ms]')

def despatch(cmd):
    start = time.time()
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.settimeout(1)
        success = False
        while not success:
            try:
                # must append \r\n so file-like server socket stream reader can read as a line!
                s.sendto(bytes(cmd + '\r\n', 'utf8'), (HOST, PORT))
                data, _addr = s.recvfrom(1024)
                if data:
                    response = str(data, 'utf8')
                    elapsed = round(time.time() - start, 3)
                    success = True
                    print('{0} => {1} processed in {2} seconds {3}'.format(cmd, response, elapsed, success))
                else:
                    print('No data in response')
            except socket.timeout as err:
                msg = 'mower comms timeout: ' + str(err)
                print(msg)
            except socket.error as err:
                msg = 'mower socket error: ' + str(err)
                print(msg)
            except Exception as err:
                msg = 'mower error: ' + str(err)
                print(msg)

keep_going = True
while keep_going:
    cmdline = input('Enter your cmd: ')
    if cmdline != '':
        print('despatching:', cmdline)
        despatch(cmdline)
    else:
        keep_going = False