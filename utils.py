from utime import ticks_ms, ticks_diff, sleep
import os
import network
import ubinascii
LOG_PRINT_ENABLED = True
SWITCH_WIFI_ENABLED = True
SCAN_WIFI_EVEN_IF_CONNECTED = True
SWITCH_WIFI_EVEN_IF_CONNECTED = False
PREFERRED_ESSIDS = ['ProxymowAP']
PRIORITY_ESSID = None # One from above list or None
PREFERRED_PASSWORDS = ['********']
MIN_RSSI_CHANGE = 20 # minimum improvement before switching
RSSI_THRESHOLDS = [0, -30, -67, -70, -80, -90, -999]
RSSI_CATEGORIES = ['Unbelievable', 'Amazing', 'Very Good', 'O.K.', 'Not Good', 'Unusable']
TX_POWER_DBM = 48 # AP Transmit Power
WIFI_DISTANCE_FACTOR = 2
late_telem = '"analogs": {}, "cutter1": {}, "cutter2": {}, "last-update": {}'
early_telem = '{{{{' + late_telem + ',"priority-essid":"{}"'\
            ',"essid":"{}","rssi":{},"dist":{}'\
            ',"free-mb":{},"last-scan":{},"qual-essids":"{}"}}}}'
telem = {}
last_scan = None
qual_essids = None
def do_connect(essid, password):
    sta_if = network.WLAN(network.STA_IF)
    sta_if.active(True)
    log('connecting to network...')
    sta_if.connect(essid, password)
    start = ticks_ms() # get millisecond counter
    delta = 0
    while not sta_if.isconnected() and delta < 10000:
        delta = ticks_diff(ticks_ms(), start) # compute time difference
        sleep(0.5)
    return sta_if.isconnected()
def disconnect():
    sta_if = network.WLAN(network.STA_IF)
    sta_if.active(True)
    log('disconnecting from network...')
    try:
        sta_if.disconnect()
    except:
        log('error disconnecting from network...')
    start = ticks_ms() # get millisecond counter
    delta = 0
    while sta_if.isconnected() and delta < 10000:
        delta = ticks_diff(ticks_ms(), start) # compute time difference
    return sta_if.isconnected()
def checks():
    global telem
    check_wifi()
    # assemble string of telemetry values
    rssi = get_rssi()
    dist = get_ap_dist(rssi)
    telem = early_telem.format(
                '{}','{}','{}','{}',
                PRIORITY_ESSID, 
                get_essid(), rssi, dist, 
                free_space_mb(),
                last_scan, qual_essids)
def scan_aps(cur_essid, cur_rssi, sta_if, trace=False):
    # scan aps and return any that are 'better'
    global last_scan, qual_essids
    last_scan = ticks_ms()
    qual_essid_list = []
    rssi_thresh = cur_rssi + MIN_RSSI_CHANGE
    if trace: log('rssi_thresh: ' + str(rssi_thresh))
    ap_list = sta_if.scan()
    ap_list.sort(key=lambda ap: ap[3], reverse=True) # sort by Signal Strength
    if trace: log(
        '\t{: ^24}{: ^18}{: ^9}{: ^6}{: ^6}{: ^12}{: ^13}{: <8}{: <7}'.format(
            'essid', 'bssid', 'channel', 'RSSI', 'delta', 'Dist', 'Quality', 'Better', 'Qualify')
        )
    if trace: log('=' * 113)
    better_aps = []
    last_better = True
    for ap in ap_list:
        essid = ''.join([c for c in ap[0].decode() if c >= '0'])
        mac = macify(ap[1])
        chan = ap[2]
        rssi = ap[3]
        delta = cur_rssi - rssi 
        cat = rssi_category(rssi)
        dist_m = round(10 ** ((abs(rssi) - TX_POWER_DBM) / 10 * WIFI_DISTANCE_FACTOR), 2)
        is_better = (cur_rssi <= 0  and rssi > rssi_thresh) or cur_rssi > 0
        if last_better != is_better:
            if trace: log('-' * 113)
        last_better = is_better
        try:
            better_index = next(i for i,pssid in enumerate(PREFERRED_ESSIDS) if essid.startswith(pssid))
        except:
            better_index = -1
        qualifies = (better_index >= 0)
        if trace: log(
            '\t{: <24}{: >18}{: >8}{: >7}{: >7}{: 10.2f}\t{: <12}{: <6}{: >6}'.format(
                'Hidden' if essid == '' else essid, mac, chan, rssi, delta, dist_m, cat, is_better, qualifies)
            )
        if qualifies:
            qual_essid_list.extend([essid, str(rssi)])
        if essid != cur_essid and better_index >= 0 and is_better: 
            better_aps.append((better_index, ap))
    return better_aps
