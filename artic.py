from time import ticks_ms, ticks_diff
from math import sin, pi
from machine import Timer
import utils as ut
import schematic as scm
from sys import platform # esp32 | rp2
import umotion_lib as uml
from shared_utils import calc_new_pose
MIN_CHUNK_DUR_MS = 20 # 20 milliseconds
last_pose_at_ms = 0 # global pose event

class Profiler():
    '''
        all speeds +/- %
        all durations milliseconds
        all relative times milliseconds
    '''
    def __init__(self,
                 left_pwm,
                 left_tgt_speed, 
                 left_cur_speed, 
                 right_pwm,
                 right_tgt_speed, 
                 right_cur_speed, 
                 duration, 
                 ramp_up_dur, 
                 ramp_down_dur
                 ):
        self.left_pwm = left_pwm
        self.left_tgt_speed = left_tgt_speed
        self.left_cur_speed = left_cur_speed
        self.left_speed_delta = left_tgt_speed - left_cur_speed
        self.right_pwm = right_pwm
        self.right_tgt_speed = right_tgt_speed
        self.right_cur_speed = right_cur_speed
        self.right_speed_delta = right_tgt_speed - right_cur_speed
        self.ramp_down_dur = ramp_down_dur
        self.sustain_dur = duration - ((ramp_up_dur + ramp_down_dur)/2)
        if duration > 0:
            self.total_dur = duration + ((ramp_up_dur + ramp_down_dur)/2)
        else:
            self.total_dur = 0
        self.ramp_up_stop = ramp_up_dur
        self.ramp_down_start = self.total_dur - ramp_down_dur
        self.abs_start_time = ticks_ms()

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
    global last_pose_at_ms
    ut.log('{}%|{}% activating for {}ms'.format(speeds[0], speeds[1], duration))
    scm.act_timer.deinit()
    for pwm in (set(scm.pwms) - set(pwms)): # deactivate others
        set_duty(pwm, 0)
    last_pose_at_ms = ticks_ms() # reset
    # get current directions and speeds
    left_dir = (-1) ** (scm.pwms.index(pwms[0]) % 2)
    right_dir = (-1) ** (scm.pwms.index(pwms[1]) % 2)
    left_cur_speed = get_speed(pwms[0], left_dir)
    right_cur_speed = get_speed(pwms[1], right_dir)
    ut.log('starting at {}%|{}%'.format(left_cur_speed, right_cur_speed))
    # assemble profiler
    profiler = Profiler(
        pwms[0], 
        speeds[0], 
        left_cur_speed, 
        pwms[1], 
        speeds[1], 
        right_cur_speed, 
        duration, 
        scm.RAMP_UP_TIME_MS, 
        scm.RAMP_DOWN_TIME_MS
    )
    scm.act_timer.init(
        period=MIN_CHUNK_DUR_MS,
        mode=Timer.PERIODIC, 
        callback=lambda t:calc_speeds(t, profiler)
    )
def calc_speeds(t, profiler: Profiler, trace=True):
    global last_pose_at_ms
    elapsed_t = ticks_diff(ticks_ms(), profiler.abs_start_time)
    try:
        # determine phase from elapsed time...
        if elapsed_t > profiler.total_dur:
            # finished / \.
            left_speed = 0
            right_speed = 0
            t.deinit()
        elif elapsed_t < profiler.ramp_up_stop:
            # ramp-up /
            cosen = cosenoidal(elapsed_t, profiler.ramp_up_stop)
            left_speed = int(profiler.left_cur_speed + (cosen * profiler.left_speed_delta))
            right_speed = int(profiler.right_cur_speed + (cosen * profiler.right_speed_delta))
        elif elapsed_t > profiler.ramp_down_start:
            # ramp-down \
            cosen = cosenoidal(profiler.total_dur - elapsed_t, profiler.ramp_down_dur)
            left_speed = int(cosen * profiler.left_tgt_speed)
            right_speed = int(cosen * profiler.right_tgt_speed)
        else:
            # sustain ---
            left_speed = profiler.left_tgt_speed
            right_speed = profiler.right_tgt_speed
    except Exception as e:
        ut.log('Error calculating speed from waveform: {}'.format(e))
    lduty = set_duty(profiler.left_pwm, left_speed)
    rduty = set_duty(profiler.right_pwm, right_speed)
    # update virtual location - only reqd for hybrids and virtuals
    if scm.axle_track_m * scm.tyre_velocity_mps != 0:
        pose_dur_ms = ticks_diff(ticks_ms(), last_pose_at_ms)
        uml.x_m, uml.y_m, uml.theta_rad = calc_new_pose(
            uml.x_m, 
            uml.y_m, 
            uml.theta_rad, 
            left_speed, 
            right_speed, 
            pose_dur_ms, 
            scm.axle_track_m, 
            scm.tyre_velocity_mps
        )
        last_pose_at_ms = ticks_ms()
    if trace:
        col_width = 30
        fmt = "{{:>6}} {{:4x}} {{:>4}} {{:>{}}}|{{:<{}}} {{:4x}} {{:<4}}".format(col_width, col_width)
        ut.log(fmt.format(
            elapsed_t, 
            lduty,
            left_speed, 
            "-" * int(abs(left_speed * col_width / 100)), 
            "-" * int(abs(right_speed * col_width / 100)), 
            rduty,
            right_speed)
        )
def get_speed(pwm, dir):
    speed = round(100 * pwm.duty_u16() / scm.MOTOR_PWM_DUTY_16)
    if scm.MOTOR_PWM_INVERT:
        speed = (100 - speed) * dir
    else:
        speed = speed * dir
    return speed
def set_duty(pwm, speed_pc):
    duty = min(int(scm.MOTOR_PWM_DUTY_16 * (abs(speed_pc) / 100)), scm.MOTOR_PWM_DUTY_16)
    pwm_duty = scm.MOTOR_PWM_DUTY_16 - duty if scm.MOTOR_PWM_INVERT else duty
    pwm.duty_u16(pwm_duty)
    return pwm_duty
def cosenoidal(t, t_end):
    return (2*pi*t/t_end-sin(2*pi*t/t_end))/2/pi