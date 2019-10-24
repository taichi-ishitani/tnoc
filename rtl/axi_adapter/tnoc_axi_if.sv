`ifndef TNOC_AXI_IF_SV
`define TNOC_AXI_IF_SV
interface tnoc_axi_if
  import  tnoc_pkg::*,
          tnoc_axi_pkg::*;
#(
  parameter tnoc_packet_config  PACKET_CONFIG = TNOC_DEFAULT_PACKET_CONFIG
);
  localparam  int ID_WIDTH      = get_id_width(PACKET_CONFIG);
  localparam  int ADDRESS_WIDTH = PACKET_CONFIG.address_width;
  localparam  int DATA_WIDTH    = PACKET_CONFIG.data_width;

  //  Write Address Channel
  logic                     awvalid;
  logic                     awready;
  logic [ID_WIDTH-1:0]      awid;
  logic [ADDRESS_WIDTH-1:0] awaddr;
  tnoc_axi_burst_length     awlen;
  tnoc_axi_burst_size       awsize;
  tnoc_axi_burst_type       awburst;
  //  Write Data Channel
  logic                     wvalid;
  logic                     wready;
  logic [DATA_WIDTH-1:0]    wdata;
  logic [DATA_WIDTH/8-1:0]  wstrb;
  logic                     wlast;
  //  Write Response Channel
  logic                     bvalid;
  logic                     bready;
  logic [ID_WIDTH-1:0]      bid;
  tnoc_axi_response         bresp;
  //  Read Address Channel
  logic                     arvalid;
  logic                     arready;
  logic [ID_WIDTH-1:0]      arid;
  logic [ADDRESS_WIDTH-1:0] araddr;
  tnoc_axi_burst_length     arlen;
  tnoc_axi_burst_size       arsize;
  tnoc_axi_burst_type       arburst;
  //  Read Response Channel
  logic                     rvalid;
  logic                     rready;
  logic [ID_WIDTH-1:0]      rid;
  logic [DATA_WIDTH-1:0]    rdata;
  tnoc_axi_response         rresp;
  logic                     rlast;

  function automatic logic get_awchannel_ack();
    return awvalid & awready;
  endfunction

  function automatic logic get_wchannel_ack();
    return wvalid & wready;
  endfunction

  function automatic logic get_bchannel_ack();
    return bvalid & bready;
  endfunction

  function automatic logic get_archannel_ack();
    return arvalid & arready;
  endfunction

  function automatic logic get_rchannel_ack();
    return rvalid & rready;
  endfunction

  modport master (
    output  awvalid,
    input   awready,
    output  awid,
    output  awaddr,
    output  awlen,
    output  awsize,
    output  awburst,
    output  wvalid,
    input   wready,
    output  wdata,
    output  wstrb,
    output  wlast,
    input   bvalid,
    output  bready,
    input   bid,
    input   bresp,
    output  arvalid,
    input   arready,
    output  arid,
    output  araddr,
    output  arlen,
    output  arsize,
    output  arburst,
    input   rvalid,
    output  rready,
    input   rid,
    input   rdata,
    input   rresp,
    input   rlast,
    import  get_awchannel_ack,
    import  get_wchannel_ack,
    import  get_bchannel_ack,
    import  get_archannel_ack,
    import  get_rchannel_ack
  );

  modport master_write (
    output  awvalid,
    input   awready,
    output  awid,
    output  awaddr,
    output  awlen,
    output  awsize,
    output  awburst,
    output  wvalid,
    input   wready,
    output  wdata,
    output  wstrb,
    output  wlast,
    input   bvalid,
    output  bready,
    input   bid,
    input   bresp,
    import  get_awchannel_ack,
    import  get_wchannel_ack,
    import  get_bchannel_ack
  );

  modport master_read (
    output  arvalid,
    input   arready,
    output  arid,
    output  araddr,
    output  arlen,
    output  arsize,
    output  arburst,
    input   rvalid,
    output  rready,
    input   rid,
    input   rdata,
    input   rresp,
    input   rlast,
    import  get_archannel_ack,
    import  get_rchannel_ack
  );

  modport slave (
    input   awvalid,
    output  awready,
    input   awid,
    input   awaddr,
    input   awlen,
    input   awsize,
    input   awburst,
    input   wvalid,
    output  wready,
    input   wdata,
    input   wstrb,
    input   wlast,
    output  bvalid,
    input   bready,
    output  bid,
    output  bresp,
    input   arvalid,
    output  arready,
    input   arid,
    input   araddr,
    input   arlen,
    input   arsize,
    input   arburst,
    output  rvalid,
    input   rready,
    output  rid,
    output  rdata,
    output  rresp,
    output  rlast,
    import  get_awchannel_ack,
    import  get_wchannel_ack,
    import  get_bchannel_ack,
    import  get_archannel_ack,
    import  get_rchannel_ack
  );

  modport slave_write (
    input   awvalid,
    output  awready,
    input   awid,
    input   awaddr,
    input   awlen,
    input   awsize,
    input   awburst,
    input   wvalid,
    output  wready,
    input   wdata,
    input   wstrb,
    input   wlast,
    output  bvalid,
    input   bready,
    output  bid,
    output  bresp,
    import  get_awchannel_ack,
    import  get_wchannel_ack,
    import  get_bchannel_ack
  );

  modport slave_read (
    input   arvalid,
    output  arready,
    input   arid,
    input   araddr,
    input   arlen,
    input   arsize,
    input   arburst,
    output  rvalid,
    input   rready,
    output  rid,
    output  rdata,
    output  rresp,
    output  rlast,
    import  get_archannel_ack,
    import  get_rchannel_ack
  );
endinterface
`endif
