module tnoc_output_switch
  `include  "tnoc_default_imports.svh"
#(
  parameter
    tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
    tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT,
    int             CHANNELS  = CONFIG.virtual_channels
)(
  input   logic           clk,
  input   logic           rst_n,
  tnoc_flit_if.target     flit_in_if[5],
  tnoc_flit_if.initiator  flit_out_if,
  input   logic [4:0]     i_output_grant,
  output  logic           o_output_free
);
  `include  "tnoc_macros.svh"
  `include  "tnoc_packet_flit_macros.svh"
  `tnoc_define_packet_and_flit(CONFIG)

  logic [4:0]                       port_free;
  `tnoc_internal_flit_if(CHANNELS)  flit_mux_if();

  assign  o_output_free = |port_free;
  for (genvar i = 0;i < 5;++i) begin
    if (CHANNELS >= 2) begin
      assign  port_free[i]  = |(flit_in_if[i].valid & flit_in_if[i].ready);
    end
    else begin
      assign  port_free[i]  = flit_in_if[i].valid & flit_in_if[i].ready;
    end
  end

  tnoc_flit_if_mux #(
    .CONFIG     (CONFIG     ),
    .CHANNELS   (CHANNELS   ),
    .ENTRIES    (5          ),
    .PORT_TYPE  (PORT_TYPE  )
  ) u_output_mux (
    .i_select     (i_output_grant ),
    .flit_in_if   (flit_in_if     ),
    .flit_out_if  (flit_mux_if    )
  );

  tnoc_flit_if_slicer #(
    .CONFIG     (CONFIG     ),
    .CHANNELS   (CHANNELS   ),
    .PORT_TYPE  (PORT_TYPE  )
  ) u_output_slicer (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .flit_in_if   (flit_mux_if  ),
    .flit_out_if  (flit_out_if  )
  );
endmodule
