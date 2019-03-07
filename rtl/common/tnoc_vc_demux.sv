module tnoc_vc_demux
  `include  "tnoc_default_imports.svh"
#(
  parameter
    tnoc_config     CONFIG    = TNOC_DEFAULT_CONFIG,
    tnoc_port_type  PORT_TYPE = TNOC_LOCAL_PORT,
  localparam
    int             CHANNELS  = CONFIG.virtual_channels
)(
  tnoc_flit_if.target     flit_in_if,
  tnoc_flit_if.initiator  flit_out_if[CHANNELS]
);
  if (is_local_port(PORT_TYPE)) begin
    for (genvar i = 0;i < CHANNELS;++i) begin
      assign  flit_out_if[i].valid        = flit_in_if.valid[i];
      assign  flit_in_if.ready[i]         = flit_out_if[i].ready;
      assign  flit_out_if[i].flit         = flit_in_if.flit[i];
      assign  flit_in_if.vc_available[i]  = flit_out_if[i].vc_available;
    end
  end
  else begin
    for (genvar i = 0;i < CHANNELS;++i) begin
      assign  flit_out_if[i].valid        = flit_in_if.valid[i];
      assign  flit_in_if.ready[i]         = flit_out_if[i].ready;
      assign  flit_out_if[i].flit         = flit_in_if.flit;
      assign  flit_in_if.vc_available[i]  = flit_out_if[i].vc_available;
    end
  end
endmodule
