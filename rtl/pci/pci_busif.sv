/*
 * PCI Edu device PCI bus interface module
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

import pci_pkg::pci_commands_t;

module pci_busif(
				 //address and data
				 input logic [31:0]	 ad_in,
				 output logic [31:0] ad_out,
				 output logic		 ad_en,
				 input logic [3:0]	 cbe_in,
				 output logic [3:0]	 cbe_out,
				 output logic		 cbe_en,
				 input logic		 par_in,
				 output logic		 par_out,
				 output logic		 par_en,
				 //interface control
				 input logic		 frame_in,
				 output logic		 frame_out,
				 output logic		 frame_en,
				 input logic		 trdy_in,
				 output logic		 trdy_out,
				 output logic		 trdy_en,
				 input logic		 irdy_in,
				 output logic		 irdy_out,
				 output logic		 irdy_en,
				 input logic		 stop_in,
				 output logic		 stop_out,
				 output logic		 stop_en,
				 input logic		 devsel_in,
				 output logic		 devsel_out,
				 output logic		 devsel_en,
				 input logic		 idsel,
				 //error reporting
				 input logic		 perr_in,
				 output logic		 perr_out,
				 output logic		 perr_en,
				 input logic		 serr_in,
				 output logic		 serr_out,
				 output logic		 serr_en,
				 //arbitration
				 output logic		 req,
				 input logic		 gnt,
				 //system
				 input logic		 clk,
				 input logic		 rst,
				 //interface control
				 input logic		 lock_in,
				 output logic		 lock_out,
				 output logic		 lock_en,
				 //interrupts
				 output logic		 inta,
				 output logic		 intb,
				 output logic		 intc,
				 output logic		 intd,
				 //PCI configuration space register interface
				 output logic		 cfg_enable,
				 output logic		 cfg_iswrite,
				 output logic [5:0]	 cfg_offset,
				 output logic [31:0] cfg_write_val,
				 output logic [3:0]	 cfg_be,
				 input logic [31:0]	 cfg_read_val,
				 input logic		 cfg_done,
				 input logic		 cfg_w_err,
				 //PCI configuration registers
				 output logic		 parity_error_detected,
				 input logic		 parity_error_response_reg,
				 input logic		 serr_enable_reg);

	// PCI bus FSM states
	typedef enum logic [3:0]							 {
														  IDLE,
														  CFG_READ_BE,
														  CFG_READ_WAIT_IRDY,
														  CFG_READ_COMP,
														  CFG_WRITE_DATA_BE,
														  CFG_WRITE_WAIT,
														  OTHER_TRANS,
														  ADDR_PAR_ERR,
														  DATA_PAR_ERR
														  } pci_fsm_state_t;

	pci_fsm_state_t state, next_state;

	logic calculated_parity, parity_match;

	always_ff @(posedge clk, negedge rst) begin
		if(rst == 1'b0) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

	// Parity check logic
	always_comb begin
		calculated_parity = ^{ad_in, cbe_in};
		parity_match = (calculated_parity == par_in);
	end

	// State transition logic
	always_comb begin
		ad_en = 1'b0;
		ad_out = 32'h00000000;
		cbe_en=1'b0;
		cbe_out=4'b0000;
		par_en=1'b0;
		par_out=1'b0;
		frame_en=1'b0;
		frame_out=1'b1;
		irdy_en=1'b0;
		irdy_out=1'b1;
		trdy_en=1'b0;
		trdy_out=1'b1;
		devsel_en=1'b0;
		devsel_out=1'b1;
		stop_en=1'b0;
		stop_out=1'b1;
		lock_en=1'b0;
		lock_out=1'b1;
		perr_en=1'b0;
		perr_out=1'b0;
		serr_en=1'b0;
		serr_out=1'b0;
		next_state = state;

		parity_error_detected = 1'b0;
		
		case(state)
			IDLE: begin
				if(frame_in==1'b0) begin
					case(cbe_in)
						pci_pkg::PCI_CMD_CFG_READ: begin
							if(idsel == 1'b1) begin
								if((ad_in[1:0] == 2'b00) && (ad_in[10:8]==3'b000)) begin
									next_state = CFG_READ_BE;
								end
							end else begin
								next_state = OTHER_TRANS;
							end
						end
						pci_pkg::PCI_CMD_CFG_WRITE: begin
							if(idsel == 1'b1) begin
								if((ad_in[1:0] == 2'b00) && (ad_in[10:8]==3'b000)) begin
									next_state = CFG_WRITE_DATA_BE;
								end
							end else begin
								next_state = OTHER_TRANS;
							end
						end
						default: begin
						end
					endcase // case (cbe_in)
				end
			end

			CFG_READ_BE: begin
				if(parity_match == 1'b1) begin
					next_state = CFG_READ_WAIT_IRDY;
				end else begin
					next_state = ADDR_PAR_ERR;
				end
			end

			CFG_READ_WAIT_IRDY: begin
				if(parity_match == 1'b1) begin
					if(irdy_in == 1'b0) begin
						trdy_en=1'b1;
						trdy_out=1'b0;
						devsel_en=1'b1;
						devsel_out=1'b0;
						ad_out = cfg_read_val;
						ad_en = 1'b1;
						par_en = 1'b1;
						par_out = ^{cfg_read_val, cbe_in};
						next_state = CFG_READ_COMP;
					end
				end else begin // if (parity_match == 1'b1)
					next_state = DATA_PAR_ERR;
				end // else: !if(parity_match == 1'b1)
			end

			CFG_READ_COMP: begin
				trdy_en=1'b1;
				trdy_out=1'b0;
				devsel_en=1'b1;
				devsel_out=1'b0;
				ad_out = cfg_read_val;
				ad_en = 1'b1;
				par_en = 1'b1;
				par_out = ^{cfg_read_val, cbe_in};
				next_state = IDLE;
			end

			CFG_WRITE_DATA_BE: begin
				if(irdy_in == 1'b0) begin
					trdy_en=1'b1;
					trdy_out=1'b0;
					devsel_en=1'b1;
					devsel_out=1'b0;
					next_state = IDLE;
				end
			end

			ADDR_PAR_ERR: begin
				parity_error_detected = 1'b1;
				
				if(serr_enable_reg == 1'b1) begin
					serr_out = 1'b0;
					serr_en = 1'b1;
				end
				
				perr_out = 1'b0;
				perr_en = 1'b1;

				// TODO: Terminate transaction if device selected
				
				next_state = IDLE;
			end

			DATA_PAR_ERR: begin
				parity_error_detected = 1'b1;
				
				if(parity_error_response_reg == 1'b1) begin
					perr_out = 1'b0;
					perr_en = 1'b1;
				end
				
				next_state = IDLE;
			end

			OTHER_TRANS: begin
				if(frame_in == 1'b1) begin
					next_state = IDLE;
				end
			end
			
			default: next_state=IDLE;
		endcase // case (state)
	end

	// Drive configuration register interface
	always_ff @(posedge clk) begin
		if(next_state == CFG_READ_BE) begin
			cfg_offset <= ad_in[7:2];
			cfg_iswrite <= 1'b0;
		end else if(next_state == CFG_READ_WAIT_IRDY) begin
			cfg_be <= cbe_in;
			cfg_enable <= 1'b1;
		end
		cfg_write_val <= 32'h00000000;
	end
	
	//drive interrupt lines
	assign inta = 1'b0;
	assign intb = 1'b0;
	assign intc = 1'b0;
	assign intd = 1'b0;
	//drive master request line
	assign req = 1'b0;
	
endmodule // pci_busif
