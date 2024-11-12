"""Module provides configuration constants for the project"""
from numpy import array, uint8

"""Constants"""
CONNECTION_OK = "[+] The COM port connection has been established successfully."
CONNECTION_KO = (
    "[!!!] ERROR: No available COM port has been selected. get an available COM ports."
)

"""Paths"""
ADJUSTED_PATH = True
PATH = "C:\\Users\\Public\\Documents\\measurements"
HARD_DRIVE_PATH = "C:\\Users\\Public\\Documents\\dan_yair_meas_config"

""""experiment setup"""
d = 8
P = 299
BYTE = 7
T_TEST = True
SAMPLES = 1000

OFFSET = 0  
NUM_OF_QUERIES = 50 
NUMBER_OF_FILES = 1
START = 0  # file from which measurement will continue
# saving methods: NPY (Python compatible), MAT (Matlab compatible),None for not saving the workspace
SAVE_METHOD = "MAT"
PS_MODEL = 5000


PICO_ARMED = True  # armed: if true will measure, otherwise will skip
ARMED = True  # armed: if true will measure, otherwise will skip
WITH_UART = True
MEAS_POWER = True

EXP_MODE_KEY = 0
EXP_MODE_PT = 0
EXP_MODE_RAND = 0
EXP_MODE_DEVICE = "RAMBAM"

"""chooses frequencies according to enumerate value in the following chart
. min value is 3 (21.33Mhz) max value is 21 (533Khz). referenced from pls15 sdk 1.1. clock.h
  typedef enum PLS_SUPPORTED_FREQUENCY{
      ##################
      following frequencies are unstable
      PLS_CLK_FREQ_CLOCK42P667MHZ,/*!<42.667MHZ */ 0
      PLS_CLK_FREQ_CLOCK32MHZ,/*!< 32MHZ */ 1
      PLS_CLK_FREQ_CLOCK25P6MHZ,/*!< 25.6MHZ */ 2
      ##########################
      following frequencies are stable
      PLS_CLK_FREQ_CLOCK21P33MHZ,/*!< 21.33MHZ*/ 3
      PLS_CLK_FREQ_CLOCK20MHZ,/*!< 20MHZ */ 4
      PLS_CLK_FREQ_CLOCK16MHZ,/*!< 16MHZ */ 5
      PLS_CLK_FREQ_CLOCK13p3MHZ,/*!< 13.3 MHZ */ 6 
      PLS_CLK_FREQ_CLOCK10MHZ,/*!< 10MHZ */ 7
      PLS_CLK_FREQ_CLOCK8MHZ,/*!< 8MHZ */ 8 
      PLS_CLK_FREQ_CLOCK6P67MHZ,/*!< 6.67MHZ */ 9
      PLS_CLK_FREQ_CLOCK5MHZ,/*!< 5MHZ */ 10
      PLS_CLK_FREQ_CLOCK4MHZ,/*!< 4MHZ */ 11
      PLS_CLK_FREQ_CLOCK32MHZ,/*!< 3.2MHZ */ 12
      PLS_CLK_FREQ_CLOCK2P857MHZ,/*!< 2.857MHZ */ 13
      PLS_CLK_FREQ_CLOCK2P5MHZ,/*!< 2.5MHZ */ 14
      PLS_CLK_FREQ_CLOCK2P133MHZ,/*!< 2.133MHZ */ 15
      PLS_CLK_FREQ_CLOCK1P6MHZ,/*!< 1.6MHZ */ 16
      ############### not stable
      PLS_CLK_FREQ_CLOCK1P28MHZ,/*!< 1.28MHZ */ 17 
      PLS_CLK_FREQ_CLOCK1P067MHZ,/*!< 1.067MHZ */ 18
      PLS_CLK_FREQ_CLOCK800KHZ,/*!< 800KHZ */ 19
      PLS_CLK_FREQ_CLOCK640KHZ,/*!< 640KHZ */ 20
      PLS_CLK_FREQ_CLOCK533KHZ,/*!<! 533KHZ */ 21
      #####
      following frequencies are not unstable
      PLS_CLK_FREQ_CLOCK457KHZ,/*!< 457KHZ */ 22(!)
      PLS_CLK_FREQ_CLOCK400KHZ,/*!< 400KHZ */ 23(!)
      PLS_CLK_FREQ_UNSUPPORTED_FREQUENCY,/*!< SPECIAL VALUE to indicate that we don't support any other frequency in
       case error should be returned */
}"""
"""pls"""
FREQ_ENUM_ARRAY = array([7, 10], dtype=uint8)
RANDOM_FREQ = False  # 1/ROUNDS randomly choese from a freq. from the array
ROUNDS = 2  # once in how many traces is the frequency changed if RANDOM_FREQ is enabled
ITERATING_FREQ = False  # every round, chooses the freq in trace_num%len(FREQ_ENUM_ARRAY)
P_STATE = False
P_STATE_RADFS = True
F_SIZE = uint8(0)  # actual size is (F_Size*2)+1 as  we expand the tails
# -------------------------------------------------------
# Oscilloscope configuration
"""
% BitsResolution -> {
                         0 = 8bit  ;
                        1 = 12bit ;
                        2 = 14bit ;
                        3 = 15bit ;
                        4 = 16bit ;  }
"""
# (it depends on the device and on the configuration.
# Please, read the user manual.)
BIT_RESOLUTION = 1

