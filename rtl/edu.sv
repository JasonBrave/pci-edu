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
