/* verilator lint_off UNUSED */

`default_nettype none

module pci_busif(
				 //address and data
				 inout logic [31:0]	 ad,
				 inout logic [3:0]	 cbe,
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
				 output logic		 intd,
				 //PCI configuration space
				 output logic		 cfg_enable,
				 output logic		 cfg_iswrite,
				 output logic [5:0]	 cfg_offset,
				 output logic [31:0] cfg_write_val,
				 input logic [31:0]	 cfg_read_val);

	// PCI bus FSM states
	enum							 {IDLE,
									  CFG_READ_WAIT_BE,
									  CFG_READ_WAIT_IRDY,
									  CFG_READ_COMP} state, next_state;

	// PCI Commands
	enum [3:0]						 {
									  PCI_CMD_INTR_ACK=4'b0000,
									  PCI_CMD_SPECIAL_CYCLE=4'b0001,
									  PCI_CMD_IO_READ=4'b0010,
									  PCI_CMD_IO_WRITE=4'b0011,
									  PCI_CMD_MEM_READ=4'b0110,
									  PCI_CMD_MEM_WRITE=4'b0111,
									  PCI_CMD_CFG_READ=4'b1010,
									  PCI_CMD_CFG_WRITE=4'b1011,
									  PCI_CMD_MEM_READ_MULTIPLE=4'b1100,
									  PCI_CMD_DUAL_ADDR_CYCLE=4'b1101,
									  PCI_CMD_MEM_READ_LINE=4'b1110,
									  PCI_CMD_MEM_WRITE_INVALIDATE=4'b1111
									  }pci_commands_t;

	// AD tri state buffer
	logic [31:0]					 ad_in,ad_out;
	logic							 ad_en;
	assign ad_in = ad;
	assign ad = ad_en ? ad_out : 32'hzzzzzzzz;
	// C/BE tri state buffer
	logic [3:0]						 cbe_in,cbe_out;
	logic							 cbe_en;
	assign cbe_in=cbe;
	assign cbe = cbe_en?cbe_out:4'bzzzz;
	//parity tri state logic
	logic							 par_in,par_out,par_en;
	assign par_in=par;
	assign par=par_en?par_out:1'bz;
	//frame tri state logic
	logic							 frame_in,frame_out,frame_en;
	assign frame_in=frame;
	assign frame=frame_en?frame_out:1'bz;
	//irdy tri state logic
	logic							 irdy_in,irdy_out,irdy_en;
	assign irdy_in=irdy;
	assign irdy=irdy_en?irdy_out:1'bz;
	//trdy tri state logic
	logic							 trdy_in,trdy_out,trdy_en;
	assign trdy_in=trdy;
	assign trdy=trdy_en?trdy_out:1'bz;
	//stop tri state logic
	logic							 stop_in,stop_out,stop_en;
	assign stop_in=stop;
	assign stop=stop_en?stop_out:1'bz;
	//lock tri state logic
	logic							 lock_in,lock_out,lock_en;
	assign lock_in=lock;
	assign lock=lock_en?lock_out:1'bz;
	//devsel tri state logic
	logic							 devsel_in,devsel_out,devsel_en;
	assign devsel_in=devsel;
	assign devsel=devsel_en?devsel_out:1'bz;
	
	always_ff @(posedge clk) begin
		if(rst == 1'b0) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

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
		next_state = state;
		cfg_enable=1'b0;
		cfg_iswrite=1'b0;
		cfg_offset=6'h00;
		cfg_write_val=32'h0000000;
		case(state)
			IDLE: begin
				if(frame==1'b0) begin
					if((idsel == 1'b1) && (cbe_in == PCI_CMD_CFG_READ) && (ad_in[1:0] == 2'b00)&&(ad_in[10:8]==3'b000)) begin
						next_state = CFG_READ_WAIT_BE;
						cfg_enable = 1'b1;
						cfg_offset=ad_in[7:2];
					end
				end
			end
			CFG_READ_WAIT_BE: begin
				next_state=CFG_READ_WAIT_IRDY;
			end
			CFG_READ_WAIT_IRDY: begin
				if(irdy == 1'b0) begin
					trdy_en=1'b1;
					trdy_out=1'b0;
					devsel_en=1'b1;
					devsel_out=1'b0;
					ad_out = cfg_read_val;
					ad_en = 1'b1;
					next_state = CFG_READ_COMP;
				end
			end
			CFG_READ_COMP: begin
				trdy_en=1'b1;
				trdy_out=1'b0;
				devsel_en=1'b1;
				devsel_out=1'b0;
				ad_out = cfg_read_val;
				ad_en = 1'b1;
				next_state = IDLE;
			end
			default: next_state=IDLE;
		endcase // case (state)
	end
	
	//drive interrupt lines
	assign inta = 1'bz;
	assign intb = 1'bz;
	assign intc = 1'bz;
	assign intd = 1'bz;
	//drive master request line
	assign req = 1'bz;
	
endmodule // pci_busif
