import time
import ftd2xx

d = 8
NUM_OF_BITS = 128
NUM_OF_RANDOM = 23
ADDR_CONT = int('2', 16)
ADDR_TEXTI = int('016e', 16)
ADDR_KEY = int('0100', 16)
ADDR_P = int('0120', 16)
ADDR_RND = int('0140', 16)
ADDR_TEXTO = int('0180', 16)
ADDR_MODE = int('000C', 16)
MODE_ENC = int('0000', 16)


# --------------------------------------------------
# Functions

def ftdi_read(chip_serial: ftd2xx.FTD2XX, no_bytes):
    t = time.time()
    # while no_bytes_available < no_bytes:
    no_bytes_available = chip_serial.getQueueStatus()
    while no_bytes_available < no_bytes:
        no_bytes_available = chip_serial.getQueueStatus()
    buf = chip_serial.read(no_bytes)
    return buf


def read(chip_serial, addr):
    hex_addr = hex(addr)[2:]
    hex_addr = '0' * (4 - len(hex_addr)) + hex_addr

    to_write = bytes([0, int(hex_addr[0:2], 16), int(hex_addr[2:4], 16)])
    # print(f'read, to_write, len(to_write): {to_write}  {len(to_write)}')

    chip_serial.write(to_write)
    res = int.from_bytes(ftdi_read(chip_serial, 2), "big")
    # print(res)
    return res


def readBurst(chip_serial, addr, read_len):
    byte_arr = bytes([])
    for i in range(read_len // 2):
        hex_addr = hex(addr + 2 * i)[2:]
        hex_addr = '0' * (4 - len(hex_addr)) + hex_addr
        byte_arr = byte_arr + bytes([0, int(hex_addr[0:2], 16), int(hex_addr[2:4], 16)])
    chip_serial.write(byte_arr)

    # print("Read Burst, byte arr, len(byte_arr): ", byte_arr, len(byte_arr))
    return ftdi_read(chip_serial, read_len)


def write(chip_serial, addr, data):
    hex_addr = hex(addr)[2:]
    hex_data = hex(data)[2:]
    hex_addr = '0' * (4 - len(hex_addr)) + hex_addr
    hex_data = '0' * (4 - len(hex_data)) + hex_data
    byte_arr = bytes(
        [1, int(hex_addr[0:2], 16), int(hex_addr[2:4], 16), int(hex_data[0:2], 16), int(hex_data[2:4], 16)])
    chip_serial.write(byte_arr)
    # print(f'write, byte_arr, len(byte_arr): {byte_arr}  {len(byte_arr)}')


def writeBurst(chip_serial, start_addr, data_arr):
    # byte_arr is 2 times too long
    byte_arr = bytes([])
    for i in range(len(data_arr)):
        hex_addr = hex(start_addr + 2 * i)[2:]
        hex_data = hex(data_arr[i])[2:]
        hex_addr = '0' * (4 - len(hex_addr)) + hex_addr
        hex_data = '0' * (4 - len(hex_data)) + hex_data
        byte_arr = byte_arr + bytes(
            [1, int(hex_addr[0:2], 16), int(hex_addr[2:4], 16), int(hex_data[0:2], 16), int(hex_data[2:4], 16)])

    # print(f'writeBurst, byte_arr, len(byte_arr): {byte_arr}  {len(byte_arr)}')
    chip_serial.write(byte_arr)


def setKey(chip_serial, key):
    writeBurst(chip_serial, ADDR_KEY, key)
    write(chip_serial, ADDR_CONT, 0x0002)
    while read(chip_serial, ADDR_CONT) != 0:
        pass


def setP(chip_serial, P):
    writeBurst(chip_serial, ADDR_P, P)


def writeTextRandom(chip_serial, text, rnd):
    writeBurst(chip_serial, ADDR_TEXTI, text)
    writeBurst(chip_serial, ADDR_RND, rnd)


def writeText(chip_serial, text):
    writeBurst(chip_serial, ADDR_RND, text)


def readText(chip_serial, length):
    return readBurst(chip_serial, ADDR_TEXTO, length)


def execute(chip_serial):
    write(chip_serial, ADDR_CONT, 0x0001)
    while read(chip_serial, ADDR_CONT) != 0:
        pass


def open(chip_serial):
    write(chip_serial, ADDR_CONT, 4)
    write(chip_serial, ADDR_CONT, 0)
    write(chip_serial, ADDR_MODE, MODE_ENC)
