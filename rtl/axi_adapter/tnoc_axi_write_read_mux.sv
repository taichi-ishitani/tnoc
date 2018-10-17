module tnoc_axi_write_read_mux
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter   int         WRITE_VC  = -1,
  parameter   int         READ_VC   = -1,
  localparam  int         VC_WIDTH  = $clog2(CONFIG.virtual_channels)
)(
  input logic                 clk,
  input logic                 rst_n,
  input logic [VC_WIDTH-1:0]  i_write_vc,
  tnoc_flit_if.target         write_flit_if,
  input logic [VC_WIDTH-1:0]  i_read_vc,
  tnoc_flit_if.target         read_flit_if,
  tnoc_flit_if.initiator      flit_out_if
);
  `include  "tnoc_macros.svh"

  localparam  int CHANNELS  = CONFIG.virtual_channels;

  logic [CHANNELS-1:0]                        write_ready;
  logic [CHANNELS-1:0]                        read_ready;
  tnoc_flit_if #(CONFIG, 1, TNOC_LOCAL_PORT)  write_read_if[2*CHANNELS]();
  tnoc_flit_if #(CONFIG, 1, TNOC_LOCAL_PORT)  flit_out[CHANNELS]();

//--------------------------------------------------------------
//  Renaming
//--------------------------------------------------------------
  assign  write_flit_if.ready         = (write_ready != '0) ? '1 : '0;
  assign  write_flit_if.vc_available  = '1;
  assign  read_flit_if.ready          = (read_ready  != '0) ? '1 : '0;
  assign  read_flit_if.vc_available   = '1;
  for (genvar i = 0;i < CHANNELS;++i) begin
    if (WRITE_VC < 0) begin
      assign  write_read_if[2*i+0].valid    = (i_write_vc == i) ? write_flit_if.valid        : '0;
      assign  write_ready[i]                = (i_write_vc == i) ? write_read_if[2*i+0].ready : '0;
      assign  write_read_if[2*i+0].flit[0]  = (i_write_vc == i) ? write_flit_if.flit[0]      : '0;
    end
    else if (WRITE_VC == i) begin
      assign  write_read_if[2*i+0].valid    = write_flit_if.valid;
      assign  write_ready[i]                = write_read_if[2*i+0].ready;
      assign  write_read_if[2*i+0].flit[0]  = write_flit_if.flit[0];
    end
    else begin
      assign  write_read_if[2*i+0].valid    = '0;
      assign  write_ready[i]                = '0;
      assign  write_read_if[2*i+0].flit[0]  = '0;
    end

    if (READ_VC < 0) begin
      assign  write_read_if[2*i+1].valid    = (i_read_vc == i) ? read_flit_if.valid         : '0;
      assign  read_ready[i]                 = (i_read_vc == i) ? write_read_if[2*i+1].ready : '0;
      assign  write_read_if[2*i+1].flit[0]  = (i_read_vc == i) ? read_flit_if.flit[0]       : '0;
    end
    else if (READ_VC == i) begin
      assign  write_read_if[2*i+1].valid    = read_flit_if.valid;
      assign  read_ready[i]                 = write_read_if[2*i+1].ready;
      assign  write_read_if[2*i+1].flit[0]  = read_flit_if.flit[0];
    end
    else begin
      assign  write_read_if[2*i+1].valid    = '0;
      assign  read_ready[i]                 = '0;
      assign  write_read_if[2*i+1].flit[0]  = '0;
    end
  end

//--------------------------------------------------------------
//  Write/Read Arbitration
//--------------------------------------------------------------
  localparam  bit DYNAMIC_VC_MAPPING  = ((WRITE_VC < 0) || (READ_VC < 0)) ? '1 : '0;

  for (genvar i = 0;i < CHANNELS;++i) begin : g_arbiter
    if (DYNAMIC_VC_MAPPING || ((i == WRITE_VC) && (i == READ_VC))) begin : g
      tnoc_flit_if_arbiter #(
        .CONFIG     (CONFIG           ),
        .ENTRIES    (2                ),
        .CHANNELS   (1                ),
        .PORT_TYPE  (TNOC_LOCAL_PORT  )
      ) u_arbiter (
        .clk          (clk                                      ),
        .rst_n        (rst_n                                    ),
        .flit_in_if   (`tnoc_array_slicer(write_read_if, i, 2)  ),
        .flit_out_if  (flit_out[i]                              )
      );
    end
    else if (i == WRITE_VC) begin : g
      `tnoc_flit_if_renamer(write_read_if[2*i+0], flit_out[i])
    end
    else if (i == READ_VC) begin : g
      `tnoc_flit_if_renamer(write_read_if[2*i+1], flit_out[i])
    end
    else begin : g
      tnoc_flit_if_dummy_initiator #(
        .CONFIG     (CONFIG           ),
        .CHANNELS   (1                ),
        .PORT_TYPE  (TNOC_LOCAL_PORT  )
      ) u_dummy (
        flit_out[i]
      );
    end
  end
endmodule
