/* wrapper for verilator top level tristate workaround */

`default_nettype none

module edu_verilator_wrapper(
							 //address and data
							 input logic [31:0]	 ad_in,
							 input logic		 ad_in_en,
							 output logic [31:0] ad_out,
							 input logic [3:0]	 cbe_in,
							 input logic		 cbe_in_en,
							 output logic [3:0]	 cbe_out,
							 inout logic		 par,
							 //interface control
							 inout logic		 frame,
							 inout logic		 trdy,
							 inout logic		 irdy,
							 inout logic		 stop,
							 inout logic		 devsel,
							 input logic		 idsel,
							 //error reporting
							 inout logic		 perr,
							 inout logic		 serr,
							 //arbitration
							 output logic		 req,
							 input logic		 gnt,
							 //system
							 input logic		 clk,
							 input logic		 rst,
							 //interface control
							 inout logic		 lock,
							 //interrupts
							 output logic		 inta,
							 output logic		 intb,
							 output logic		 intc,
							 output logic		 intd);

	// AD tristate
	logic [31:0]								 ad;
	assign ad_out=ad;
	assign ad=ad_in_en?ad_in:32'hzzzzzzzz;
	// C/BE tristate
	logic [3:0]									 cbe;
	assign cbe_out=cbe;
	assign cbe=cbe_in_en?cbe_in:4'bzzzz;

`ifdef VERILATOR
	pullup(frame);
	pullup(irdy);
	pullup(trdy);
	pullup(stop);
	pullup(lock);
	pullup(devsel);
	pullup(perr);
`endif
	
	edu pci_edu_device(
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
endmodule // edu_verilator_wrapper
