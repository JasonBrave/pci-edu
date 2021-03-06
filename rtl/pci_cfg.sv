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

/* verilator lint_off UNUSED */

`default_nettype none

module pci_cfg(// control signals
			   input logic		   clk,
			   input logic		   rst,
			   // register signals
			   input logic		   cfg_enable,
			   input logic		   cfg_iswrite,
			   input logic [5:0]   cfg_offset,
			   input logic [31:0]  cfg_write_val,
			   output logic [31:0] cfg_read_val,
			   // status signals
			   input logic		   intr_status,
			   input logic		   master_data_parity_error,
			   input logic		   signaled_target_abort,
			   input logic		   received_target_abort,
			   input logic		   received_master_abort,
			   input logic		   signaled_system_error,
			   input logic		   detected_parity_error);

	localparam					   EDU_PCI_VENDOR_ID = 16'h1234;
	localparam					   EDU_PCI_DEVICE_ID = 16'h11e8;

	localparam					   EDU_PCI_DEVSEL_TIMING = 2'b00;
	localparam					   EDU_PCI_CAPABLE_FASTB2B = 1'b0;
	localparam					   EDU_PCI_CAPABLE_66MHZ = 1'b0;
	localparam					   EDU_PCI_IMPLEMENT_CAPABILITIES = 1'b1;

	localparam					   EDU_PCI_CLASS = 8'hff;
	localparam					   EDU_PCI_SUBCLASS = 8'h00;
	localparam					   EDU_PCI_PROGIF = 8'h00;
	localparam					   EDU_PCI_REVISION = 8'h09;//v0.9

	localparam					   EDU_PCI_MULTIFUNCTION = 1'b0;
	localparam					   EDU_PCI_HEADER_TYPE = 7'h00;

	localparam					   EDU_PCI_SUBSYSTEM_ID_DEF = 16'h11e8;
	localparam					   EDU_PCI_SUBSYSTEM_VENDOR_ID_DEF = 16'h1234;

	localparam					   EDU_PCI_CAPPTR = 8'h40;

	localparam					   EDU_PCI_INTERRUPT_PIN = 8'h01;

	localparam					   EDU_PCI_MIN_GNT = 8'h00;
	localparam					   EDU_PCI_MAX_LAT = 8'h00;

	localparam					   EDU_PCI_MSI_CAP_CAPID = 8'h05;
	localparam					   EDU_PCI_MSI_CAP_NEXTPTR = 8'h00;
	localparam					   EDU_PCI_MSI_PER_VECTOR_MASK_CAPABLE = 1'b0;
	localparam					   EDU_PCI_MSI_64BIT_ADDR_CAPABLE = 1'b1;
	localparam					   EDU_PCI_MSI_MULTI_MSI_CAPABLE = 3'b000;
	
	typedef enum [5:0]			   {
									// PCI Configuration Space header registers
									CFG_VENDOR_DEVICE = 6'h00,
									CFG_COMMAND_STATUS = 6'h01,
									CFG_REV_CLASS = 6'h02,
									CFG_CACHE_LATTIMER_HDRTYPE_BIST = 6'h03,
									CFG_BAR0 = 6'h04,
									CFG_BAR1 = 6'h05,
									CFG_BAR2 = 6'h06,
									CFG_BAR3 = 6'h07,
									CFG_BAR4 = 6'h08,
									CFG_BAR5 = 6'h09,
									CFG_CARDBUS_CIS = 6'h0a,
									CFG_SUBSYSTEM_ID = 6'h0b,
									CFG_ROMBAR = 6'h0c,
									CFG_CAPPTR = 6'h0d,
									CFG_INTR_PIN = 6'h0f,
									// MSI capability
									CFG_MSI_CAPHDR_CTRL = 6'h10,
									CFG_MSI_ADDR_LOWER = 6'h11,
									CFG_MSI_ADDR_UPPER = 6'h12,
									CFG_MSI_DATA = 6'h13
									}pci_cfg_reg_t;
	
	reg							   command_intr_disable;
	reg							   command_fast_b2b;
	reg							   command_serr_enable;
	reg							   command_perr_response;
	reg							   command_memwr_invalidate;
	reg							   command_special_cycles;
	reg							   command_bus_master;
	reg							   command_memory_space;
	reg							   command_io_space;

	reg [7:0]					   cacheline_size;
	reg [7:3]					   latency_timer;							   

	reg [31:4]					   bar0;
	
	reg [15:0]					   subsystem_id,subsystem_vendor_id;

	reg [7:0]					   interrupt_line;

	reg [2:0]					   msi_multiple_message;
	reg							   msi_enable;
	reg [63:2]					   msi_address;
	reg [15:0]					   msi_data;
	
	always_ff @(posedge clk) begin
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
			subsystem_id <= EDU_PCI_SUBSYSTEM_ID_DEF;
			subsystem_vendor_id <= EDU_PCI_SUBSYSTEM_VENDOR_ID_DEF;
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
		end else begin
			if(cfg_enable == 1'b1) begin
				if(cfg_iswrite == 1'b0) begin
					case(cfg_offset)
						CFG_VENDOR_DEVICE: cfg_read_val <= {EDU_PCI_DEVICE_ID,EDU_PCI_VENDOR_ID};
						CFG_COMMAND_STATUS: cfg_read_val <= {{
															  detected_parity_error,
															  signaled_system_error,
															  received_master_abort,
															  received_target_abort,
															  signaled_target_abort,
															  EDU_PCI_DEVSEL_TIMING,
															  master_data_parity_error,
															  EDU_PCI_CAPABLE_FASTB2B,
															  1'b0,//reserved
															  EDU_PCI_CAPABLE_66MHZ,
															  EDU_PCI_IMPLEMENT_CAPABILITIES,
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
						CFG_REV_CLASS: cfg_read_val <= {EDU_PCI_CLASS,
														EDU_PCI_SUBCLASS,
														EDU_PCI_PROGIF,
														EDU_PCI_REVISION};
						CFG_CACHE_LATTIMER_HDRTYPE_BIST: cfg_read_val <= {8'h00,//BIST not implemented
																		  {EDU_PCI_MULTIFUNCTION,EDU_PCI_HEADER_TYPE},//header type
																		  {latency_timer,3'b000},//latency timer 
																		  cacheline_size// cacheine size 
																		  };
						CFG_BAR0: cfg_read_val <= {bar0,
												   1'b0,//not prefetchable
												   2'b00,//32-bit space
												   1'b0//memory space
												   };
						CFG_BAR1: cfg_read_val <= 32'h00000000;
						CFG_BAR2: cfg_read_val <= 32'h00000000;
						CFG_BAR3: cfg_read_val <= 32'h00000000;
						CFG_BAR4: cfg_read_val <= 32'h00000000;
						CFG_BAR5: cfg_read_val <= 32'h00000000;
						CFG_CARDBUS_CIS: cfg_read_val <= 32'h00000000;
						CFG_SUBSYSTEM_ID: cfg_read_val <= {subsystem_id,subsystem_vendor_id};
						CFG_ROMBAR: cfg_read_val <= 32'h00000000;
						CFG_CAPPTR: cfg_read_val <= {24'h000000,EDU_PCI_CAPPTR};
						CFG_INTR_PIN: cfg_read_val <= {EDU_PCI_MAX_LAT,
													   EDU_PCI_MIN_GNT,
													   EDU_PCI_INTERRUPT_PIN,
													   interrupt_line
													   };
						CFG_MSI_CAPHDR_CTRL: cfg_read_val <= {{7'b0000000,
															   EDU_PCI_MSI_PER_VECTOR_MASK_CAPABLE,
															   EDU_PCI_MSI_64BIT_ADDR_CAPABLE,
															   msi_multiple_message,
															   EDU_PCI_MSI_MULTI_MSI_CAPABLE,
															   msi_enable},
															  EDU_PCI_MSI_CAP_NEXTPTR,
															  EDU_PCI_MSI_CAP_CAPID};
						CFG_MSI_ADDR_LOWER: cfg_read_val <= {msi_address[31:2],2'b00};
						CFG_MSI_ADDR_UPPER: cfg_read_val <= msi_address[63:32];
						CFG_MSI_DATA: cfg_read_val <= {16'h0000, msi_data};
						default: cfg_read_val <= 32'h00000000;
					endcase // case (offset)
				end
			end // if (cfg_enable == 1'b1)
		end // else: !if(rst = 1'b0)
	end
	
endmodule // pci_cfg
