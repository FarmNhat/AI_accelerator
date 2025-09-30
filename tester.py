def read_matrix(filename):
    with open(filename, "r") as f:
        nums = [int(x) for x in f.read().split()]
    return nums

# đọc ifmap 5x5
ifmap_vals = read_matrix("img.txt")
ifmap = [ifmap_vals[i*5:(i+1)*5] for i in range(5)]

# đọc kernel 3x3
kernel_vals = read_matrix("kernel.txt")
kernel = [kernel_vals[i*3:(i+1)*3] for i in range(3)]

# tính convolution valid -> 3x3
out_size = 5 - 3 + 1
out = [[0 for _ in range(out_size)] for _ in range(out_size)]

for i in range(out_size):
    for j in range(out_size):
        acc = 0
        for ki in range(3):
            for kj in range(3):
                acc += ifmap[i+ki][j+kj] * kernel[ki][kj]
        out[i][j] = acc

# in kết quả
print("Kết quả convolution 3x3:")
for row in out:
    print(" ".join(str(x) for x in row))
