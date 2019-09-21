[head|tail] = [1, 2, 3]
head = 1
tail = [2, 3]

[head|tail] = [1]
head = 1
tail = []

[] = []

# This does not match, no value for head
[head|tail] = []

# match head value
[1 | tail ]= [1, 2, 3]
tail = [2, 3]

# use underscore to ignore a variable
[head | _ ]= [1, 2, 3]
