/*
 * PCI Edu device testbench
 *
 * This file is part of PCI Edu device.
 *
 * PCI Edu device is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * PCI Edu device is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with PCI Edu device.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "../obj_dir/Vedu_verilator_wrapper.h"

void tb_pci_reset(Vedu_verilator_wrapper *vedu, VerilatedVcdC *tfp) {
	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->ad_in_en = 0;
	vedu->cbe_in_en = 0;
	vedu->idsel = 0;
	vedu->irdy = 1;
	vedu->rst = 1;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->ad_in_en = 0;
	vedu->cbe_in_en = 0;
	vedu->idsel = 0;
	vedu->irdy = 1;
	vedu->rst = 0;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->ad_in_en = 0;
	vedu->cbe_in_en = 0;
	vedu->idsel = 0;
	vedu->irdy = 1;
	vedu->rst = 0;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->ad_in_en = 0;
	vedu->cbe_in_en = 0;
	vedu->idsel = 0;
	vedu->irdy = 1;
	vedu->rst = 0;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());

	vedu->rst = 1;
}

void tb_pci_idle(Vedu_verilator_wrapper *vedu, VerilatedVcdC *tfp, unsigned int n) {
	for (unsigned int i = 0; i < n; i++) {
		Verilated::timeInc(1);
		vedu->frame = 1;
		vedu->ad_in_en = 0;
		vedu->idsel = 0;
		vedu->cbe_in_en = 0;
		vedu->irdy = 1;
		vedu->clk = 0;
		vedu->eval();
		tfp->dump(Verilated::time());

		Verilated::timeInc(1);
		vedu->frame = 1;
		vedu->ad_in_en = 0;
		vedu->idsel = 0;
		vedu->cbe_in_en = 0;
		vedu->irdy = 1;
		vedu->clk = 1;
		vedu->eval();
		tfp->dump(Verilated::time());
	}
}

uint32_t tb_pci_config_read32(Vedu_verilator_wrapper *vedu, VerilatedVcdC *tfp, unsigned int reg) {
	// AD phase
	Verilated::timeInc(1);
	vedu->frame = 0;
	vedu->ad_in = reg << 2;
	vedu->ad_in_en = 1;
	vedu->idsel = 1;
	vedu->cbe_in = 0xa;
	vedu->cbe_in_en = 1;
	vedu->irdy = 1;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 0;
	vedu->ad_in = reg << 2;
	vedu->ad_in_en = 1;
	vedu->idsel = 1;
	vedu->cbe_in = 0xa;
	vedu->cbe_in_en = 1;
	vedu->irdy = 1;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->ad_in_en = 0;
	vedu->idsel = 0;
	vedu->cbe_in = 0xf;
	vedu->cbe_in_en = 1;
	vedu->irdy = 0;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->ad_in_en = 0;
	vedu->idsel = 0;
	vedu->cbe_in = 0xf;
	vedu->cbe_in_en = 1;
	vedu->irdy = 0;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());
	// C/BE phase and assert IRDY
	uint32_t value = 0;
	do {
		Verilated::timeInc(1);
		vedu->frame = 1;
		vedu->ad_in_en = 0;
		vedu->idsel = 0;
		vedu->cbe_in = 0xf;
		vedu->cbe_in_en = 1;
		vedu->irdy = 0;
		vedu->clk = 0;
		vedu->eval();
		tfp->dump(Verilated::time());

		Verilated::timeInc(1);
		vedu->frame = 1;
		vedu->ad_in_en = 0;
		vedu->idsel = 0;
		vedu->cbe_in = 0xf;
		vedu->cbe_in_en = 1;
		vedu->irdy = 0;
		vedu->clk = 1;
		vedu->eval();
		tfp->dump(Verilated::time());
		value = vedu->ad_out;
	} while (vedu->trdy == 1 && vedu->devsel == 1);

	return value;
}

void tb_pci_config_write32(Vedu_verilator_wrapper *vedu, VerilatedVcdC *tfp, unsigned int reg,
						   uint32_t value) {
	// AD phase
	Verilated::timeInc(1);
	vedu->frame = 0;
	vedu->ad_in = reg << 2;
	vedu->ad_in_en = 1;
	vedu->idsel = 1;
	vedu->cbe_in = 0xb;
	vedu->cbe_in_en = 1;
	vedu->irdy = 1;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 0;
	vedu->ad_in = reg << 2;
	vedu->ad_in_en = 1;
	vedu->idsel = 1;
	vedu->cbe_in = 0xb;
	vedu->cbe_in_en = 1;
	vedu->irdy = 1;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());

	vedu->idsel = 0;
	vedu->frame = 1;

	do {
		// Data phase
		Verilated::timeInc(1);
		vedu->ad_in = value;
		vedu->ad_in_en = 1;
		vedu->cbe_in = 0xf;
		vedu->cbe_in_en = 1;
		vedu->irdy = 0;
		vedu->clk = 0;
		vedu->eval();
		tfp->dump(Verilated::time());

		Verilated::timeInc(1);
		vedu->ad_in = value;
		vedu->ad_in_en = 1;
		vedu->cbe_in = 0xf;
		vedu->cbe_in_en = 1;
		vedu->irdy = 0;
		vedu->clk = 1;
		vedu->eval();
		tfp->dump(Verilated::time());
	} while (vedu->trdy == 1 || vedu->devsel == 1);

	// End of transaction
	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->ad_in_en = 0;
	vedu->cbe_in_en = 0;
	vedu->irdy = 1;
	vedu->clk = 0;
	vedu->eval();
	tfp->dump(Verilated::time());

	Verilated::timeInc(1);
	vedu->frame = 1;
	vedu->ad_in_en = 0;
	vedu->cbe_in_en = 0;
	vedu->irdy = 1;
	vedu->clk = 1;
	vedu->eval();
	tfp->dump(Verilated::time());
}

int main(int argc, char *argv[]) {
	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	VerilatedVcdC *tfp = new VerilatedVcdC;

	std::cout << std::hex;

	Vedu_verilator_wrapper *vedu = new Vedu_verilator_wrapper();
	vedu->trace(tfp, 99);
	tfp->open("dump.vcd");

	tb_pci_reset(vedu, tfp);
	tb_pci_idle(vedu, tfp, 5);
	std::cout << "PCI Configuration Space registers status:" << std::endl;
	for (int reg = 0; reg < 64; reg++) {
		uint32_t value = tb_pci_config_read32(vedu, tfp, reg);
		std::cout << "PCI Cfg Register offset " << reg << " value " << value << std::endl;
		tb_pci_idle(vedu, tfp, 5);
	}
	std::cout << "Write to MSI upper address register" << std::endl;
	tb_pci_config_write32(vedu, tfp, 0x12, 0x12345678);
	std::cout << "PCI Configuration Space registers status:" << std::endl;
	for (int reg = 0; reg < 64; reg++) {
		uint32_t value = tb_pci_config_read32(vedu, tfp, reg);
		std::cout << "PCI Cfg Register offset " << reg << " value " << value << std::endl;
		tb_pci_idle(vedu, tfp, 5);
	}
	tb_pci_idle(vedu, tfp, 5);
	tfp->close();
}
