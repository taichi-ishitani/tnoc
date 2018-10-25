module tnoc_flit_if_fifo
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config     CONFIG      = TNOC_DEFAULT_CONFIG,
  parameter   int             CHANNELS    = CONFIG.virtual_channels,
  parameter   int             DEPTH       = 8,
  parameter   int             THRESHOLD   = DEPTH,
  parameter   bit             DATA_FF_OUT = 0,
  parameter   tnoc_port_type  PORT_TYPE   = TNOC_LOCAL_PORT,
  localparam  int             FLITS       = (is_local_port(PORT_TYPE)) ? CHANNELS : 1
)(
  input   logic             clk,
  input   logic             rst_n,
  input   logic             i_clear,
  output  logic [FLITS-1:0] o_empty,
  output  logic [FLITS-1:0] o_almost_full,
  output  logic [FLITS-1:0] o_full,
  tnoc_flit_if.target       flit_in_if,
  tnoc_flit_if.initiator    flit_out_if
);
  `include  "tnoc_packet.svh"
  `include  "tnoc_flit.svh"

  typedef struct packed {
    logic [CHANNELS-1:0]        valid;
    logic [TNOC_FLIT_WIDTH-1:0] flit;
  } s_fifo_data;

  logic [FLITS-1:0] empty;
  logic [FLITS-1:0] almost_full;
  logic [FLITS-1:0] full;

  assign  o_empty       = empty;
  assign  o_almost_full = almost_full;
  assign  o_full        = full;

  if (is_local_port(PORT_TYPE)) begin : g_local_port
    for (genvar i = 0;i < FLITS;++i) begin : g_fifo
      assign  flit_in_if.ready[i]         = ~full[i];
      assign  flit_in_if.vc_available[i]  = ~almost_full[i];
      assign  flit_out_if.valid[i]        = ~empty[i];

      tbcm_fifo #(
        .DATA_TYPE    (tnoc_flit    ),
        .DEPTH        (DEPTH        ),
        .THRESHOLD    (THRESHOLD    ),
        .DATA_FF_OUT  (DATA_FF_OUT  ),
        .FLAG_FF_OUT  (1            )
      ) u_fifo (
        .clk            (clk                  ),
        .rst_n          (rst_n                ),
        .i_clear        (i_clear              ),
        .o_empty        (empty[i]             ),
        .o_almost_full  (almost_full[i]       ),
        .o_full         (full[i]              ),
        .i_push         (flit_in_if.valid[i]  ),
        .i_data         (flit_in_if.flit[i]   ),
        .i_pop          (flit_out_if.ready[i] ),
        .o_data         (flit_out_if.flit[i]  )
      );
    end
  end
  else if (CHANNELS == 1) begin : g_internal_port_vc_eq_1
    assign  flit_in_if.ready        = ~full;
    assign  flit_in_if.vc_available = ~almost_full;
    assign  flit_out_if.valid       = ~empty;

    tbcm_fifo #(
      .DATA_TYPE    (tnoc_flit    ),
      .DEPTH        (DEPTH        ),
      .THRESHOLD    (THRESHOLD    ),
      .DATA_FF_OUT  (DATA_FF_OUT  ),
      .FLAG_FF_OUT  (1            )
    ) u_fifo (
      .clk            (clk                  ),
      .rst_n          (rst_n                ),
      .i_clear        (i_clear              ),
      .o_empty        (empty                ),
      .o_almost_full  (almost_full          ),
      .o_full         (full                 ),
      .i_push         (flit_in_if.valid     ),
      .i_data         (flit_in_if.flit[0]   ),
      .i_pop          (flit_out_if.ready    ),
      .o_data         (flit_out_if.flit[0]  )
    );
  end
  else begin : g_internal_port_vc_gt_1
    logic       push;
    s_fifo_data push_data;
    logic       pop;
    s_fifo_data pop_data;

    assign  flit_in_if.ready        = {CHANNELS{~full       }};
    assign  flit_in_if.vc_available = {CHANNELS{~almost_full}};
    assign  flit_out_if.valid       = (!empty) ? pop_data.valid : '0;
    assign  flit_out_if.flit[0]     = pop_data.flit;

    assign  push            = |flit_in_if.valid;
    assign  push_data.valid = flit_in_if.valid;
    assign  push_data.flit  = flit_in_if.flit[0];
    assign  pop             = |(flit_out_if.valid & flit_out_if.ready);

    tbcm_fifo #(
      .DATA_TYPE    (s_fifo_data  ),
      .DEPTH        (DEPTH        ),
      .THRESHOLD    (THRESHOLD    ),
      .DATA_FF_OUT  (DATA_FF_OUT  ),
      .FLAG_FF_OUT  (1            )
    ) u_fifo (
      .clk            (clk          ),
      .rst_n          (rst_n        ),
      .i_clear        (i_clear      ),
      .o_empty        (empty        ),
      .o_almost_full  (almost_full  ),
      .o_full         (full         ),
      .i_push         (push         ),
      .i_data         (push_data    ),
      .i_pop          (pop          ),
      .o_data         (pop_data     )
    );
  end
endmodule
