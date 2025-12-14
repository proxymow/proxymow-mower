from math import degrees, radians
from time import ticks_ms, sleep
import machine
from machine import Timer, ADC
import json
import schematic as scm
import utils
import artic
from schematic import dev_type

x_m = y_m = theta_rad = 0
min_adc = 1024

# control functions
def stop():
    # Emergency Stop
    cutter(0, -1)
    abort()
    utils.log('Emergency Stop Activated!')
def abort():
    # Abort Movement
    for pwm in scm.pwms: # deactivate all
        artic.set_duty(pwm, 0)
def sweep(left_speed, right_speed, duration):
    return artic.sweep(left_speed, right_speed, duration)
def readadcs():
    analogs = []
    if scm.adc_enabled:
        if scm.dev_type == 'esp8266':
            analogs.append(scm.adcs[0].read())
            analogs.append(min_adc)
        else:
            for i in range(len(scm.adcs)):
                # read_u16 read a raw analog value in the range 0-65535
                analogs.append(scm.adcs[i].read_u16() // 64)
    else:
        analogs = []
    return analogs
def get_telemetry():
    # update telemetry values
    global min_adc
    cut1_val = cut2_val = -1
    if scm.i2c_enabled:
        try:
            byte_state = scm.i2c.readfrom_mem(scm.i2c_reg, scm.RELAY_STATE_REG, 1)
            state = int.from_bytes(byte_state, 'big')
            utils.log('read relay state: {}'.format(state))
            cut1_val = state & 1
            cut2_val = (state & 2) // 2
        except Exception as e:
            utils.log('Error reading i2c in get telemetry: ' + str(e))
    anlgs = readadcs()
    if dev_type != 'rp2':
        if len(anlgs) > 0 and anlgs[0] > 512:
            min_adc = min(anlgs[0], min_adc)
            anlgs[1] = min_adc
    utils.telem['analogs'] = anlgs
    utils.telem['cutter1'] = cut1_val
    utils.telem['cutter2'] = cut2_val
    utils.telem['last-update'] = ticks_ms()
    utils.telem['reset-cause'] = str(machine.reset_cause())
    # refresh dynamic comms values
    rssi = utils.get_rssi()
    dist = utils.get_ap_dist(rssi)
    utils.telem['rssi'] = rssi
    utils.telem['dist'] = dist
    result = json.dumps(utils.telem)
    return result
def get_pose():
    # assemble pose string in degrees
    return '{},{},{}'.format(x_m, y_m, degrees(theta_rad))
def set_pose(xm_in, ym_in, thetadeg_in, axle_track_m=None, tyre_velocity_mps=None):
    global x_m, y_m, theta_rad
    # update pose
    if axle_track_m is not None:
        scm.axle_track_m = axle_track_m
    if tyre_velocity_mps is not None:
        scm.tyre_velocity_mps = tyre_velocity_mps
    x_m, y_m, theta_rad = xm_in, ym_in, radians(thetadeg_in)
    utils.log('setting pose: {:.0f}@({:.2f}, {:.2f})'.format(degrees(theta_rad), x_m, y_m))
    return 0
def set_priority_essid(essid=None):
    # set the preferred access point in utils
    if any([essid.startswith(ps) for ps in utils.PREFERRED_ESSIDS]):
        utils.PRIORITY_ESSID = essid
        utils.log('set_priority_essid: ' + essid)
        utils.checks()
        return 0
    else:
        utils.log('set_priority_essid error unrecognised essid: ' + essid)
        return -1
def cutter(addr_in, mode):
    '''
        addr may be a binary address (mode -1)
        or a channel index (modes 0 & 1) 
    '''
    result = -1
    if scm.i2c_enabled:
        utils.log('Cutter addr:{} mode:{} intmode:{} type:{}'.format(addr_in, mode, int(mode), type(mode)))
        cutter_state_bytes = scm.i2c.readfrom_mem(scm.i2c_reg, scm.RELAY_STATE_REG, 2)
        cur_state = int.from_bytes(cutter_state_bytes, 'big') // 256
        addr = int(addr_in)
        mask = 2**addr
        if mode > 0.5:
            # independent channel set mode
            utils.log('Cutter {} ON'.format(addr + 1))
            addr = cur_state | mask
        elif mode >= 0.0:
            # independent channel clear mode
            utils.log('Cutter {} OFF'.format(addr + 1))
            addr = cur_state & ~mask
        addr_byte_array = (addr, 0) # (address, timer)
        addr_bytes = bytes(addr_byte_array)
        try:
            utils.log('Cutter address bytes {} Writing...'.format(addr_bytes))    
            scm.i2c.writeto_mem(scm.i2c_reg, scm.RELAY_STATE_REG, addr_bytes)
            result = 3
        except Exception:
            utils.log('Cutter address {} Write Failed'.format(addr))
            result = 0
        # pause to allow settling
        sleep(2.5)
    return result
def cancel(_t=None):
    # switch off led - active low
    scm.out_pins['act_led'].value(True)    
def led(duration=200):
    # switch on led
    scm.out_pins['act_led'].value(False)  
    scm.tt_dur_timer.init(period=int(duration), mode=Timer.ONE_SHOT,callback=lambda t:cancel(t))
def reset():
    utils.log('Resetting in 5 seconds...')
    stop()
    sleep(5)
    machine.reset()