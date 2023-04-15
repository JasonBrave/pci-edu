SV_SRC = rtl/edu.sv rtl/pci/pci_pkg.sv rtl/pci/pci.sv rtl/pci/pci_cfg.sv rtl/pci/pci_busif.sv
SV_EXTRA_SRC = tb/edu_verilator_wrapper.sv
TB_SRC = tb/sim_main.cpp
VERILATOR = verilator

all: obj_dir/Vedu_verilator_wrapper

obj_dir/Vedu_verilator_wrapper:
	$(VERILATOR) -Wall --cc --exe --clk clk --top edu_verilator_wrapper --trace --build $(TB_SRC) $(SV_SRC) $(SV_EXTRA_SRC)

sim: obj_dir/Vedu_verilator_wrapper
	./obj_dir/Vedu_verilator_wrapper

clean:
	rm -rf obj_dir
