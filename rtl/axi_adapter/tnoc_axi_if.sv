`ifndef TNOC_AXI_IF_SV
`define TNOC_AXI_IF_SV
interface tnoc_axi_if
  import  tnoc_config_pkg::*,
          tnoc_axi_types_pkg::*;
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)();
  localparam  int ID_WIDTH      = CONFIG.id_x_width
                                + CONFIG.id_y_width
                                + $clog2(CONFIG.tags);
  localparam  int ADDRESS_WIDTH = CONFIG.address_width;
  localparam  int DATA_WIDTH    = CONFIG.data_width;

  //  Write Address
  logic                         awvalid;
  logic                         awready;
  logic                         awack;
  logic [ID_WIDTH-1:0]          awid;
  logic [ADDRESS_WIDTH-1:0]     awaddr;
  tnoc_axi_packed_burst_length  awlen;
  tnoc_axi_burst_size           awsize;
  tnoc_axi_burst_type           awburst;
  //  Write Data
  logic                         wvalid;
  logic                         wready;
  logic                         wack;
  logic [DATA_WIDTH-1:0]        wdata;
  logic [DATA_WIDTH/8-1:0]      wstrb;
  logic                         wlast;
  //  Write Response
  logic                         bvalid;
  logic                         bready;
  logic                         back;
  logic [ID_WIDTH-1:0]          bid;
  tnoc_axi_response             bresp;
  //  Read Address
  logic                         arvalid;
  logic                         arready;
  logic                         arack;
  logic [ID_WIDTH-1:0]          arid;
  logic [ADDRESS_WIDTH-1:0]     araddr;
  tnoc_axi_packed_burst_length  arlen;
  tnoc_axi_burst_size           arsize;
  tnoc_axi_burst_type           arburst;
  //  Read Response
  logic                         rvalid;
  logic                         rready;
  logic                         rack;
  logic [ID_WIDTH-1:0]          rid;
  logic [DATA_WIDTH-1:0]        rdata;
  tnoc_axi_response             rresp;
  logic                         rlast;

  assign  awack = (awvalid && awready) ? '1 : '0;
  assign  wack  = (wvalid  && wready ) ? '1 : '0;
  assign  back  = (bvalid  && bready ) ? '1 : '0;
  assign  arack = (arvalid && arready) ? '1 : '0;
  assign  rack  = (rvalid  && rready ) ? '1 : '0;

  modport master (
    output  awvalid,
    input   awready,
    input   awack,
    output  awid,
    output  awaddr,
    output  awlen,
    output  awsize,
    output  awburst,
    output  wvalid,
    input   wready,
    input   wack,
    output  wdata,
    output  wstrb,
    output  wlast,
    input   bvalid,
    output  bready,
    input   back,
    input   bid,
    input   bresp,
    output  arvalid,
    input   arready,
    input   arack,
    output  arid,
    output  araddr,
    output  arlen,
    output  arsize,
    output  arburst,
    input   rvalid,
    output  rready,
    input   rack,
    input   rid,
    input   rdata,
    input   rresp,
    input   rlast
  );

  modport slave (
    input   awvalid,
    output  awready,
    output  awack,
    input   awid,
    input   awaddr,
    input   awlen,
    input   awsize,
    input   awburst,
    input   wvalid,
    output  wready,
    output  wack,
    input   wdata,
    input   wstrb,
    input   wlast,
    output  bvalid,
    input   bready,
    output  back,
    output  bid,
    output  bresp,
    input   arvalid,
    output  arready,
    output  arack,
    input   arid,
    input   araddr,
    input   arlen,
    input   arsize,
    input   arburst,
    output  rvalid,
    input   rready,
    output  rack,
    output  rid,
    output  rdata,
    output  rresp,
    output  rlast
  );

  modport monitor (
    input awvalid,
    input awready,
    input awack,
    input awid,
    input awaddr,
    input awlen,
    input awsize,
    input awburst,
    input wvalid,
    input wready,
    input wack,
    input wdata,
    input wstrb,
    input wlast,
    input bvalid,
    input bready,
    input back,
    input bid,
    input bresp,
    input arvalid,
    input arready,
    input arack,
    input arid,
    input araddr,
    input arlen,
    input arsize,
    input arburst,
    input rvalid,
    input rready,
    input rack,
    input rid,
    input rdata,
    input rresp,
    input rlast
  );
endinterface

