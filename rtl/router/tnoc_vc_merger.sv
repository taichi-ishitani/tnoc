module tnoc_vc_merger
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input logic                 clk,
  input logic                 rst_n,
  input logic [CHANNELS-1:0]  i_vc_grant,
  tnoc_flit_if.target         flit_in_if[CHANNELS],
  tnoc_flit_if.initiator      flit_out_if
);
  localparam  tnoc_port_type  PORT_TYPE = TNOC_INTERNAL_PORT;

  `tnoc_internal_flit_if(CHANNELS)  flit_fifo_if();

  tnoc_vc_mux #(
    .CONFIG     (CONFIG     ),
    .PORT_TYPE  (PORT_TYPE  )
  ) u_vc_mux (
    .i_vc_grant   (i_vc_grant   ),
    .flit_in_if   (flit_in_if   ),
    .flit_out_if  (flit_fifo_if )
  );

  tnoc_flit_if_slicer #(
    .CONFIG     (CONFIG     ),
    .PORT_TYPE  (PORT_TYPE  )
  ) u_output_fifo (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .flit_in_if   (flit_fifo_if ),
    .flit_out_if  (flit_out_if  )
  );
endmodule
