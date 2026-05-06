from machine import Pin, I2C, Timer, RTC, PWM, ADC, unique_id, reset_cause
import ubinascii
import network
from utils import log
from umotion_lib import led
from time import sleep
from sys import platform # esp32 | rp2
mower_name = 'Unnamed'
# name                      board label
i2c_scl = 5     #           GPIO5    D1
i2c_sda = 4     #           GPIO4    D2             
act_led = 16    #           GPIO16   D0 active low
left_in1 = 0    #           GPIO0    D3
left_in2 = 14   #           GPIO14   D5
right_in1 = 12  #           GPIO12   D6 - boot high
right_in2 = 13  #           GPIO13   D7 - boot high
MOTOR_PWM_FREQ = 2000
MOTOR_PWM_DUTY_10 = 1023
MOTOR_PWM_DUTY_16 = 65535
MOTOR_PWM_INVERT = False
RAMP_UP_TIME_MS = 300
RAMP_DOWN_TIME_MS = 0
RELAY_STATE_REG = 10
i2c_reg = 0x52 # mLink
axle_track_m = 0 # m
tyre_velocity_mps = 0 # metres per second
# add pin names to in/out lists
out_pin_names = ['left_in1', 'left_in2', 'right_in1', 'right_in2', 'act_led']
out_pins = {}
in_pin_names = []
in_pin_numbers = []
in_pins = {}
left_scale_factor = right_scale_factor = 1.0
adc_enabled = True
adcs = []
i2c_enabled = True
pwms = []

# customise h/w interfaces according to unique identifier
uid = ubinascii.hexlify(unique_id()).decode().upper()
if uid == '6789ABCD':
    # customise your mower variant here
    mower_name = 'MyMower'
    adc_enabled = False
    i2c_enabled = False
elif uid == 'E661380123456789':
    # pico RP2
    mower_name = 'Pico1'
elif uid == '6789ABCDEFGH':
    # esp32
    mower_name = 'ESP32A'
    left_in1 = 16 # esp32 gpio0 => gpio16
    left_in2 = 17 # esp32 gpio14 => gpio17
    right_in1 = 18 # esp32 gpio12 => gpio18
    right_in2 = 19 # esp32 gpio13 => gpio19
    act_led = 14 # esp32 gpio16 => gpio14
else:
    # unidentified id - use defaults
    log('Unidentified Identifier uid: ' + uid)
out_pin_init_state = [MOTOR_PWM_INVERT] * 4 + [False]
out_pin_numbers = [left_in1, left_in2, right_in1, right_in2, act_led]
# make all out pins outputs
pin_count = len(out_pin_names)
for i in range(pin_count):
    name = out_pin_names[i]
    num = out_pin_numbers[i]
    val = out_pin_init_state[i]
    pin = Pin(num, Pin.OUT)
    out_pins[name] = pin
    pin.value(val)
log(str(pin_count) + ' out pins initialised')
# make all in pins inputs
pin_count = len(in_pin_names)
for i in range(pin_count):
    name = in_pin_names[i]
    num = in_pin_numbers[i]
    pin = Pin(num, Pin.IN, Pin.PULL_UP)
    in_pins[name] = pin
log(str(pin_count) + ' in pins initialised')
# create timers
if platform == 'esp32':
    act_timer = Timer(1) # create mSec timer for activate delay
    led_on_timer = Timer(2) # create mSec timer for led on
    led_off_timer = Timer(3) # create mSec timer for led off
else:
    act_timer = Timer(-1)
    led_on_timer = Timer(-1)
    led_off_timer = Timer(-1)
stop_duty = MOTOR_PWM_DUTY_16 if MOTOR_PWM_INVERT else 0
pwms = [
    PWM(out_pins["left_in2"], freq=MOTOR_PWM_FREQ, duty_u16=stop_duty),
    PWM(out_pins["left_in1"], freq=MOTOR_PWM_FREQ, duty_u16=stop_duty),
    PWM(out_pins["right_in2"], freq=MOTOR_PWM_FREQ, duty_u16=stop_duty),
    PWM(out_pins["right_in1"], freq=MOTOR_PWM_FREQ, duty_u16=stop_duty)
]
for pwm in pwms: # ensure stopped
    if abs(pwm.duty_u16() - stop_duty) > 10:
        log('motor pwm {} failed to initialise 16bit duty to {} - resetting duty'.format(pwm, stop_duty))
        pwm.duty_u16(stop_duty)
log('motor pwms initialised uid:{} Name:{} pwms:{}'.format(uid, mower_name, pwms))
# construct an I2C bus
if i2c_enabled:
    i2c = I2C(0, scl=Pin(i2c_scl), sda=Pin(i2c_sda), freq=500000)
    log('i2c enabled: {}'.format(i2c.scan()))
# adc
if adc_enabled:
    if platform == 'rp2':
        # channel number in the range 0 - 3 or ADC.CORE_TEMP
        # pin GP26..GP29 on pico
        chans = [0, 1, 2, 3, ADC.CORE_TEMP]
    elif platform == 'esp32':
        # pin number in the range 32 - 39
        chans = [36, 39, 34, 35, 32, 33]
    for chan in chans:
        adc = ADC(chan)
        if platform == 'esp32': adc.atten(ADC.ATTN_11DB) # 3.3V range
        adcs.append(adc)
    log('{} adc(s) initialised'.format(len(chans)))
for _ in range(4):
    led(400);sleep(1);led(100);sleep(1)
log('Schematic for {} {} Initialised'.format(mower_name, platform))