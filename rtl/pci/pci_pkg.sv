package pci_pkg;

	typedef enum logic [5:0] {
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
							  } pci_cfg_reg_offset;
	
endpackage
