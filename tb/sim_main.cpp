#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "../obj_dir/Vedu.h"

void tb_pci_reset(Vedu *vedu, VerilatedVcdC *tfp) {
	Verilated::timeInc(1);
	vedu->rst = 0;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->rst = 1;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->rst = 1;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->rst = 1;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());

	vedu->rst = 0;
}

void tb_pci_idle(Vedu *vedu, VerilatedVcdC *tfp, unsigned int n) {
	for (unsigned int i = 0; i < n; i++) {
		Verilated::timeInc(1);
		vedu->frame = 1;
		vedu->clk = 0;
		vedu->eval();
		tfp->dump(Verilated::time());

		Verilated::timeInc(1);
		vedu->frame = 1;
		vedu->clk = 1;
		vedu->eval();
		tfp->dump(Verilated::time());
	}
}

uint32_t tb_pci_config_read32(Vedu *vedu, VerilatedVcdC *tfp, unsigned int reg) {
	Verilated::timeInc(1);
	vedu->frame = 0;
	vedu->ad = reg << 2;
	vedu->idsel = 1;
	vedu->cbe = 0xa;
	vedu->irdy = 1;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 0;
	vedu->ad = reg << 2;
	vedu->idsel = 1;
	vedu->cbe = 0xa;
	vedu->irdy = 1;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->cbe = 0xf;
	vedu->irdy = 0;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());
	std::cout << vedu->ad << std::endl;

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->cbe = 0xf;
	vedu->irdy = 0;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());
	std::cout << vedu->ad << std::endl;
	uint32_t value = vedu->ad;

	do {
		Verilated::timeInc(1);
		vedu->frame = 1;
		vedu->cbe = 0;
		vedu->irdy = 1;
		vedu->clk = 0;
		vedu->eval();
		tfp->dump(Verilated::time());
		std::cout << vedu->ad << std::endl;

		Verilated::timeInc(1);
		vedu->frame = 1;
		vedu->cbe = 0;
		vedu->irdy = 1;
		vedu->clk = 1;
		vedu->eval();
		tfp->dump(Verilated::time());
		std::cout << vedu->ad << std::endl;
	} while (vedu->trdy == 1 && vedu->devsel == 1);

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->cbe = 0;
	vedu->irdy = 1;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());
	return value;
}

int main(int argc, char *argv[]) {
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	VerilatedVcdC *tfp = new VerilatedVcdC;

	std::cout << std::hex;

	Vedu *vedu = new Vedu();
	vedu->trace(tfp, 99);
	tfp->open("dump.vcd");

	tb_pci_reset(vedu, tfp);
	tb_pci_idle(vedu, tfp, 5);
	std::cout << "Test: Register 0 in PCI cfg is " << tb_pci_config_read32(vedu, tfp, 0)
			  << std::endl;

	tfp->close();
}
