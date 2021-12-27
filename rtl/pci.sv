/*
 * PCI Edu device PCI bus IP module
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

module pci(
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

	logic					  cfg_enable;
	logic					  cfg_iswrite;
	logic [5:0]				  cfg_offset;
	logic [31:0]			  cfg_write_val;
	logic [31:0]			  cfg_read_val;

	pci_busif pci_bus_interface(
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
								.intd(intd),
								.cfg_enable(cfg_enable),
								.cfg_iswrite(cfg_iswrite),
								.cfg_offset(cfg_offset),
								.cfg_write_val(cfg_write_val),
								.cfg_read_val(cfg_read_val));
	
	pci_cfg pci_configuration_space(
									.clk(clk),
									.rst(rst),
									.cfg_enable(cfg_enable),
									.cfg_iswrite(cfg_iswrite),
									.cfg_offset(cfg_offset),
									.cfg_write_val(cfg_write_val),
									.cfg_read_val(cfg_read_val),
									.intr_status(1'b0),
									.master_data_parity_error(1'b0),
									.signaled_target_abort(1'b0),
									.received_target_abort(1'b0),
									.received_master_abort(1'b0),
									.signaled_system_error(1'b0),
									.detected_parity_error(1'b0));
	
endmodule // pci
