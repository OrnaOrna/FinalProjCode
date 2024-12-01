import os
import secrets

import numpy as np
from picoscope import (ps5000a)
from scipy.io import savemat
from tqdm import trange

from Protocol_yair_dan import *
from config import *

"""Constants"""
CONNECTION_OK = "[+] The COM port connection has been established successfully."
CONNECTION_KO = "[!!!] ERROR: No available COM port has been selected. get an available COM ports."


def save_traces(data: object, file_name: object, save_method: object) -> object:
    """"Saving the traces to a file, according to definitions on config file"""

    if save_method == "NPY":  # saving in .npy
        np.save(file_name + ".npy", np.array(data), allow_pickle=False)
    elif save_method == "MAT":  # saving in .mat
        savemat(
            file_name + ".mat", data, format="5", do_compression=False, oned_as="row"
        )
    else:
        print("[!] WARNING: workspace and dataset are not saved!")


def assure_path_exists(path):
    if not os.path.exists(path):
        os.makedirs(path)


def number_to_bit_array(number, num_bits=None):
    # Convert the number to binary string and remove the '0b' prefix
    binary_str = bin(number)[2:]

    # If a specific number of bits is required, pad the binary string with leading zeros
    if num_bits is not None:
        binary_str = binary_str.zfill(num_bits)

    # Convert the binary string to a list of integers (0 or 1)
    bit_array = [int(bit) for bit in binary_str]

    return bit_array


def binary_array_to_uint16(binary_array):
    # Convert the binary array to a binary string
    binary_str = ''.join(str(bit) for bit in binary_array)

    # Convert the binary string to an integer with base 2
    number = int(binary_str, 2)

    # Cast the integer to uint16 using NumPy
    uint16_number = np.uint16(number)

    return uint16_number


def measurement_setup(exp_mode_rand, exp_mode_pt, exp_mode_key, plaintext_i, key_i, random_vect_i, i=0) -> bool:
    t_test_bit = secrets.randbits(1)
    if exp_mode_rand == 0:
        random_vect_i[:] = np.zeros((1, 23), dtype=np.uint16)
    else:
        random_vect_i[:] = np.array([secrets.randbits(exp_mode_rand) << (16 - exp_mode_rand) for _ in range(23)], dtype=np.uint16)

    if exp_mode_pt == 0:
        if t_test_bit:
            plaintext_i[:] = np.zeros((1, 8), dtype=np.uint16)
        else:
            plaintext_i[:] = np.array([secrets.randbelow(2 ** 8) << 8 for _ in range(8)], dtype=np.uint16)
    elif exp_mode_pt == 1:
        if t_test_bit:
            plaintext_i[:] = np.full((1, 8), 2 ** 15, dtype=np.uint16)
        else:
            plaintext_i[:] = np.array([secrets.randbelow(2 ** 8) << 8 for _ in range(8)], dtype=np.uint16)

    """rP_arr = np.convolve(np.flip(number_to_bit_array(random_vect_i[7])), np.flip(number_to_bit_array(P))) % 2  # rP
    rP_uint16 = binary_array_to_uint16(rP_arr)
    plaintext_i[0] = (rP_uint16 << (8 - d)) ^ plaintext_i[0]"""

    if exp_mode_key == 0:
        key_i[:] = np.zeros((1, 8), dtype=np.uint16)
    else:
        key_i[:] = np.array([secrets.randbelow(2 ** 16) for _ in range(8)], dtype=np.uint16)

    return bool(t_test_bit)


def none_func(a, b, c):
    pass


def change_rand(i):
    global EXP_MODE_RAND
    EXP_MODE_RAND = i


