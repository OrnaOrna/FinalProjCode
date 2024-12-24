"""Module scans a grid of pixels and measures traces above each pixels"""

"""Whether to use Daniel's implementation (for riscure, etc) or Yair & Dan's implementation (w. GLM)"""
YAIR_DAN = True

from Utils_yair_dan import *
from config import *

# Temporary, remove after succot
for i in range(0, 1):
    #change_rand(i)
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

        picoscope_serial.setSamplingInterval(SAMPLING_INTERVAL, SAMPLING_INTERVAL * SAMPLES)
        # Setting trigger
        picoscope_serial.setSimpleTrigger(trigSrc=TRIGGER_CHANNEL, threshold_V=TRIGGER_LEVEL,
                                          direction=TRIGGER_DIRECTION,
                                          delay=TRIGGER_DELAY,
                                          timeout_ms=1, enabled=True)

        # Setting the sampling frequency

        # (SamplingFrequency, maxSamples) = picoscope_serial.setSamplingFrequency(SAMPLING_FREQUENCY, SAMPLES, 0, 0)
        # SamplingTime = 1 / SamplingFrequency
        # Timebase = picoscope_serial.getTimeBaseNum(SamplingTime)
        # picoscope_serial.timebase = Timebase
        #
        # picoscope_serial.noSamples = SAMPLES + OFFSET
    else:
        ps = None
        print("pico is not armed")

    folder_string = PATH + f'\\--For project-- CLM FvR {EXP_MODE_PT}pt {d}bit {EXP_MODE_DEVICE} {EXP_MODE_RAND} rand {NUM_OF_QUERIES} TRACES {SAMPLES} samples'

    if PICO_ARMED:
        assure_path_exists(folder_string)

    start_time = time.time()

    if PICO_ARMED:
        if not ARMED:
            print("[!] CAUTION: not armed!")
        else:
            perform_measurement(START, NUMBER_OF_FILES, NUM_OF_QUERIES, folder_string, CHIP_SERIAL,
                                picoscope_serial)
    else:
        if not ARMED:
            print("[!] CAUTION: not armed!")
        else:
            perform_measurement(START, NUMBER_OF_FILES, NUM_OF_QUERIES, folder_string, CHIP_SERIAL,
                                )

    print("[+] Acquisition completed.")

    elapsed = time.time() - start_time
    m = int(elapsed / 60)
    h = int(elapsed / 3600)
    print(f'[+] Elapsed time: {h}:{m}:{elapsed - m * 60 - h * 3600}')

    close(CHIP_SERIAL)
    if PICO_ARMED:
        picoscope_serial.close()
