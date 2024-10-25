"""Module scans a grid of pixels and measures traces above each pixels"""

"""Whether to use Daniel's implementation (for riscure, etc) or Yair & Dan's implementation (w. GLM)"""
YAIR_DAN = True

import sys
from time import *
from Motor import *
from datetime import datetime
import serial
import ftd2xx
from picoscope import (ps5000a)

if YAIR_DAN:
    from Utils_yair_dan import *
else:
    from Util_functions import *
from config import *

# Temporary, remove after succot
for i in range(0, 1):
    #change_rand(i)
    if YAIR_DAN:
        CHIP_SERIAL = ftd2xx.open(0)
        if PICO_ARMED:
            picoscope_serial = ps5000a.PS5000a()

            # Setting the resolution
            # picoscope_serial.resolution = BIT_RESOLUTION

            # Setting channel B (power channel)
            # picoscope_serial.setChannel(EM_CHANNEL, EM_CH_COUPLING, EM_CH_RANGE, EM_CH_OFFSET, EM_CH_ENABLED
            #                             , False, 1)
            picoscope_serial.setChannel(channel=POWER_CHANNEL, coupling=POWER_CH_COUPLING, VRange=POWER_CH_RANGE,
                                        VOffset=POWER_CH_OFFSET, enabled=POWER_CH_ENABLED, BWLimited=False,
                                        probeAttenuation=1)
            picoscope_serial.setChannel(channel=TRIGGER_CHANNEL, coupling="DC", VRange=5)

            picoscope_serial.setResolution('14')

            picoscope_serial.setSamplingInterval(SAMPLING_INTERVAL, SAMPLING_INTERVAL*SAMPLES)
            # Setting trigger
            picoscope_serial.setSimpleTrigger(trigSrc=TRIGGER_CHANNEL, threshold_V=TRIGGER_LEVEL, direction=TRIGGER_DIRECTION,
                                              delay=TRIGGER_DELAY,
                                              timeout_ms=1, enabled=True)


            # Setting the sampling frequency

            # (SamplingFrequency, maxSamples) = picoscope_serial.setSamplingFrequency(SAMPLING_FREQUENCY, SAMPLES, 0, 0)
            # SamplingTime = 1 / SamplingFrequency
            # Timebase = picoscope_serial.getTimeBaseNum(SamplingTime)
            # picoscope_serial.timebase = Timebase
            #
            # picoscope_serial.noSamples = SAMPLES + OFFSET

            print("hello world")
        else:
            ps = None
            print("pico is not armed")

        if RISCURE_ARMED:
            # Start the serial port session with motors
            riscure_serial = serial.Serial(
                port=RISCURE_COMPORT,
                baudrate=RISCURE_BAUDRATE,
                stopbits=serial.STOPBITS_ONE,  # one stop bit per byte
                bytesize=serial.EIGHTBITS,  # number of bits per bytes
            )
            if riscure_serial.isOpen():
                print(CONNECTION_OK)
            else:
                print(CONNECTION_KO)
                riscure_serial.close()
                sys.exit()

            bus = pyTMCL.connect(riscure_serial)
            # Getting the module from the bus
            module = bus.get_module(1)
            # Get the motor from thr bus:
            # Get the motor on axis Z of module with address 1
            MOTOR_Z = Motor(bus.get_motor(1, 0), Z_MIN, Z_MAX)
            MOTOR_Z.set_speed(Z_MOVEMENT_SPEED)
            # Get the motor on axis Y of module with address 1
            MOTOR_Y = Motor(bus.get_motor(1, 1), Y_MIN, Y_MAX)
            MOTOR_Y.set_speed(Y_MOVEMENT_SPEED)
            # Get the motor on axis X of module with address 1
            MOTOR_X = Motor(bus.get_motor(1, 2), X_MIN, X_MAX)
            MOTOR_X.set_speed(X_MOVEMENT_SPEED)

            if not os.path.exists("XYZ.json"):
                write_xyz("XYZ", 0, 0, 0)

            save_xyz(MOTOR_X, MOTOR_Y, MOTOR_Z,
                     "timestamps\\" + asctime().replace(":", ".").replace("  ", " ").replace(" ", "_") + "_XYZ")

            # lower motorZ to measurement position, set starting position
            save_xyz(MOTOR_X, MOTOR_Y, MOTOR_Z, "_init")
            MOTOR_Z.move_absolute(MOTOR_Z.min)
        CHIP_SERIAL.setTimeouts(500, 500)
    else:
        CHIP_SERIAL = serial.Serial(port=CHIP_COM_PORT, baudrate=CHIP_BAUDRATE, bytesize=serial.EIGHTBITS,
                                    parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE, timeout=30, xonxoff=0)

    TEMP_GRID = "grids\\Temp_grid.npz"
    if SAVE_PATH:
        # checking that the WD external hard drive is connected
        if os.path.exists(HARD_DRIVE_PATH):
            folder_string = HARD_DRIVE_PATH + f'fpga_ExpMode_{str(EXP_MODE)}_{datetime.now().strftime("%d_%m_%Y_%H.%M.%S")}'
        else:
            print("WD hard drive is not connected")
            close(CHIP_SERIAL, MOTOR_X, MOTOR_Y, MOTOR_Z, riscure_serial)
    if not SAVE_PATH:
        if ADJUSTED_PATH:
            folder_string = PATH + f'\\--For project-- FvR {EXP_MODE_PT}pt {d}bit {EXP_MODE_DEVICE} {EXP_MODE_RAND} rand {NUM_OF_QUERIES} TRACES {SAMPLES} samples'
        else:
            folder_string = PATH + f'\\fpga_ExpMode_{str(EXP_MODE)}_{datetime.now().strftime("%d_%m_%Y_%H.%M.%S")}' \
                               f'_{EXPERIMENT_DESC}'

    if PICO_ARMED:
        assure_path_exists(folder_string)

    if RESUME_RUN:
        """resumes run from last pixel, using the npz dictionary"""
        if os.path.exists(TEMP_GRID):
            Dictionary = np.load(TEMP_GRID, allow_pickle=False)
            grid = Dictionary["grid"]
            N = Dictionary["N"]
            if np.shape(grid) != (N, N):
                raise ValueError(f"grid size {repr(np.shape(grid))} doesnt match {N}x{N}")
        else:
            print("No temporary grid found, please start a new run")
            close(CHIP_SERIAL, MOTOR_X, MOTOR_Y, MOTOR_Z, riscure_serial)
    else:
        Dictionary = np.load(GRID_NPZ_PATH, allow_pickle=False)
        grid = Dictionary["grid"]
        N = Dictionary["N"]
        if np.shape(grid) != (N, N):
            raise ValueError(f"grid size {repr(np.shape(grid))} doesnt match {N}x{N}")

    start_time = time.time()

    if not RISCURE_ARMED:
        pixel_path = folder_string + f'\\({0},{0},{0})'
        if PICO_ARMED:
            assure_path_exists(pixel_path)
            if not ARMED:
                print("[!] CAUTION: not armed!")
            else:
                perform_measurement(START, NUMBER_OF_FILES, NUM_OF_QUERIES, EXP_MODE, pixel_path, CHIP_SERIAL,
                                    picoscope_serial)
        else:
            if not ARMED:
                print("[!] CAUTION: not armed!")
            else:
                perform_measurement(START, NUMBER_OF_FILES, NUM_OF_QUERIES, EXP_MODE, pixel_path, CHIP_SERIAL,
                                    )
    elif RISCURE_ARMED:
        for y in range(N):
            for x in range(N):
                if grid[x, y] == 0:
                    # do not measure
                    pass
                else:
                    "measuring pixel"
                    print("moving to next pixel")
                    move_absolute_grid(MOTOR_X, MOTOR_Y, x, y, N)
                    save_xyz(MOTOR_X, MOTOR_Y, MOTOR_Z, "XYZ")  # saving the current position...
                    print(f"arrived at pixel ({x},{y})")
                    if not ARMED:
                        print("[!] CAUTION: not armed!")
                    else:
                        pixel_path = folder_string + f'\\({x},{y},{MOTOR_Z.position()})'
                        if PICO_ARMED:
                            "create a pixel directory for the traces"
                            assure_path_exists(pixel_path)
                            perform_measurement(START, NUMBER_OF_FILES, NUM_OF_QUERIES, EXP_MODE, pixel_path, CHIP_SERIAL,
                                                picoscope_serial)
                        else:
                            perform_measurement(START, NUMBER_OF_FILES, NUM_OF_QUERIES, EXP_MODE, pixel_path, CHIP_SERIAL)

                    if RISCURE_ARMED:
                        grid[x, y] = 0
                        np.savez(TEMP_GRID, grid=grid, N=N)

        # move back to starting point
        x, y, z = read_xyz("_init")
        move_absolute(MOTOR_X, MOTOR_Y, x, y)
        MOTOR_Z.set_speed(2047)
        MOTOR_Z.move_absolute(z)
        os.remove("_init.json")

    print("[+] Acquisition completed.")

    elapsed = time.time() - start_time
    m = int(elapsed / 60)
    h = int(elapsed / 3600)
    print(f'[+] Elapsed time: {h}:{m}:{elapsed - m * 60 - h * 3600}')

    close(CHIP_SERIAL, MOTOR_X, MOTOR_Y, MOTOR_Z, riscure_serial) if RISCURE_ARMED else CHIP_SERIAL.close()
    if PICO_ARMED:
        picoscope_serial.close()