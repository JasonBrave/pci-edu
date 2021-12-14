/* verilator lint_off UNUSED */

`default_nettype none

module pci_cfg(input logic clk,
			   input logic		   rst,
			   input logic		   cfg_enable,
			   input logic		   cfg_iswrite,
			   input logic [5:0]   cfg_offset,
			   input logic [31:0]  cfg_write_val,
			   output logic [31:0] cfg_read_val);

	always_ff @(posedge clk) begin
		if(cfg_enable == 1'b1) begin
			if(cfg_iswrite == 1'b0) begin
				case(cfg_offset)
					6'h00: cfg_read_val <= 32'h12345678;
					default: cfg_read_val <= 32'hffffffff;
				endcase // case (offset)
			end
		end
	end
	
endmodule // pci_cfg