def perform_measurement(start, number_of_files, num_of_queries, pixel_path, chip_serial,
                        serial_picoscope: ps5000a.PS5000a = None):
    # const_key = np.random.randint(0, 2**16, size=(1, 8), dtype=np.uint16)
    const_key = np.zeros(shape=(1, 8), dtype=np.uint16)
    key = np.tile(const_key, (num_of_queries, 1))
    open(chip_serial=chip_serial)
    #setKey(chip_serial, key[0, :])
    for file_num in trange(start, number_of_files, 1, leave=True, position=1, desc="Batch progress", ):
        """iterating over the number of files and showing a progressing toolbar"""

        # Change 16 here to whatever fits, and also formatting (from np.ndarray to bytearray or smth)
        plaintext = np.zeros((num_of_queries, 8), dtype=np.uint16)
        ciphertext = np.zeros((num_of_queries, 8), dtype=np.uint16)
        random_vect = np.zeros((num_of_queries, 23), dtype=np.uint16)
        poly_and_root_num = 1  # Number between 1-239
        P_root = np.uint16(poly_and_root_num << (16 - np.max(int(np.log2(poly_and_root_num))),0))
        traces = np.zeros((num_of_queries, SAMPLES), dtype=np.int16)
        power_traces = np.zeros((num_of_queries, SAMPLES), dtype=np.int16)
        k_vec = np.zeros((num_of_queries, 8), dtype=np.uint16)
        t_test_bits = np.zeros(num_of_queries, dtype=bool)
        # sendxs = np.zeros((1, num_of_queries, 32), dtype=np.uint8)

        for trace_num in trange(0, num_of_queries, 1, leave=True, position=2, desc="Queries"):
            if PICO_ARMED:
                serial_picoscope.runBlock(0, 0, none_func)

            """iterating over traces per file"""
            # create serial data
            rand_bit = measurement_setup(EXP_MODE_RAND, EXP_MODE_PT, EXP_MODE_KEY, plaintext[trace_num, :], k_vec[trace_num, :], random_vect[trace_num, :],
                                         trace_num)
            t_test_bits[trace_num] = rand_bit

            # print(k_vec[trace_num, :])
            # print(random_vect[trace_num, :])

            # print(plaintext[trace_num, :])
            # s_unflip = np.hstack([plaintext[trace_num, :], key[trace_num, :].T])
            # sendx = s_unflip[::-1]

            if WITH_UART:
                # print(f"  {sendx}    writing")
                setKey(chip_serial, key[trace_num, :])
                setP(chip_serial, P_root)
                writeTextRandom(chip_serial, plaintext[trace_num, :], random_vect[trace_num, :])
                execute(chip_serial)
                f = readText(chip_serial, 16)

                temp = np.frombuffer(f, np.uint8)
                # print(temp)
                # print(f"              {f}       received")
                ciphertext[trace_num, :] = np.frombuffer(f, np.uint16)

                # # # uncomment to debug , prints the received ciphertext
                # if len(f) == 0:
                #     # i -= 1
                #     continue
                # print(f)
                # # ciphertexts[count, i, :] = tmp
                # time.sleep(0.1)

            if PICO_ARMED:
                """collect data from the oscilloscope"""
                serial_picoscope.waitReady()
                serial_picoscope.getDataRaw(channel=POWER_CHANNEL, numSamples=SAMPLES, downSampleRatio=DOWN_SAMPLING, data=power_traces[trace_num, :])

                # (traces[trace_num, :], numSamplesReturned, overflow) = serial_picoscope.getDataRaw(
                #     EM_CHANNEL, SAMPLES, OFFSET, DOWN_SAMPLING, 0, 0)

                # serial_picoscope.getDataRawBulk()
                # (power_traces[trace_num, :], numSamplesReturned, overflow) = serial_picoscope.getDataRaw(
                #     POWER_CHANNEL, SAMPLES, OFFSET, DOWN_SAMPLING, 0, 0)
                # print(power_traces[trace_num, :])

        if PICO_ARMED:
            # saving the data
            trace_mat_path = pixel_path + f"\\traces_{file_num}"
            traces_batch = {
                "plaintext": np.uint16(plaintext),
                "key": np.uint16(key),
                "randomness": np.uint16(random_vect),
                "ciphertext": np.uint16(ciphertext),
                "Queries": NUM_OF_QUERIES,
                "samples": SAMPLES,
                "Sampling_freq": SAMPLING_FREQUENCY,
                "BYTE": BYTE,
                "EXP_MODE": EXP_MODE,
                "FREQ_ENUM": FREQ_ENUM_ARRAY,
            }
            if MEAS_POWER:
                traces_batch["power_traces"] = power_traces
            if T_TEST:
                traces_batch["bit"] = t_test_bits

            save_traces(
                traces_batch,
                trace_mat_path,
                SAVE_METHOD,
            )


def close(chip_serial):
    """Closes serial ports """
    chip_serial.close()
    print("[+]Chip serial PORT Disengaged.")
