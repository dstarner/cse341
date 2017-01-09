import fileinput


def compute_average(the_list):
    the_sum = 0
    for op_time in the_list:
        the_sum += op_time
    return round(the_sum / len(the_list), 2)


maxTime = 0  # Max time for an instruction
minTime = 100  # Min time for an instruction
times = []   # All times to compute average at the end

opcodes = {0: "AND", 1: "OR", 2: "ADD", 3: "BAD",
           4: "BEQ", 5: "BAD", 6: "SUB", 7: "SLT"}

operations = [[]]
index = 0

inputs = list(fileinput.input())[1:]

for line in inputs:
    newline = line.replace(" ", "").replace("\n", "").replace("=", "").replace(",", "")
    # Get the time
    break_off_time = newline.split("a")
    time = break_off_time[0]
    # Get a
    break_off_a = break_off_time[1].split("b")
    a = break_off_a[0]
    # Get B
    break_off_b = break_off_a[1].split("OPCode")
    b = break_off_b[0]
    break_off_op = break_off_b[1].split("sum")
    op = break_off_op[0]
    break_off_sum = break_off_op[1].split("zero")
    ans = break_off_sum[0]
    zero = break_off_sum[1]
    # At this point, everything is set

    if time.endswith("00"):  # beginning of operation
        index += 1           # increment the operation
        operations.append([{"time": time, "a": a, "b": b, "op": op, "ans": ans, "zero": zero}])
    else:
        operations[index].append({"time": time, "a": a, "b": b, "op": op, "ans": ans, "zero": zero})

for i, op_list in enumerate(operations):
    time = int(op_list[-1]["time"]) - int(op_list[0]["time"])
    if len(op_list) == 1:
        if i == 0:
            time = int(op_list[0]["time"])
        else:
            time = int(op_list[0]["time"]) - int(operations[i][-1]["time"])

    if time > maxTime:
        maxTime = time
    if time < minTime:
        minTime = time
    times.append(time)

    if opcodes[int(op_list[0]["op"], 2)] == "BEQ":
        print("%s. Computed %s of %s and %s with zero output %s in %s time" %
              (i+1, opcodes[int(op_list[0]["op"], 2)], op_list[0]["a"], op_list[0]["b"], op_list[-1]["zero"], time))
    else:
        print("%s. Computed %s of %s and %s with answer %s in %s time" %
              (i+1, opcodes[int(op_list[0]["op"], 2)], op_list[0]["a"], op_list[0]["b"], op_list[-1]["ans"], time))

print("Max: %s;  Min: %s;  Average: %s" % (maxTime, minTime, compute_average(times)))
