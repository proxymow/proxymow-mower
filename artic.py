from time import ticks_ms, ticks_add, ticks_diff, sleep
from machine import Timer
import schematic as scm
import umotion_lib as uml
import utils as ut
from math import floor, degrees
from shared_utils import calc_new_pose

chunk_index = -1
remaining_ms = -1

def sweep(left_speed, right_speed, duration):
    ut.log('sweeping...')
    adj_left_speed = left_speed * scm.left_scale_factor
    adj_right_speed = right_speed * scm.right_scale_factor
    if left_speed > 0 and right_speed > 0:
        # drive forward
        activate(scm.pwms[::2], [adj_left_speed, adj_right_speed], int(duration), True)
    elif left_speed <= 0 and right_speed <= 0:
        # drive reverse
        activate(scm.pwms[1::2], [adj_left_speed, adj_right_speed], int(duration), True)
    elif left_speed > 0 and right_speed <= 0:
        # clockwise rotate
        activate(scm.pwms[::3], [adj_left_speed, adj_right_speed], int(duration))
    elif left_speed <= 0 and right_speed > 0:
        # anti-clockwise rotate
        activate(scm.pwms[1:3], [adj_left_speed, adj_right_speed], int(duration))     
    return 4 
def activate(pwms, speeds, duration, chunked=False):
    global chunk_index
    ut.log('activating periodic pwms... chunked? ' + str(chunked))
    scm.act_timer.deinit()
    deactivate(scm.pwms) # deactivate all
    chunk_index = -1
    if duration >= 0:
        chunks = max(floor(duration / scm.MIN_STEP_DUR_MS), 1) if chunked else 1
        chunk_dur_ms = duration // chunks
        # note the start details
        ut.log('activating for '+str(duration)+' ms in '+str(chunks)+' chunks of '+str(chunk_dur_ms)+'ms')
        for i, pwm in enumerate(pwms):
            set_duty(pwm, speeds[i], scm.dev_type)
        start_time_ms = ticks_ms()
        finish_time_ms = ticks_add(start_time_ms, duration) # completion
        scm.act_timer.init(
            period=int(chunk_dur_ms), 
            mode=Timer.PERIODIC, 
            callback=lambda t: motivate(t, pwms, speeds, chunks, chunk_dur_ms, finish_time_ms, start_time_ms)
        )
        sleep(scm.REPL_SPACE)
def motivate(t, pwms, speeds, chunks, chunk_dur_ms, finish_time_ms, start_time_ms):
    global chunk_index, remaining_ms
    chunk_index += 1
    remaining_ms = ticks_diff(finish_time_ms, ticks_ms())
    # only reqd for hybrids and virtuals
    if scm.axle_track_m * scm.tyre_velocity_mps != 0:
        ut.log('cur pose: {0:.0f}@({1:.3f}, {2:.3f})'.format(degrees(uml.theta_rad), uml.x_m, uml.y_m))
        uml.x_m, uml.y_m, uml.theta_rad = calc_new_pose(
            uml.x_m, 
            uml.y_m, 
            uml.theta_rad, 
            speeds[0], 
            speeds[1], 
            chunk_dur_ms, 
            scm.axle_track_m, 
            scm.tyre_velocity_mps
        )
        ut.log('new pose: {0:.0f}@({1:.3f}, {2:.3f})'.format(degrees(uml.theta_rad), uml.x_m, uml.y_m))
    if chunk_index < (chunks - 1):
        ut.log('mot chunk: ' + str(chunk_index) + ' remaining_ms ' + str(remaining_ms))
        for i, pwm in enumerate(pwms):
            set_duty(pwm, speeds[i], scm.dev_type)
    else:
        deactivate(pwms)
        t.deinit()
        elapsed_ms = ticks_diff(ticks_ms(), start_time_ms)
        ut.log('de-activated after ' + str(elapsed_ms))
def set_duty(pwm, speed_pc, dev_type):
    if dev_type == 'esp8266':
        duty = min(int(scm.MOTOR_PWM_DUTY_10 * (abs(speed_pc) / 100)), scm.MOTOR_PWM_DUTY_10)
        pwm_duty = scm.MOTOR_PWM_DUTY_10 - duty if scm.MOTOR_PWM_INVERT else duty
        pwm.duty(pwm_duty)
        ut.log('{} {}% set duty {} over {}'.format(dev_type, speed_pc, pwm_duty, scm.MOTOR_PWM_DUTY_10))
    else:
        duty = min(int(scm.MOTOR_PWM_DUTY_16 * (abs(speed_pc) / 100)), scm.MOTOR_PWM_DUTY_16)
        pwm_duty = scm.MOTOR_PWM_DUTY_16 - duty if scm.MOTOR_PWM_INVERT else duty
        pwm.duty_u16(pwm_duty)
        ut.log('{} {}% set duty {} over {}'.format(dev_type, speed_pc, pwm_duty, scm.MOTOR_PWM_DUTY_16))
def deactivate(pwms):
    ut.log('deact')
    for pwm in pwms:
        set_duty(pwm, 0, scm.dev_type)