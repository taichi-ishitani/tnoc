`ifndef TNOC_AXI_MACROS_SVH
`define TNOC_AXI_MACROS_SVH

`define tnoc_axi_define_types(CONFIG) \
typedef struct packed { \
  tnoc_location_id  location_id; \
  tnoc_tag          tag; \
} tnoc_axi_id;

`define tnoc_axi_write_if_renamer(SLAVE_IF, MASTER_IF) \
assign  MASTER_IF.awvalid = SLAVE_IF.awvalid; \
assign  SLAVE_IF.awready  = MASTER_IF.awready; \
assign  MASTER_IF.awid    = SLAVE_IF.awid; \
assign  MASTER_IF.awaddr  = SLAVE_IF.awaddr; \
assign  MASTER_IF.awlen   = SLAVE_IF.awlen; \
assign  MASTER_IF.awsize  = SLAVE_IF.awsize; \
assign  MASTER_IF.awburst = SLAVE_IF.awburst; \
assign  MASTER_IF.wvalid  = SLAVE_IF.wvalid; \
assign  SLAVE_IF.wready   = MASTER_IF.wready; \
assign  MASTER_IF.wdata   = SLAVE_IF.wdata; \
assign  MASTER_IF.wstrb   = SLAVE_IF.wstrb; \
assign  MASTER_IF.wlast   = SLAVE_IF.wlast; \
assign  SLAVE_IF.bvalid   = MASTER_IF.bvalid; \
assign  MASTER_IF.bready  = SLAVE_IF.bready; \
assign  SLAVE_IF.bid      = MASTER_IF.bid; \
assign  SLAVE_IF.bresp    = MASTER_IF.bresp;

`define tnoc_axi_read_if_renamer(SLAVE_IF, MASTER_IF) \
assign  MASTER_IF.arvalid = SLAVE_IF.arvalid; \
assign  SLAVE_IF.arready  = MASTER_IF.arready; \
assign  MASTER_IF.arid    = SLAVE_IF.arid; \
assign  MASTER_IF.araddr  = SLAVE_IF.araddr; \
assign  MASTER_IF.arlen   = SLAVE_IF.arlen; \
assign  MASTER_IF.arsize  = SLAVE_IF.arsize; \
assign  MASTER_IF.arburst = SLAVE_IF.arburst; \
assign  SLAVE_IF.rvalid   = MASTER_IF.rvalid; \
assign  MASTER_IF.rready  = SLAVE_IF.rready; \
assign  SLAVE_IF.rid      = MASTER_IF.rid; \
assign  SLAVE_IF.rdata    = MASTER_IF.rdata; \
assign  SLAVE_IF.rresp    = MASTER_IF.rresp; \
assign  SLAVE_IF.rlast    = MASTER_IF.rlast;

`endif
