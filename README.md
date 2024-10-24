# A Hardware Implementation & Side Channel Analysis of the RAMBAM and CLM Masking Schemes: Project Code Repository
This is accompanying code for the 4th year engineering final project of Yair Oren and Dan Michaeli, under supervision of Dr. Itamar Levi and Prof. Osnat Keren. It contains all hardware code written by us, as well as software code we used for simulation of the implemented systems and for side-channel analysis, and the LyX file of the final report. 

#### The repository is organized as follows:
- `Framework/`: The hardware framework files for interfacing our module with the board and chip. This code is for the slave FPGA only; code for the master FPGA was used completely unaltered and can be found at [SASEBO Project's Site](https://www.risec.aist.go.jp/project/sasebo/) under SASEBO GIII.
- `RAMBAM/`: SystemVerilog implementation of the RAMBAM masking scheme:
    - `S-Box Only/` code for the `SubBytes` stage of the cipher only.
    - `Full RAMBAM Module/` code that needs to be added to complete the implementation.
    - `Alternatives/`: Alternative implementations for some sub-modules.
- - `Include/`: Header files used by the design; includes all parameters needed for the hardware modules.
- `CLM/`: SystemVerilog implementation of the CLM masking scheme:
    - `Implementation/`: The implementation code for the entire design (S-Box included).
    - `Alternatives/`: Same as in `RAMBAM/`.
    - `Include/`: Header files used by the design; includes data loaded to memory for functions that are hard to calculate in hardware.
- `MATLAB`: MatLab scripts used for simulation &amp; debugging, and also for generation of the hardware parameters used in the header files.
- `Python Measurement/` Python code for communication between hardware and computer and for trace collection. Provided courtesy of Daniel Dobkin of SELECSYS Lab.
- `Scripts/`: Simple scripts used in simulation and debugging. Includes input files to the Cadence XCelium simulator we used for debugging.
- `Report/`: The LyX file and dependencies for the final report, and reports from midyear.

