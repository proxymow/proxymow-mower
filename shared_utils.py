import sys
from math import pi, cos, sin, degrees
def get_turn_circle_from_relative_velocities(x1, y1, t1, v_left, v_right, axle_track_m, ccw_min_vdiff = 1.0e-5, debug=False, logger=None):
    cx = x1
    cy = y1
    turn_radius = 0
    ccw = True
    try:
        if v_left is not None and v_right is not None:
            if v_left == v_right:
                if v_left < 0:
                    v_left += ccw_min_vdiff
                else:
                    v_right -= ccw_min_vdiff
            reverse = v_left <= 0 and v_right <= 0
            v_diff = v_right - v_left
            v_sum = v_right + v_left
            ccw = (v_left < v_right)
            if v_right == 0 and v_left != 0:
                turn_radius = axle_track_m
                offset_turn_radius = axle_track_m / (-2 if ccw ^ reverse else 2)        
            elif v_left == 0 and v_right != 0:
                turn_radius = axle_track_m
                offset_turn_radius = axle_track_m / (2 if ccw ^ reverse else -2)        
            elif v_left * v_right < 0:
                turn_radius = axle_track_m / 2
                offset_turn_radius = 0
            else:
                turn_radius = abs((axle_track_m * v_sum) / (2 * v_diff))
                offset_turn_radius = turn_radius
            dx = cos(t1) * offset_turn_radius
            dy = sin(t1) * offset_turn_radius
            if ccw ^ reverse:
                cx = x1 - dx
                cy = y1 - dy
            else:
                cx = x1 + dx
                cy = y1 + dy
    except  Exception as e:
        msg = 'Error in get_turn_circle_from_relative_velocities: ' + str(e)
        if logger:
            logger.error(msg)
        else:
            print(msg)
    return (cx, cy), turn_radius, ccw
def get_turn_circle_sector_angle(turn_radius, dir_ccw, left_speed, right_speed, duration_s, debug=False, logger=None):
    alpha_rad = 0
    try:
        if turn_radius > 0:
            tyre_travel = abs(max(left_speed, right_speed, key=lambda x: abs(x))) * duration_s  # metres
            turn_circle_circumference = 2 * pi * turn_radius
            sector_portion = tyre_travel / turn_circle_circumference
            alpha_rad = 2 * pi * sector_portion * (1 if dir_ccw else -1)
    except  Exception as e:
        msg = 'Error in get_turn_circle_sector_angle: ' + str(e)
        if logger:
            logger.error(msg)
        else:
            print(msg)
    return alpha_rad
def calc_new_pose(x_0, y_0, theta_0, speed_left_percent, speed_right_percent, duration_ms, axle_track_m, velocity_full_speed_mps, debug=False, logger=None):
    new_x_m = None
    new_y_m = None
    new_t_adj_rad = None
    try:
        duration_s = duration_ms / 1000
        v_left = velocity_full_speed_mps * speed_left_percent / 100  # scale percentage to fraction
        v_right = velocity_full_speed_mps * speed_right_percent / 100
        (cx, cy), turn_radius, ccw = get_turn_circle_from_relative_velocities(x_0, y_0, theta_0, v_left, v_right, axle_track_m)
        alpha_rad = get_turn_circle_sector_angle(turn_radius, ccw, v_left, v_right, duration_s)
        new_x_m, new_y_m = getPointRotatedCounterClockwise(x_0, y_0, alpha_rad, cx, cy)
        new_t_adj_rad = sum_angles(theta_0, alpha_rad)
    except  Exception as e:
        msg = 'Error in calc_new_pose: ' + str(e)
        if logger:
            logger.error(msg)
        else:
            print(msg)
    return new_x_m, new_y_m, round(new_t_adj_rad, 4)
def getPointRotatedCounterClockwise(x, y, t, cx, cy):
    x1_offset = x - cx
    y1_offset = y - cy 
    cos_delta = cos(-t)
    sin_delta = sin(-t)
    delta_x = (x1_offset * cos_delta) + (y1_offset * sin_delta)
    delta_y = (x1_offset * sin_delta) - (y1_offset * cos_delta) 
    new_x = cx + delta_x
    new_y = cy - delta_y
    return new_x, new_y
def sum_angles(t1_rad, t2_rad):
    t_sum = (t1_rad + t2_rad) % (2 * pi)
    if t_sum < 0:
        t_sum += (2 * pi)
    return t_sum