def check_wifi():
    sta_if = network.WLAN(network.STA_IF)
    sta_if.active(True)
    cur_essid = sta_if.config('essid')
    connected = sta_if.isconnected()
    cur_rssi = sta_if.status('rssi') if connected else 100
    msg = 'check_wifi current network state - Connected to {}[{}]'.format(cur_essid, cur_rssi) if connected else 'Disconnected!'
    log(msg) 
    log('check_wifi current connection quality: {} = {}'.format(cur_rssi, rssi_category(cur_rssi)))
    if SCAN_WIFI_EVEN_IF_CONNECTED:
        better_aps = scan_aps(cur_essid, cur_rssi, sta_if, True)
        log('aggressive scanning - better aps: {}'.format(better_aps))
    log('check_wifi Checking Exclusive SSID: {} Current: {}'.format(PRIORITY_ESSID, cur_essid))
    if PRIORITY_ESSID is not None:
        if cur_essid != PRIORITY_ESSID or not connected:
            log('check_wifi Switching to Priority SSID: ' + PRIORITY_ESSID)
            pwd_index = next(i for i, pssid in enumerate(PREFERRED_ESSIDS) if PRIORITY_ESSID.startswith(pssid))
            log('check_wifi Priority Password Index: ' + str(pwd_index))
            pref_pwd = PREFERRED_PASSWORDS[pwd_index]
            connected = do_connect(PRIORITY_ESSID, pref_pwd)
            log('check_wifi connected to Priority AP?: ' + str(connected))
            new_essid = sta_if.config('essid')
            new_rssi = sta_if.status('rssi')
            log('check_wifi Priority network essid {} {}'.format(new_essid, new_rssi))
        else:
            log('check_wifi already connected to Priority AP: ' + cur_essid)
    elif not connected or (SWITCH_WIFI_EVEN_IF_CONNECTED and cur_rssi < -80):
        if not SCAN_WIFI_EVEN_IF_CONNECTED:
            better_aps = scan_aps(cur_essid, cur_rssi, sta_if, True)
        if len(better_aps) > 0:
            better_ssid = better_aps[0][1][0].decode()
            better_pwd = PREFERRED_PASSWORDS[better_aps[0][0]]
            if SWITCH_WIFI_ENABLED:
                log('Connecting to better AP {}...'.format(better_ssid)) 
                connected = do_connect(better_ssid, better_pwd)
                log('connected to new network?: ' + str(connected))
                new_essid = sta_if.config('essid')
                new_rssi = sta_if.status('rssi')
                log('new network essid {} {}'.format(new_essid, new_rssi))
            else:
                log('Better Signals Available but SWITCH_WIFI Disabled')
        else:
            log('no stronger signals - sticking with {}'.format(cur_essid))
def get_essid():
    sta_if = network.WLAN(network.STA_IF)
    essid = sta_if.config('essid')
    return essid
def get_rssi():
    sta_if = network.WLAN(network.STA_IF)
    rssi = sta_if.status('rssi')    
    return rssi
def get_ap_dist(rssi):
    dist_m = round(10 ** ((abs(rssi) - TX_POWER_DBM) / 10 * WIFI_DISTANCE_FACTOR), 2)
    return dist_m
def macify(mac_bytes):
    return ubinascii.hexlify(mac_bytes,':').decode().upper()
def rssi_category(rssi):
    try:
        rssi_index = next(i for i in range(len(RSSI_THRESHOLDS) - 1) if RSSI_THRESHOLDS[i] >= rssi >= RSSI_THRESHOLDS[i + 1])
        cat = RSSI_CATEGORIES[rssi_index]
    except:
        cat = RSSI_CATEGORIES[-1]
    return cat
def log(msg):
    if LOG_PRINT_ENABLED:
        print(msg)
def df():
    s = os.statvfs('//')
    return ('{} MB'.format((s[0]*s[3])/1048576))
def free_space_mb():
    free_space_h = df()
    free_mb = float(free_space_h.split()[0])
    return free_mb
