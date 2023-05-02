package pci_pkg;

	// PCI Commands
	typedef enum logic [3:0] {
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
							  } pci_commands_t;

	// PCI Configuration Space header registers
	typedef enum logic [5:0] {
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
							  } pci_cfg_reg_offset;

endpackage
