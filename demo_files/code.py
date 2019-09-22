import time, sys
for i in range(20):
    time.sleep(.2)
    print(i)
    print("errors", file=sys.stderr)
    sys.stdout.flush()
    sys.stderr.flush()

raise "asd"