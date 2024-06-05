import random
import yaml

CORRECT_SEQUENCE = [36, 19, 56, 101, 73]
STANDARD_INCORRECT_SEQUENCE = [255, 255, 255, 255, 255] 





def generate_random_sequence():
    if random.randint(0, 1) == 0:
        while True:
            alter = [random.randint(0, 1) for i in range(5)]
            if sum(alter) == 0:
                continue
            return [CORRECT_SEQUENCE[i] if alter[i] == 0 else STANDARD_INCORRECT_SEQUENCE[i] for i in range(5)]
    else:
        return [random.randint(0, 255) for i in range(5)]

def generate_input(seq, with_asserts=False):
    rv = []
    tmp = [0, seq[0], 1]
    if with_asserts:
        tmp.append([0, 0])
    rv.append(tmp)
    for i in range(1, len(seq)):
        tmp = [0, seq[i], 0]
        if with_asserts:
            tmp.append([0, 0])
        rv.append(tmp)
    return rv


CORRECT_INPUT = generate_input(CORRECT_SEQUENCE, with_asserts=False)
tmp = CORRECT_INPUT
tmp.append([0, 255, 1])
IDEMPOTENT_INPUT1 = tmp
IDEMPOTENT_INPUT2 = [0, 255, 0]

IDEMPOTENT_INPUT_ARRAY = [IDEMPOTENT_INPUT1, IDEMPOTENT_INPUT2]

def random_idempotent_input():
    # create random concatenation of the two idempotent inputs
    rv = []
    len = random.randint(1, 10)
    for i in range(len):
        rv.extend(random.choice(IDEMPOTENT_INPUT_ARRAY))
    return rv
    
def go_to_warning1():
    # concatenate the 3 incorrect sequences
    seq = [generate_input(STANDARD_INCORRECT_SEQUENCE, with_asserts=False)]
    seq.extend(generate_input(STANDARD_INCORRECT_SEQUENCE, with_asserts=False))
    seq.extend(generate_input(STANDARD_INCORRECT_SEQUENCE, with_asserts=False))
    tmp = random_idempotent_input()
    tmp = generate_input(tmp, with_asserts=False)
    # append array [0, 1] to the end of the sequence tmp for each element in tmp
    for i in range(len(tmp)):
        tmp[i].append([0, 1])
    seq.extend(tmp)
    return seq

def go_to_warning2():
    # concatenate the 3 incorrect sequences
    seq = [generate_input(CORRECT_SEQUENCE, with_asserts=False)]
    seq[0][2] = 0
    # pick a number between 0 and 4
    i = random.randint(1, 4)
    seq[i][2] = 1
    tmp = random_idempotent_input()
    tmp = generate_input(tmp, with_asserts=False)
    for i in range(len(tmp)):
        tmp[i].append([0, 1])

    seq.extend(tmp)
    return seq + tmp


def serialize_to_yaml(data, filename):
    with open(filename, 'w') as file:
        yaml.dump(data, file)

def reset():
    return [1, 0, 0]

data = go_to_warning1()
data.extend(reset())
data.extend([go_to_warning2()])
data.extend(reset())
print(data)
serialize_to_yaml(data, 'output.yaml')
