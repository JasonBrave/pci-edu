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

`default_nettype none

module pci(
		   //address and data
		   input logic [31:0]  ad_in,
		   output logic [31:0] ad_out,
		   output logic		   ad_en,
		   input logic [3:0]   cbe_in,
		   output logic [3:0]  cbe_out,
		   output logic		   cbe_en,
		   input logic		   par_in,
		   output logic		   par_out,
		   output logic		   par_en,
		   //interface control
		   input logic		   frame_in,
		   output logic		   frame_out,
		   output logic		   frame_en,
		   input logic		   trdy_in,
		   output logic		   trdy_out,
		   output logic		   trdy_en,
		   input logic		   irdy_in,
		   output logic		   irdy_out,
		   output logic		   irdy_en,
		   input logic		   stop_in,
		   output logic		   stop_out,
		   output logic		   stop_en,
		   input logic		   devsel_in,
		   output logic		   devsel_out,
		   output logic		   devsel_en,
		   input logic		   idsel,
		   //error reporting
		   input logic		   perr_in,
		   output logic		   perr_out,
		   output logic		   perr_en,
		   input logic		   serr_in,
		   output logic		   serr_out,
		   output logic		   serr_en,
		   //arbitration
		   output logic		   req,
		   input logic		   gnt,
		   //system
		   input logic		   clk,
		   input logic		   rst,
		   //interface control
		   input logic		   lock_in,
		   output logic		   lock_out,
		   output logic		   lock_en,
		   //interrupts
		   output logic		   inta,
		   output logic		   intb,
		   output logic		   intc,
		   output logic		   intd);	

	logic					  cfg_enable;
	logic					  cfg_iswrite;
	logic [5:0]				  cfg_offset;
	logic [31:0]			  cfg_write_val;
	logic [3:0]				  cfg_be;
	logic [31:0]			  cfg_read_val;
	logic					  cfg_done;
	logic					  cfg_w_err;

	pci_busif pci_bus_interface(
								/*AUTOINST*/
								// Outputs
								.ad_out			(ad_out[31:0]),
								.ad_en			(ad_en),
								.cbe_out		(cbe_out[3:0]),
								.cbe_en			(cbe_en),
								.par_out		(par_out),
								.par_en			(par_en),
								.frame_out		(frame_out),
								.frame_en		(frame_en),
								.trdy_out		(trdy_out),
								.trdy_en		(trdy_en),
								.irdy_out		(irdy_out),
								.irdy_en		(irdy_en),
								.stop_out		(stop_out),
								.stop_en		(stop_en),
								.devsel_out		(devsel_out),
								.devsel_en		(devsel_en),
								.perr_out		(perr_out),
								.perr_en		(perr_en),
								.serr_out		(serr_out),
								.serr_en		(serr_en),
								.req			(req),
								.lock_out		(lock_out),
								.lock_en		(lock_en),
								.inta			(inta),
								.intb			(intb),
								.intc			(intc),
								.intd			(intd),
								.cfg_enable		(cfg_enable),
								.cfg_iswrite	(cfg_iswrite),
								.cfg_offset		(cfg_offset[5:0]),
								.cfg_write_val	(cfg_write_val[31:0]),
								.cfg_be			(cfg_be[3:0]),
								// Inputs
								.ad_in			(ad_in[31:0]),
								.cbe_in			(cbe_in[3:0]),
								.par_in			(par_in),
								.frame_in		(frame_in),
								.trdy_in		(trdy_in),
								.irdy_in		(irdy_in),
								.stop_in		(stop_in),
								.devsel_in		(devsel_in),
								.idsel			(idsel),
								.perr_in		(perr_in),
								.serr_in		(serr_in),
								.gnt			(gnt),
								.clk			(clk),
								.rst			(rst),
								.lock_in		(lock_in),
								.cfg_read_val	(cfg_read_val[31:0]),
								.cfg_done		(cfg_done),
								.cfg_w_err		(cfg_w_err));
	
	pci_cfg pci_configuration_space(
									.intr_status(1'b0),
									.master_data_parity_error(1'b0),
									.signaled_target_abort(1'b0),
									.received_target_abort(1'b0),
									.received_master_abort(1'b0),
									.signaled_system_error(1'b0),
									.detected_parity_error(1'b0),
									/*AUTOINST*/
									// Outputs
									.cfg_read_val		(cfg_read_val[31:0]),
									.cfg_done			(cfg_done),
									.cfg_w_err			(cfg_w_err),
									// Inputs
									.clk				(clk),
									.rst				(rst),
									.cfg_enable			(cfg_enable),
									.cfg_iswrite		(cfg_iswrite),
									.cfg_offset			(cfg_offset[5:0]),
									.cfg_write_val		(cfg_write_val[31:0]),
									.cfg_be				(cfg_be[3:0]));
	
endmodule // pci
