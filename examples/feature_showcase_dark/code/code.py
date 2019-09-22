import time, sys

def sleep_printer(n):
    for i in range(n):
        print(i)
        time.sleep(.2)
        sys.stdout.flush()

sleep_printer(20)