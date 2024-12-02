from machine import Pin, I2C, Timer, RTC, PWM, ADC, unique_id
import ubinascii
import network
from utils import log
dev_type = 'esp8266' # default
# name                      board label
i2c_scl = 5     #           GPIO5    D1
i2c_sda = 4     #           GPIO4    D2             
led = 16        #           GPIO16   D0 active low
left_in1 = 0    #           GPIO0    D3
left_in2 = 14   #           GPIO14   D5
right_in1 = 12  #           GPIO12   D6 - boot high
right_in2 = 13  #           GPIO13   D7 - boot high
MOTOR_PWM_FREQ = 1000
MOTOR_PWM_DUTY = 1023
RP2_MOTOR_PWM_DUTY = 65535
MIN_STEP_DUR_MS = 250 # 250
RELAY_STATE_REG = 10
i2c_reg = 0x52 # 0x52(mLink)
axle_track_m = 0 # m
tyre_velocity_mps = 0 # metres per second
# add pin names to in/out lists
out_pin_names = ['left_in1', 'left_in2', 'right_in1', 'right_in2', 'led']
out_pin_numbers = [left_in1, left_in2, right_in1, right_in2, led]
out_pins = {}
in_pin_names = []
in_pin_numbers = []
in_pins = {}
left_scale_factor = right_scale_factor = 1.0
adc_enabled = True
adcs = []
i2c_enabled = True
pwms = []
act_timer = tt_dur_timer = rtc = None
# create timers
act_timer = Timer(-1) # create mSec timer for activate delay
tt_dur_timer = Timer(-1) # create mSec timer for led duration
# create Real Time Clock
rtc = RTC()
# customise h/w interfaces according to unique identifier
uid = ubinascii.hexlify(unique_id()).decode().upper()
nid = uid[:6]
if nid == '6789AB':
    # customise your mower variant here
    mower_name = 'MyMower'
    adc_enabled = False
    i2c_enabled = False
elif nid == '2345CD':
    # pico RP2
    mower_name = 'Pico1'
    dev_type = 'rp2'
else:
    # unidentified mac - use defaults
    log('Unidentified Identifier nid: ' + nid)
    mower_name = 'Unknown'
out_pin_init_state = [False, False, False, False, False]
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
if dev_type == 'rp2':
    pwms = [
        PWM(out_pins["left_in2"], freq=MOTOR_PWM_FREQ, duty_u16=0),
        PWM(out_pins["left_in1"], freq=MOTOR_PWM_FREQ, duty_u16=0),
        PWM(out_pins["right_in2"], freq=MOTOR_PWM_FREQ, duty_u16=0),
        PWM(out_pins["right_in1"], freq=MOTOR_PWM_FREQ, duty_u16=0)
    ]
else:
    pwms = [
        PWM(out_pins["left_in2"], MOTOR_PWM_FREQ, 0),
        PWM(out_pins["left_in1"], MOTOR_PWM_FREQ, 0),
        PWM(out_pins["right_in2"], MOTOR_PWM_FREQ, 0),
        PWM(out_pins["right_in1"], MOTOR_PWM_FREQ, 0)
    ]
log('motor pwms initialised nid:{} Name:{}'.format(nid, mower_name))
# construct an I2C bus
if i2c_enabled:
    if dev_type == 'rp2':
        i2c = I2C(0, scl=Pin(i2c_scl), sda=Pin(i2c_sda), freq=400000)
    else:
        i2c = I2C(scl=Pin(i2c_scl), sda=Pin(i2c_sda), freq=400000)
    log('i2c enabled: {}'.format(i2c.scan()))
# adc
if adc_enabled:
    adcs.append(ADC(0)) # pin GP26 on pico
    if dev_type == 'rp2':
        # channel number in the range 0 - 3 or ADC.CORE_TEMP
        adcs.append(ADC(1)) # pin GP27 on pico
        adcs.append(ADC(2)) # pin GP28 on pico
        adcs.append(ADC(3)) # pin GP29 on pico
        adcs.append(ADC(ADC.CORE_TEMP))
    log('adc(s) initialised')
# disable EPS8266 AP
ap_if = network.WLAN(network.AP_IF)
ap_if.active(False)
log('Schematic for {} Initialised'.format(mower_name))
