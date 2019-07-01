module tnoc_axi_slave_adapter
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG      = TNOC_DEFAULT_CONFIG,
  parameter   int         WRITE_VC    = -1,
  parameter   int         READ_VC     = -1,
  localparam  int         ID_X_WIDTH  = CONFIG.id_x_width,
  localparam  int         ID_Y_WIDTH  = CONFIG.id_y_width,
  localparam  int         VC_WIDTH    = $clog2(CONFIG.virtual_channels)
)(
  input logic                       clk,
  input logic                       rst_n,
  input logic [ID_X_WIDTH-1:0]      i_id_x,
  input logic [ID_Y_WIDTH-1:0]      i_id_y,
  input logic [VC_WIDTH-1:0]        i_write_vc,
  tnoc_address_decoer_if.requester  write_decoder_if,
  input logic [VC_WIDTH-1:0]        i_read_vc,
  tnoc_address_decoer_if.requester  read_decoder_if,
  tnoc_axi_if.slave                 axi_if,
  tnoc_flit_if.initiator            flit_out_if,
  tnoc_flit_if.target               flit_in_if
);
  `include  "tnoc_axi_macros.svh"

  tnoc_flit_if #(CONFIG, 1, TNOC_LOCAL_PORT)  flit_in[2]();
  tnoc_flit_if #(CONFIG, 1, TNOC_LOCAL_PORT)  flit_out[2]();

//--------------------------------------------------------------
//  AXI Write Channels
//--------------------------------------------------------------
  logic [VC_WIDTH-1:0]        write_vc;
  tnoc_axi_write_if #(CONFIG) axi_write_if();


  `tnoc_axi_write_if_renamer(axi_if, axi_write_if)

  if (WRITE_VC < 0) begin
    assign  write_vc  = i_write_vc;
  end
  else begin
    assign  write_vc  = WRITE_VC;
  end

  tnoc_axi_slave_write_adapter #(
    .CONFIG (CONFIG )
  ) u_write_adapter (
    .clk            (clk              ),
    .rst_n          (rst_n            ),
    .i_id_x         (i_id_x           ),
    .i_id_y         (i_id_y           ),
    .i_vc           (write_vc         ),
    .decoder_if     (write_decoder_if ),
    .axi_if         (axi_write_if     ),
    .flit_out_if    (flit_out[0]      ),
    .flit_in_if     (flit_in[0]       )
  );

//--------------------------------------------------------------
//  AXI Read Channels
//--------------------------------------------------------------
  logic [VC_WIDTH-1:0]        read_vc;
  tnoc_axi_read_if #(CONFIG)  axi_read_if();

  `tnoc_axi_read_if_renamer(axi_if, axi_read_if)

  if (READ_VC < 0) begin
    assign  read_vc = i_read_vc;
  end
  else begin
    assign  read_vc = READ_VC;
  end

  tnoc_axi_slave_read_adapter #(
    .CONFIG (CONFIG )
  ) u_read_adapter (
    .clk            (clk              ),
    .rst_n          (rst_n            ),
    .i_id_x         (i_id_x           ),
    .i_id_y         (i_id_y           ),
    .i_vc           (read_vc          ),
    .decoder_if     (read_decoder_if  ),
    .axi_if         (axi_read_if      ),
    .flit_out_if    (flit_out[1]      ),
    .flit_in_if     (flit_in[1]       )
  );

//--------------------------------------------------------------
//  MUX/DEMUX
//--------------------------------------------------------------
  tnoc_axi_write_read_mux #(
    .CONFIG   (CONFIG   ),
    .WRITE_VC (WRITE_VC ),
    .READ_VC  (READ_VC  )
  ) u_write_read_mux (
    .clk            (clk          ),
    .rst_n          (rst_n        ),
    .i_write_vc     (i_write_vc   ),
    .write_flit_if  (flit_out[0]  ),
    .i_read_vc      (i_read_vc    ),
    .read_flit_if   (flit_out[1]  ),
    .flit_out_if    (flit_out_if  )
  );

  tnoc_axi_write_read_demux #(
    .CONFIG     (CONFIG                   ),
    .WRITE_TYPE (TNOC_RESPONSE            ),
    .READ_TYPE  (TNOC_RESPONSE_WITH_DATA  )
  ) u_write_read_demux (
    .clk            (clk        ),
    .rst_n          (rst_n      ),
    .flit_in_if     (flit_in_if ),
    .write_flit_if  (flit_in[0] ),
    .read_flit_if   (flit_in[1] )
  );
endmodule
