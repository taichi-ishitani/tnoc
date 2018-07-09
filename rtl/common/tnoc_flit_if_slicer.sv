module tnoc_flit_if_slicer
  `include  "tnoc_default_imports.svh"
#(
  parameter tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
  parameter int             CHANNELS  = CONFIG.virtual_channels,
  parameter tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT
)(
  input logic             clk,
  input logic             rst_n,
  tnoc_flit_if.target     flit_in_if,
  tnoc_flit_if.initiator  flit_out_if
);
  tnoc_flit_if_fifo #(
    .CONFIG     (CONFIG     ),
    .CHANNELS   (CHANNELS   ),
    .DEPTH      (2          ),
    .PORT_TYPE  (PORT_TYPE  )
  ) u_fifo (
    .clk            (clk          ),
    .rst_n          (rst_n        ),
    .i_clear        ('0           ),
    .o_empty        (),
    .o_almost_full  (),
    .o_full         (),
    .flit_in_if     (flit_in_if   ),
    .flit_out_if    (flit_out_if  )
  );
endmodule
