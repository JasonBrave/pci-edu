# PCI Edu device

This is an attempt to implement [QEMU PCI Edu device](https://github.com/qemu/qemu/blob/master/docs/specs/edu.txt) in SystemVerilog.

PCI Vendor ID 0x1234, Device ID 0x11e8.

### Features planned to implement
* PCI Bus
* PCI configuration space
* Memory address decoder
* Line interrupt and MSI interrupt
* MMIO registers
* Bus mastering DMA

### Getting started
Simulating PCI Edu device requires G++, make and Verilator. A VCD waveform viewer is also required for viewing waveform.\
Run simulation: `make sim`

### Source structure
`rtl` SystemVerilog RTL source code\
`tb/edu_verilator_wrapper.sv` SystemVerilog verilator wrapper, used as top level module for verilator simulation\
`sim_main.cpp` Verilator C++ testbench
