module noc_vc_demux
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  noc_flit_if.target    flit_in_if,
  noc_flit_if.initiator flit_out_if[CHANNELS]
);
  generate for (genvar i = 0;i < CHANNELS;++i) begin
    assign  flit_out_if[i].valid        = flit_in_if.valid[i];
    assign  flit_in_if.ready[i]         = flit_out_if[i].ready;
    assign  flit_out_if[i].flit         = flit_in_if.flit;
    assign  flit_in_if.vc_available[i]  = flit_out_if[i].vc_available;
  end endgenerate
endmodule