# Sample Frequency (in Hz)
SAMPLING_FREQUENCY = (
    100E6  # 125E6 #14E6 #clock is 2MHz in the FPGA==> 7 samples per clock #200E6
)

SAMPLING_INTERVAL = 8E-9

# Picoscope channel Configurations
"""
% ChXEnabled -> True - OFF ; False - ON
% ChXCoupling -> 0 - AC ; 1 - DC
% ChXRange -> {
%                0.01 = +/-10mV ;
%                0.02 = +/-20mV ;
%                0.05 = +/-50mV ;
%                0.1  = +/-100mV ;
%                0.2  = +/-200mV ;
%                0.5  = +/-500mV ;
%                1.0  = +/-1V ;
%                2.0  = +/-2V ;
%                5.0  = +/-5V ;
%                10.0 = +/-10V ;
%                20.0 = +/-20V ;  }
% ChXOffset -> [V]
"""

# Channel B configuration
POWER_CHANNEL = "B"
POWER_CH_ENABLED = True
POWER_CH_COUPLING = 0  # 0 = AC ; 1 = DC
POWER_CH_RANGE = 0.1  # for 19 # 0.1 for 18 ?
POWER_CH_OFFSET = 0

# Trigger configuration
"""
% Channel list -> {
%                 0 -> CHANNEL A ;
%                 1 -> CHANNEL B ;
%                 2 -> CHANNEL C ;
%                 3 -> CHANNEL D ;
%                 4 -> EXTERNAL ;   }
% Trigger Level -> V
% Trigger Delay -> s
% TriggerDirection -> {
%                 0 -> ABOVE THRESHOLD ;
%                 1 -> BELOW THRESHOLD ;
%                 2 -> RISING EDGE ;
%                 3 -> FALLING EDGE ;
%                 4 -> RISING OR FALLING EDGE ;
%                 5 -> INSIDE WINDOW ;
%                 6 -> OUTSIDE WINDOW ;
%                 7 -> ENTER WINDOW ;
%                 8 -> EXIT WINDOW ;
%                 9 -> NONE ;   }
% TriggerAutosetms -> ms (0 if REPEAT/SINGLE MODE TRIGGERING - CLASSIC)
"""

TRIGGER_CHANNEL = 'C'
TRIGGER_LEVEL = 1
TRIGGER_DELAY = 0
TRIGGER_DIRECTION = 3
TRIGGER_AUTOSET_MS = 0

# Acquisition configuration
NUM_PRE_TRIGGER_SAMPLES = 0  # 0
DOWN_SAMPLING = 1
