/*
 * PCI Edu device top level module
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

/* verilator lint_off UNUSED */

`default_nettype none

module edu(
		   //address and data
		   inout logic [31:0] ad,
		   inout logic [3:0]  cbe,
		   inout logic		  par,
		   //interface control
		   inout logic		  frame,
		   inout logic		  trdy,
		   inout logic		  irdy,
		   inout logic		  stop,
		   inout logic		  devsel,
		   input logic		  idsel,
		   //error reporting
		   inout logic		  perr,
		   inout logic		  serr,
		   //arbitration
		   output logic		  req,
		   input logic		  gnt,
		   //system
		   input logic		  clk,
		   input logic		  rst,
		   //interface control
		   inout logic		  lock,
		   //interrupts
		   output logic		  inta,
		   output logic		  intb,
		   output logic		  intc,
		   output logic		  intd);

	pci pci_ip(
			   .ad(ad),
			   .cbe(cbe),
			   .par(par),
			   .frame(frame),
			   .trdy(trdy),
			   .irdy(irdy),
			   .stop(stop),
			   .devsel(devsel),
			   .idsel(idsel),
			   .perr(perr),
			   .serr(serr),
			   .req(req),
			   .gnt(gnt),
			   .clk(clk),
			   .rst(rst),
			   .lock(lock),
			   .inta(inta),
			   .intb(intb),
			   .intc(intc),
			   .intd(intd));
endmodule // edu
