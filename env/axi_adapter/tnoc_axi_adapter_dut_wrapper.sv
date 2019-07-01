module tnoc_axi_adapter_dut_wrapper
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config CONFIG  = TNOC_DEFAULT_CONFIG
)(
  input logic clk,
  input logic rst_n,
  tvip_axi_if slave_if[3],
  tvip_axi_if master_if[3]
);
  localparam  int ADDRESS_WIDTH = CONFIG.address_width;
  localparam  int ID_X_WIDTH    = CONFIG.id_x_width;
  localparam  int ID_Y_WIDTH    = CONFIG.id_y_width;

  import  tnoc_axi_types_pkg::*;
  import  tvip_axi_types_pkg::*;

  `include  "tnoc_packet_flit_macros.svh"
  `tnoc_define_packet_and_flit(CONFIG)

  localparam  int BFM_IFS = 6 * CONFIG.virtual_channels;
  tnoc_bfm_flit_if  flit_tx_if[BFM_IFS](clk, rst_n);
  tnoc_bfm_flit_if  flit_rx_if[BFM_IFS](clk, rst_n);

  tnoc_flit_if #(CONFIG)  adapter_to_fabric_if[6]();
  tnoc_flit_if #(CONFIG)  fabric_to_adapter_if[6]();

  tnoc_flit_array_if_connector #(
    .CONFIG       (CONFIG ),
    .IFS          (6      ),
    .ACTIVE_MODE  (0      )
  ) u_flit_if_connector (
    .flit_in_if       (adapter_to_fabric_if ),
    .flit_out_if      (fabric_to_adapter_if ),
    .flit_bfm_in_if   (flit_tx_if           ),
    .flit_bfm_out_if  (flit_rx_if           )
  );

  tnoc_vc write_vc[6];
  tnoc_vc read_vc[6];

  always_ff @(negedge rst_n) begin
    for (int i = 0;i < 6;++i) begin
      write_vc[i] <= randomize_vc();
      read_vc[i]  <= randomize_vc();
    end
  end

  function automatic tnoc_vc randomize_vc();
    tnoc_vc vc;
    void'(std::randomize(vc) with {
      vc inside {[0:CONFIG.virtual_channels-1]};
    });
    return vc;
  endfunction

  typedef struct {
    tnoc_location_id  location_id;
    logic             invalid_destination;
  } s_decode_result;

  function automatic s_decode_result decode_address(tnoc_address address);
    s_decode_result result;
    case (address[ADDRESS_WIDTH-1:ADDRESS_WIDTH-2])
      0: begin
        result.location_id.x        = 1;
        result.location_id.y        = 0;
        result.invalid_destination  = 0;
      end
      1: begin
        result.location_id.x        = 0;
        result.location_id.y        = 1;
        result.invalid_destination  = 0;
      end
      2: begin
        result.location_id.x        = 2;
        result.location_id.y        = 1;
        result.invalid_destination  = 0;
      end
      3: begin
        bit invalid_destination;
        int id_x;
        int id_y;
        void'(std::randomize(invalid_destination));
        void'(std::randomize(id_x, id_y) with {
          if (invalid_destination) {
            id_x inside {[0:2]};
            id_y inside {[0:1]};
          }
          else {
            id_x inside {[3:((2**CONFIG.id_x_width) - 1)]};
            id_y inside {[3:((2**CONFIG.id_y_width) - 1)]};
          }
        });
        result.location_id.x        = id_x;
        result.location_id.y        = id_y;
        result.invalid_destination  = invalid_destination;
      end
    endcase
    return result;
  endfunction

  for (genvar i = 0;i < 3;++i) begin : g_slave_adapter
    localparam  int ID_X      = (i == 0) ? 0
                              : (i == 1) ? 2 : 1;
    localparam  int ID_Y      = (i == 0) ? 0
                              : (i == 1) ? 0 : 1;
    localparam  int IF_INDEX  = 3 * ID_Y + ID_X;
    localparam  int WRITE_VC  = (i == 0) ? 0
                              : (i == 1) ? 0 : -1;
    localparam  int READ_VC   = (i == 0) ? 1
                              : (i == 1) ? 0 : -1;

    tnoc_axi_if #(CONFIG)             axi_if();
    tnoc_address_decoer_if #(CONFIG)  write_decoder_if();
    s_decode_result                   write_decode_result;
    tnoc_address_decoer_if #(CONFIG)  read_decoder_if();
    s_decode_result                   read_decode_result;

    assign  write_decode_result       = decode_address(write_decoder_if.address);
    assign  write_decoder_if.id_x     = write_decode_result.location_id.x;
    assign  write_decoder_if.id_y     = write_decode_result.location_id.y;
    assign  write_decoder_if.invalid  = write_decode_result.invalid_destination;
    assign  read_decode_result        = decode_address(read_decoder_if.address);
    assign  read_decoder_if.id_x      = read_decode_result.location_id.x;
    assign  read_decoder_if.id_y      = read_decode_result.location_id.y;
    assign  read_decoder_if.invalid   = read_decode_result.invalid_destination;

    assign  axi_if.awvalid      = slave_if[i].awvalid;
    assign  slave_if[i].awready = axi_if.awready;
    assign  axi_if.awid         = slave_if[i].awid;
    assign  axi_if.awaddr       = slave_if[i].awaddr;
    assign  axi_if.awlen        = slave_if[i].awlen;
    assign  axi_if.awsize       = tnoc_axi_burst_size'(slave_if[i].awsize);
    assign  axi_if.awburst      = tnoc_axi_burst_type'(slave_if[i].awburst);
    assign  axi_if.wvalid       = slave_if[i].wvalid;
    assign  slave_if[i].wready  = axi_if.wready;
    assign  axi_if.wdata        = slave_if[i].wdata;
    assign  axi_if.wstrb        = slave_if[i].wstrb;
    assign  axi_if.wlast        = slave_if[i].wlast;
    assign  slave_if[i].bvalid  = axi_if.bvalid;
    assign  axi_if.bready       = slave_if[i].bready;
    assign  slave_if[i].bid     = axi_if.bid;
    assign  slave_if[i].bresp   = tvip_axi_response'(axi_if.bresp);
    assign  axi_if.arvalid      = slave_if[i].arvalid;
    assign  slave_if[i].arready = axi_if.arready;
    assign  axi_if.arid         = slave_if[i].arid;
    assign  axi_if.araddr       = slave_if[i].araddr;
    assign  axi_if.arlen        = slave_if[i].arlen;
    assign  axi_if.arsize       = tnoc_axi_burst_size'(slave_if[i].arsize);
    assign  axi_if.arburst      = tnoc_axi_burst_type'(slave_if[i].arburst);
    assign  slave_if[i].rvalid  = axi_if.rvalid;
    assign  axi_if.rready       = slave_if[i].rready;
    assign  slave_if[i].rid     = axi_if.rid;
    assign  slave_if[i].rdata   = axi_if.rdata;
    assign  slave_if[i].rresp   = tvip_axi_response'(axi_if.rresp);
    assign  slave_if[i].rlast   = axi_if.rlast;

    tnoc_axi_slave_adapter #(
      .CONFIG   (CONFIG   ),
      .WRITE_VC (WRITE_VC ),
      .READ_VC  (READ_VC  )
    ) u_adapter (
      .clk              (clk                            ),
      .rst_n            (rst_n                          ),
      .i_id_x           (ID_X[ID_X_WIDTH-1:0]           ),
      .i_id_y           (ID_Y[ID_Y_WIDTH-1:0]           ),
      .i_write_vc       (write_vc[3*0+i]                ),
      .write_decoder_if (write_decoder_if               ),
      .i_read_vc        (read_vc[3*0+i]                 ),
      .read_decoder_if  (read_decoder_if                ),
      .axi_if           (axi_if                         ),
      .flit_out_if      (adapter_to_fabric_if[IF_INDEX] ),
      .flit_in_if       (fabric_to_adapter_if[IF_INDEX] )
    );
  end

  for (genvar i = 0;i < 3;++i) begin : g_master_adapter
    localparam  int ID_X              = (i == 0) ? 1
                                      : (i == 1) ? 0 : 2;
    localparam  int ID_Y              = (i == 0) ? 0
                                      : (i == 1) ? 1 : 1;
    localparam  int IF_INDEX          = 3 * ID_Y + ID_X;
    localparam  int WRITE_VC          = (i == 0) ? 0
                                      : (i == 1) ? 0 : -1;
    localparam  int READ_VC           = (i == 0) ? 1
                                      : (i == 1) ? 0 : -1;
    localparam  bit READ_INTERLEAVING = (i == 2) ? 1 : 0;

    tnoc_axi_if #(CONFIG) axi_if();
    assign  master_if[i].awvalid  = axi_if.awvalid;
    assign  axi_if.awready        = master_if[i].awready;
    assign  master_if[i].awid     = axi_if.awid;
    assign  master_if[i].awaddr   = axi_if.awaddr;
    assign  master_if[i].awlen    = axi_if.awlen;
    assign  master_if[i].awsize   = tvip_axi_burst_size'(axi_if.awsize);
    assign  master_if[i].awburst  = tvip_axi_burst_type'(axi_if.awburst);
    assign  master_if[i].wvalid   = axi_if.wvalid;
    assign  axi_if.wready         = master_if[i].wready;
    assign  master_if[i].wdata    = axi_if.wdata;
    assign  master_if[i].wstrb    = axi_if.wstrb;
    assign  master_if[i].wlast    = axi_if.wlast;
    assign  axi_if.bvalid         = master_if[i].bvalid;
    assign  master_if[i].bready   = axi_if.bready;
    assign  axi_if.bid            = master_if[i].bid;
    assign  axi_if.bresp          = tnoc_axi_response'(master_if[i].bresp);
    assign  master_if[i].arvalid  = axi_if.arvalid;
    assign  axi_if.arready        = master_if[i].arready;
    assign  master_if[i].arid     = axi_if.arid;
    assign  master_if[i].araddr   = axi_if.araddr;
    assign  master_if[i].arlen    = axi_if.arlen;
    assign  master_if[i].arsize   = tvip_axi_burst_size'(axi_if.arsize);
    assign  master_if[i].arburst  = tvip_axi_burst_type'(axi_if.arburst);
    assign  axi_if.rvalid         = master_if[i].rvalid;
    assign  master_if[i].rready   = axi_if.rready;
    assign  axi_if.rid            = master_if[i].rid;
    assign  axi_if.rdata          = master_if[i].rdata;
    assign  axi_if.rresp          = tnoc_axi_response'(master_if[i].rresp);
    assign  axi_if.rlast          = master_if[i].rlast;

    tnoc_axi_master_adapter #(
      .CONFIG             (CONFIG             ),
      .WRITE_VC           (WRITE_VC           ),
      .READ_VC            (READ_VC            ),
      .READ_INTERLEAVING  (READ_INTERLEAVING  )
    ) u_adapter (
      .clk          (clk                            ),
      .rst_n        (rst_n                          ),
      .i_id_x       (ID_X[ID_X_WIDTH-1:0]           ),
      .i_id_y       (ID_Y[ID_Y_WIDTH-1:0]           ),
      .i_write_vc   (write_vc[3*1+i]                ),
      .i_read_vc    (read_vc[3*1+i]                 ),
      .axi_if       (axi_if                         ),
      .flit_out_if  (adapter_to_fabric_if[IF_INDEX] ),
      .flit_in_if   (fabric_to_adapter_if[IF_INDEX] )
    );
  end

  tnoc_fabric #(CONFIG) u_fabric (
    .clk          (clk                  ),
    .rst_n        (rst_n                ),
    .flit_in_if   (adapter_to_fabric_if ),
    .flit_out_if  (fabric_to_adapter_if )
  );
endmodule
