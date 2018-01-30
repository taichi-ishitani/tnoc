module tnoc_vc_demux
  import  tnoc_config_pkg::*;
#(
  parameter   tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  tnoc_flit_if.target     flit_in_if,
  tnoc_flit_if.initiator  flit_out_if[CHANNELS]
);
  generate for (genvar i = 0;i < CHANNELS;++i) begin
    assign  flit_out_if[i].valid        = flit_in_if.valid[i];
    assign  flit_in_if.ready[i]         = flit_out_if[i].ready;
    assign  flit_out_if[i].flit         = flit_in_if.flit;
    assign  flit_in_if.vc_available[i]  = flit_out_if[i].vc_available;
  end endgenerate
endmodule
