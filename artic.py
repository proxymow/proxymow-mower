from time import ticks_ms, ticks_add, ticks_diff, sleep
from math import exp, degrees, sin, pi
from machine import Timer, Pin, reset
import utils as ut
import schematic as scm
import umotion_lib as uml
from shared_utils import calc_new_pose
last_chunk_ms = 0 # global chunk tracker
class Profiler():
    def __init__(self, start_speed, stop_speed, duration, ru_time_ms, rd_time_ms):
        self.start = start_speed
        self.stop = stop_speed
        self.ramp_up_duration = ru_time_ms
        self.ramp_down_duration = rd_time_ms
        self.sustain_duration = max(0, duration - (self.ramp_up_duration + self.ramp_down_duration))
        self.total_duration = self.ramp_up_duration + self.sustain_duration + self.ramp_down_duration
        self.ramp_up_stop = self.ramp_up_duration
        self.ramp_down_start = self.total_duration - self.ramp_down_duration
        self.ramp_down_stop = self.total_duration
def sweep(left_speed, right_speed, duration):
    ut.log('sweeping...')
    adj_left_speed = left_speed * scm.left_scale_factor
    adj_right_speed = right_speed * scm.right_scale_factor
    if left_speed > 0 and right_speed > 0:
        # drive forward
        activate(scm.pwms[::2], [adj_left_speed, adj_right_speed], int(duration))
    elif left_speed <= 0 and right_speed <= 0:
        # drive reverse
        activate(scm.pwms[1::2], [adj_left_speed, adj_right_speed], int(duration))
    elif left_speed > 0 and right_speed <= 0:
        # clockwise rotate
        activate(scm.pwms[::3], [adj_left_speed, adj_right_speed], int(duration))
    elif left_speed <= 0 and right_speed > 0:
        # anti-clockwise rotate
        activate(scm.pwms[1:3], [adj_left_speed, adj_right_speed], int(duration))     
    return 4
def activate(pwms, speeds, duration):
    ut.log('{}%|{}% activating for {}ms'.format(speeds[0], speeds[1], duration))
    scm.act_timer.deinit()
    for pwm in (set(scm.pwms) - set(pwms)): # deactivate others
        set_duty(pwm, 0)
    # get current speeds
    if scm.dev_type == 'esp8266':
        left_start = round(100 * pwms[0].duty() / scm.MOTOR_PWM_DUTY_10)
        right_start = round(100 * pwms[1].duty() / scm.MOTOR_PWM_DUTY_10)
    else:
        left_start = round(100 * pwms[0].duty_u16() / scm.MOTOR_PWM_DUTY_16)
        right_start = round(100 * pwms[1].duty_u16() / scm.MOTOR_PWM_DUTY_16)
    # assemble profiles
    left_profiler = Profiler(left_start, speeds[0], duration, scm.RAMP_UP_TIME_MS, scm.RAMP_DOWN_TIME_MS)
    right_profiler = Profiler(right_start, speeds[1], duration, scm.RAMP_UP_TIME_MS, scm.RAMP_DOWN_TIME_MS)
    # calculate ramp durations
    start_time_ms = ticks_ms()
    # reset chunk tracker
    last_chunk_ms = start_time_ms
    ramp_up_stop_ms = max(left_profiler.ramp_up_duration, right_profiler.ramp_up_duration)
    ramp_down_stop_ms = max(left_profiler.total_duration, right_profiler.total_duration)
    # blitz ramp up - blocks
    blitz_speeds(pwms, speeds, ramp_up_stop_ms, start_time_ms, left_profiler, right_profiler)
    # calculate timer period
    sustain_ms = max(1, min(left_profiler.sustain_duration, right_profiler.sustain_duration) - 150) # less fixed overhead, minimum 1ms
    ut.log('Timer period sustain: {}ms'.format(sustain_ms)) 
    scm.act_timer.init(
        period=sustain_ms,
        mode=Timer.ONE_SHOT, 
        callback=lambda t: ramp_down(pwms, speeds, ramp_down_stop_ms, start_time_ms, left_profiler, right_profiler)
    )
    sleep(scm.REPL_SPACE)
