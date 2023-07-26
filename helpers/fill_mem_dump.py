# quando arquivos de dump de memória tem menos de 256 linhass, dá problema no modelsim
file_name = input("Enter path and file name from current dir: \n\tExample: ./rars/prime/mem_dump.txt\n")

with open(file_name, 'r+') as f:
    content = f.readlines()
    n = len(content)
    # write to file with "00000000" until line 256
    for i in range(n, 256):
        f.write("00000000\n")
