/*
 * PCI Edu device PCI configuration space module
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

import pci_pkg::pci_cfg_reg_offset;

module pci_cfg
  #(
	parameter PCI_VENDOR_ID = 16'h1234,
	parameter PCI_DEVICE_ID = 16'h11e8,
	parameter PCI_CLASS = 8'hff,
	parameter PCI_SUBCLASS = 8'h00,
	parameter PCI_PROGIF = 8'h00,
	parameter PCI_REVISION = 8'h09,
	parameter PCI_SUBSYSTEM_ID_DEF = 16'h11e8,
	parameter PCI_SUBSYSTEM_VENDOR_ID_DEF = 16'h1234)
	(// control signals
	 input logic		 clk,
	 input logic		 rst,
	 // register signals
	 input logic		 cfg_enable,
	 input logic		 cfg_iswrite,
	 input logic [5:0]	 cfg_offset,
	 input logic [31:0]	 cfg_write_val,
	 input logic [3:0]	 cfg_be,
	 output logic [31:0] cfg_read_val,
	 output logic		 cfg_done,
	 output logic		 cfg_w_err,
	 // status signals
	 input logic		 intr_status,
	 input logic		 master_data_parity_error,
	 input logic		 signaled_target_abort,
	 input logic		 received_target_abort,
	 input logic		 received_master_abort,
	 input logic		 signaled_system_error,
	 input logic		 parity_error,
	 // register output
	 output logic		 serr_enable,
	 output logic		 perr_response);

	localparam   PCI_DEVSEL_TIMING = 2'b00;
	localparam	 PCI_CAPABLE_FASTB2B = 1'b0;
	localparam	 PCI_CAPABLE_66MHZ = 1'b0;
	localparam	 PCI_IMPLEMENT_CAPABILITIES = 1'b1;

	localparam	 PCI_MULTIFUNCTION = 1'b0;
	localparam	 PCI_HEADER_TYPE = 7'h00;

	localparam	 PCI_CAPPTR = 8'h40;

	localparam	 PCI_INTERRUPT_PIN = 8'h01;

	localparam	 PCI_MIN_GNT = 8'h00;
	localparam	 PCI_MAX_LAT = 8'h00;

	localparam	 PCI_MSI_CAP_CAPID = 8'h05;
	localparam	 PCI_MSI_CAP_NEXTPTR = 8'h00;
	localparam	 PCI_MSI_PER_VECTOR_MASK_CAPABLE = 1'b0;
	localparam	 PCI_MSI_64BIT_ADDR_CAPABLE = 1'b1;
	localparam	 PCI_MSI_MULTI_MSI_CAPABLE = 3'b000;

	logic		 command_intr_disable;
	logic		 command_fast_b2b;
	logic		 command_serr_enable;
	logic		 command_perr_response;
	logic		 command_memwr_invalidate;
	logic		 command_special_cycles;
	logic		 command_bus_master;
	logic		 command_memory_space;
	logic		 command_io_space;

	logic		 detected_parity_error;

	logic [7:0]	 cacheline_size;
	logic [7:3]	 latency_timer;

	logic [31:4] bar0;

	logic [15:0] subsystem_id,subsystem_vendor_id;

	logic [7:0]	 interrupt_line;

	logic [2:0]	 msi_multiple_message;
	logic		 msi_enable;
	logic [63:2] msi_address;
	logic [15:0] msi_data;

	always_ff @(posedge clk, negedge rst) begin
		if(parity_error == 1'b1) begin
			detected_parity_error <= 1'b1;
		end
	end

	assign serr_enable = command_serr_enable;
	assign perr_response = command_perr_response;
	
	always_ff @(posedge clk, negedge rst) begin
		if(rst == 1'b0) begin
			// command register reset
			command_intr_disable <= 1'b0;
			command_fast_b2b <= 1'b0;
			command_serr_enable <= 1'b0;
			command_perr_response <= 1'b0;
			command_memwr_invalidate <= 1'b0;
			command_special_cycles <= 1'b0;
			command_bus_master <= 1'b0;
			command_memory_space <= 1'b0;
			command_io_space <= 1'b0;
			//subsystem register reset
			subsystem_id <= PCI_SUBSYSTEM_ID_DEF;
			subsystem_vendor_id <= PCI_SUBSYSTEM_VENDOR_ID_DEF;
			//cacheline size register reset
			cacheline_size <= 8'h00;
			latency_timer <= 5'b00000;
			// BAR 0 reset
			bar0 <= 28'h0000000;
			// reset interrupt line register
			interrupt_line <= 8'h00;
			// reset MSI registers
			msi_multiple_message <= 3'b000;
			msi_enable <= 1'b0;
			msi_address <= 62'h00000000_00000000;
			msi_data <= 16'h0000;

			cfg_done <= 1'b0;
			cfg_w_err <= 1'b0;
		end else begin
			if(cfg_enable == 1'b1) begin
				if(cfg_iswrite == 1'b0) begin
					case(cfg_offset)
						pci_pkg::CFG_VENDOR_DEVICE: cfg_read_val <= {PCI_DEVICE_ID,PCI_VENDOR_ID};
						pci_pkg::CFG_COMMAND_STATUS: cfg_read_val <= {{
																	   detected_parity_error,
																	   signaled_system_error,
																	   received_master_abort,
																	   received_target_abort,
																	   signaled_target_abort,
																	   PCI_DEVSEL_TIMING,
																	   master_data_parity_error,
																	   PCI_CAPABLE_FASTB2B,
																	   1'b0,//reserved
																	   PCI_CAPABLE_66MHZ,
																	   PCI_IMPLEMENT_CAPABILITIES,
																	   intr_status,
																	   3'b000//reserved
																	   },{
																		  5'b00000,//reserved
																		  command_intr_disable,
																		  command_fast_b2b,
																		  command_serr_enable,
																		  1'b0,//reserved
																		  command_perr_response,
																		  1'b0,// VGA palette snooping not implemented
																		  command_memwr_invalidate,
																		  command_special_cycles,
																		  command_bus_master,
																		  command_memory_space,
																		  command_io_space//implement this bit, although this device does not use IO space
																		  }};
						pci_pkg::CFG_REV_CLASS: cfg_read_val <= {PCI_CLASS,
																 PCI_SUBCLASS,
																 PCI_PROGIF,
																 PCI_REVISION};
						pci_pkg::CFG_CACHE_LATTIMER_HDRTYPE_BIST: cfg_read_val <= {8'h00,//BIST not implemented
																				   {PCI_MULTIFUNCTION,PCI_HEADER_TYPE},//header type
																				   {latency_timer,3'b000},//latency timer 
																				   cacheline_size// cacheine size 
																				   };
						pci_pkg::CFG_BAR0: cfg_read_val <= {bar0,
															1'b0,//not prefetchable
															2'b00,//32-bit space
															1'b0//memory space
															};
						pci_pkg::CFG_BAR1: cfg_read_val <= 32'h00000000;
						pci_pkg::CFG_BAR2: cfg_read_val <= 32'h00000000;
						pci_pkg::CFG_BAR3: cfg_read_val <= 32'h00000000;
						pci_pkg::CFG_BAR4: cfg_read_val <= 32'h00000000;
						pci_pkg::CFG_BAR5: cfg_read_val <= 32'h00000000;
						pci_pkg::CFG_CARDBUS_CIS: cfg_read_val <= 32'h00000000;
						pci_pkg::CFG_SUBSYSTEM_ID: cfg_read_val <= {subsystem_id,subsystem_vendor_id};
						pci_pkg::CFG_ROMBAR: cfg_read_val <= 32'h00000000;
						pci_pkg::CFG_CAPPTR: cfg_read_val <= {24'h000000,PCI_CAPPTR};
						pci_pkg::CFG_INTR_PIN: cfg_read_val <= {PCI_MAX_LAT,
																PCI_MIN_GNT,
																PCI_INTERRUPT_PIN,
																interrupt_line
																};
						pci_pkg::CFG_MSI_CAPHDR_CTRL: cfg_read_val <= {{7'b0000000,
																		PCI_MSI_PER_VECTOR_MASK_CAPABLE,
																		PCI_MSI_64BIT_ADDR_CAPABLE,
																		msi_multiple_message,
																		PCI_MSI_MULTI_MSI_CAPABLE,
																		msi_enable},
																	   PCI_MSI_CAP_NEXTPTR,
																	   PCI_MSI_CAP_CAPID};
						pci_pkg::CFG_MSI_ADDR_LOWER: cfg_read_val <= {msi_address[31:2],2'b00};
						pci_pkg::CFG_MSI_ADDR_UPPER: cfg_read_val <= msi_address[63:32];
						pci_pkg::CFG_MSI_DATA: cfg_read_val <= {16'h0000, msi_data};
						default: cfg_read_val <= 32'h00000000;
					endcase // case (offset)
					cfg_done <= 1'b1;
				end else begin // if (cfg_iswrite == 1'b0)
					case(cfg_offset)
						pci_pkg::CFG_VENDOR_DEVICE: cfg_w_err <= 1'b1;
						pci_pkg::CFG_COMMAND_STATUS: begin
							if(cfg_be[0]) begin
								command_io_space <= cfg_write_val[0];
								command_io_space <= cfg_write_val[1];
								command_bus_master <= cfg_write_val[2];
								command_special_cycles <= cfg_write_val[3];
								command_memwr_invalidate <= cfg_write_val[4];
								command_perr_response <= cfg_write_val[6];
							end
							if(cfg_be[1]) begin
								command_serr_enable <= cfg_write_val[8];
								command_fast_b2b <= cfg_write_val[9];
								command_intr_disable <= cfg_write_val[10];
							end
						end
						pci_pkg::CFG_REV_CLASS: cfg_w_err <= 1'b1;
						pci_pkg::CFG_CACHE_LATTIMER_HDRTYPE_BIST: begin
							if(cfg_be[0]) begin
								cacheline_size <= cfg_write_val[7:0];
							end
							if(cfg_be[1]) begin
								latency_timer <= cfg_write_val[15:11];
							end
						end
						pci_pkg::CFG_BAR0: begin
							if(cfg_be != 4'b1111) begin
								cfg_w_err <= 1'b1;
							end else begin
								bar0 <= cfg_write_val[31:4];
							end
						end
						pci_pkg::CFG_BAR1: begin
						end
						pci_pkg::CFG_BAR2: begin
						end
						pci_pkg::CFG_BAR3: begin
						end
						pci_pkg::CFG_BAR4: begin
						end
						pci_pkg::CFG_BAR5: begin
						end
						pci_pkg::CFG_CARDBUS_CIS: begin
						end
						pci_pkg::CFG_SUBSYSTEM_ID: begin
							if(cfg_be[1:0] == 2'b11) begin
								subsystem_vendor_id <= cfg_write_val[15:0];
							end
							if(cfg_be[3:2] == 2'b11) begin
								subsystem_id <= cfg_write_val[31:16];
							end
							if(((^cfg_be[1:0]) == 1'b1) || ((^cfg_be[3:2]) == 1'b1)) begin
								cfg_w_err <= 1'b1;
							end
						end // case: pci_pkg::CFG_SUBSYSTEM_ID
						pci_pkg::CFG_ROMBAR: begin
						end
						pci_pkg::CFG_CAPPTR: begin
							cfg_w_err <= 1'b1;
						end
						pci_pkg::CFG_INTR_PIN: begin
							if(cfg_be[0] == 1'b1) begin
								interrupt_line <= cfg_write_val[7:0];
							end
						end
						pci_pkg::CFG_MSI_CAPHDR_CTRL: begin
							if(cfg_be[2] == 1'b1) begin
								msi_enable <= cfg_write_val[16];
								msi_multiple_message[2:0] <= cfg_write_val[22:20];
							end
						end
						pci_pkg::CFG_MSI_ADDR_LOWER: begin
							if(cfg_be == 4'b1111) begin
								msi_address[31:2] <= cfg_write_val[31:2];
							end
						end
						pci_pkg::CFG_MSI_ADDR_UPPER: begin
							if(cfg_be == 4'b1111) begin
								msi_address[63:32] <= cfg_write_val[31:0];
							end
						end
						pci_pkg::CFG_MSI_DATA: begin
							if(cfg_be[1:0] == 2'b11) begin
								msi_data <= cfg_write_val[15:0];
							end
						end
						default: begin
						end
					endcase // case (cfg_offset)
					cfg_done <= 1'b1;
				end // else: !if(cfg_iswrite == 1'b0)
			end else begin // if (cfg_enable == 1'b1)
				if(cfg_done == 1'b1) begin
					cfg_done <= 1'b0;
				end
				if(cfg_w_err == 1'b1) begin
					cfg_w_err <= 1'b0;
				end
			end

		end // else: !if(rst = 1'b0)
	end

endmodule // pci_cfg