def ramp_down(pwms, speeds, stop_time_ms, start_time_ms, left_profiler, right_profiler):
    # blitz ramp down - blocks
    blitz_speeds(pwms, speeds, stop_time_ms, start_time_ms, left_profiler, right_profiler)

def blitz_speeds(pwms, speeds, stop_time_ms, start_time_ms, left_profiler, right_profiler):
    elapsed_ms = 0
    while True:
        elapsed_ms = ticks_diff(ticks_ms(), start_time_ms) 
        calc_speeds(pwms, speeds, start_time_ms, left_profiler, right_profiler)
        if elapsed_ms > stop_time_ms:
            break

def calc_speeds(pwms, speeds, start_time_ms, left_profiler=None, right_profiler=None):
    global last_chunk_ms
    t = elapsed_ms = ticks_diff(ticks_ms(), start_time_ms)
    try:
        left_speed = 0
        right_speed = 0
        # cosenoidal
        left_speed = cosenoid(left_profiler.start, left_profiler.stop, left_profiler.ramp_up_stop, left_profiler.ramp_down_start, left_profiler.ramp_down_stop, t)
        right_speed = cosenoid(right_profiler.start, right_profiler.stop, right_profiler.ramp_up_stop, right_profiler.ramp_down_start, right_profiler.ramp_down_stop, t)
    except Exception as e:
        ut.log('Error calculating speed from waveform: {}'.format(e))
    col_width = 30
    set_duty(pwms[0], left_speed)
    set_duty(pwms[1], right_speed)
    # update virtual location - only reqd for hybrids and virtuals
    if scm.axle_track_m * scm.tyre_velocity_mps != 0:
        uml.x_m, uml.y_m, uml.theta_rad = calc_new_pose(
            uml.x_m, 
            uml.y_m, 
            uml.theta_rad, 
            left_speed, 
            right_speed, 
            elapsed_ms - last_chunk_ms, 
            scm.axle_track_m, 
            scm.tyre_velocity_mps
        )
        last_chunk_ms = elapsed_ms # update global
    fmt = "{{:>6}} {{:>4}} {{:>{}}}|{{:<{}}} {{:<4}}".format(col_width, col_width)
    ut.log(fmt.format(
        t, 
        left_speed, 
        "-" * int(abs(left_speed * col_width / 100)), 
        "-" * int(abs(right_speed * col_width / 100)), 
        right_speed)
    )
def set_duty(pwm, speed_pc):
    if scm.dev_type == 'esp8266':
        duty = min(int(scm.MOTOR_PWM_DUTY_10 * (abs(speed_pc) / 100)), scm.MOTOR_PWM_DUTY_10)
        pwm_duty = scm.MOTOR_PWM_DUTY_10 - duty if scm.MOTOR_PWM_INVERT else duty
        pwm.duty(pwm_duty)
    else:
        duty = min(int(scm.MOTOR_PWM_DUTY_16 * (abs(speed_pc) / 100)), scm.MOTOR_PWM_DUTY_16)
        pwm_duty = scm.MOTOR_PWM_DUTY_16 - duty if scm.MOTOR_PWM_INVERT else duty
        pwm.duty_u16(pwm_duty)
def cosenoidal(t, t_end):
    return (2*pi*t/t_end-sin(2*pi*t/t_end))/2/pi
def cosenoid(y_start, y_stop, x_ramp_up_stop, x_ramp_down_start, x_ramp_down_stop, t):
    y_rampup_delta = y_stop - y_start
    y_rampdown_delta = y_stop # down to zero
    x_rampdown_delta = x_ramp_down_stop - x_ramp_down_start
    if t <= x_ramp_up_stop:
        cosen = cosenoidal(t, x_ramp_up_stop)
        result = y_start + (cosen * y_rampup_delta)
    elif t < x_ramp_down_start:
        result = y_stop
    elif t < x_ramp_down_stop:
        cosen = cosenoidal(t - x_ramp_down_start, x_rampdown_delta)
        inv_cosen = 1 - cosen
        result = inv_cosen * y_rampdown_delta
    else:
        result = 0
    return int(result)