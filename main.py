import sys
import machine as m
import micropython
import schematic

# enable emergency exception buffer for exceptions in isrs
micropython.alloc_emergency_exception_buf(100)

try:
    # load mower
    print('launching mower')
    import mower
except Exception as err:
    msg = 'error launching mower: ' + str(err)
    print(msg)
    # Open the file in 'append' mode to keep previous error logs
    with open("error_log.txt", "a") as f:
        f.write("\n--- main Error ---\n")
        sys.print_exception(err, f)
    m.reset()
