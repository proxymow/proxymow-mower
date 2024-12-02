import schematic
import micropython

# enable emergency exception buffer for exceptions in isrs
micropython.alloc_emergency_exception_buf(100)

# then finally
import mower