interface tnoc_axi_write_if
  import  tnoc_config_pkg::*,
          tnoc_axi_types_pkg::*;
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)();
  localparam  int ID_WIDTH      = CONFIG.id_x_width
                                + CONFIG.id_y_width
                                + $clog2(CONFIG.tags);
  localparam  int ADDRESS_WIDTH = CONFIG.address_width;
  localparam  int DATA_WIDTH    = CONFIG.data_width;

  //  Write Address
  logic                         awvalid;
  logic                         awready;
  logic                         awack;
  logic [ID_WIDTH-1:0]          awid;
  logic [ADDRESS_WIDTH-1:0]     awaddr;
  tnoc_axi_packed_burst_length  awlen;
  tnoc_axi_burst_size           awsize;
  tnoc_axi_burst_type           awburst;
  //  Write Data
  logic                         wvalid;
  logic                         wready;
  logic                         wack;
  logic [DATA_WIDTH-1:0]        wdata;
  logic [DATA_WIDTH/8-1:0]      wstrb;
  logic                         wlast;
  //  Write Response
  logic                         bvalid;
  logic                         bready;
  logic                         back;
  logic [ID_WIDTH-1:0]          bid;
  tnoc_axi_response             bresp;

  assign  awack = (awvalid && awready) ? '1 : '0;
  assign  wack  = (wvalid  && wready ) ? '1 : '0;
  assign  back  = (bvalid  && bready ) ? '1 : '0;

  modport master (
    output  awvalid,
    input   awready,
    input   awack,
    output  awid,
    output  awaddr,
    output  awlen,
    output  awsize,
    output  awburst,
    output  wvalid,
    input   wready,
    input   wack,
    output  wdata,
    output  wstrb,
    output  wlast,
    input   bvalid,
    output  bready,
    input   back,
    input   bid,
    input   bresp
  );

  modport slave (
    input   awvalid,
    output  awready,
    output  awack,
    input   awid,
    input   awaddr,
    input   awlen,
    input   awsize,
    input   awburst,
    input   wvalid,
    output  wready,
    output  wack,
    input   wdata,
    input   wstrb,
    input   wlast,
    output  bvalid,
    input   bready,
    output  back,
    output  bid,
    output  bresp
  );

  modport monitor (
    input awvalid,
    input awready,
    input awack,
    input awid,
    input awaddr,
    input awlen,
    input awsize,
    input awburst,
    input wvalid,
    input wready,
    input wack,
    input wdata,
    input wstrb,
    input wlast,
    input bvalid,
    input bready,
    input back,
    input bid,
    input bresp
  );
endinterface

interface tnoc_axi_read_if
  import  tnoc_config_pkg::*,
          tnoc_axi_types_pkg::*;
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)();
  localparam  int ID_WIDTH      = CONFIG.id_x_width
                                + CONFIG.id_y_width
                                + $clog2(CONFIG.tags);
  localparam  int ADDRESS_WIDTH = CONFIG.address_width;
  localparam  int DATA_WIDTH    = CONFIG.data_width;

  //  Read Address
  logic                         arvalid;
  logic                         arready;
  logic                         arack;
  logic [ID_WIDTH-1:0]          arid;
  logic [ADDRESS_WIDTH-1:0]     araddr;
  tnoc_axi_packed_burst_length  arlen;
  tnoc_axi_burst_size           arsize;
  tnoc_axi_burst_type           arburst;
  //  Read Response
  logic                         rvalid;
  logic                         rready;
  logic                         rack;
  logic [ID_WIDTH-1:0]          rid;
  logic [DATA_WIDTH-1:0]        rdata;
  tnoc_axi_response             rresp;
  logic                         rlast;

  assign  arack = (arvalid && arready) ? '1 : '0;
  assign  rack  = (rvalid  && rready ) ? '1 : '0;

  modport master (
    output  arvalid,
    input   arready,
    input   arack,
    output  arid,
    output  araddr,
    output  arlen,
    output  arsize,
    output  arburst,
    input   rvalid,
    output  rready,
    input   rack,
    input   rid,
    input   rdata,
    input   rresp,
    input   rlast
  );

  modport slave (
    input   arvalid,
    output  arready,
    output  arack,
    input   arid,
    input   araddr,
    input   arlen,
    input   arsize,
    input   arburst,
    output  rvalid,
    input   rready,
    output  rack,
    output  rid,
    output  rdata,
    output  rresp,
    output  rlast
  );

  modport monitor (
    input arvalid,
    input arready,
    input arack,
    input arid,
    input araddr,
    input arlen,
    input arsize,
    input arburst,
    input rvalid,
    input rready,
    input rack,
    input rid,
    input rdata,
    input rresp,
    input rlast
  );
endinterface
`endif
