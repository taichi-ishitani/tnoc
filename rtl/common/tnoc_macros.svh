`ifndef TNOC_MACROS_SVH
`define TNOC_MACROS_SVH

`define tnoc_array_slicer(ARRAY, INDEX, ELEMENTS) ARRAY[INDEX*ELEMENTS:(INDEX+1)*ELEMENTS-1]

`define tnoc_flit_ack(FLIT_IF)  (FLIT_IF.valid & FLIT_IF.ready)

`define tnoc_internal_flit_if(channel) \
tnoc_flit_if #(CONFIG, channel, TNOC_INTERNAL_PORT)

`define tnoc_flit_if_renamer(flit_in_if, flit_out_if) \
assign  flit_out_if.valid       = flit_in_if.valid; \
assign  flit_in_if.ready        = flit_out_if.ready; \
assign  flit_out_if.flit        = flit_in_if.flit; \
assign  flit_in_if.vc_available = flit_out_if.vc_available; \

`define tnoc_flit_array_if_renamer(flit_in_if, flit_out_if, size) \
for (genvar __i = 0;__i < size;++__i) begin \
  assign  flit_out_if[__i].valid        = flit_in_if[__i].valid; \
  assign  flit_in_if[__i].ready         = flit_out_if[__i].ready; \
  assign  flit_out_if[__i].flit         = flit_in_if[__i].flit; \
  assign  flit_in_if[__i].vc_available  = flit_out_if[__i].vc_available; \
end

`define tnoc_port_control_if_renamer(arbitrator_if, requester_if) \
assign  requester_if.request          = arbitrator_if.request; \
assign  arbitrator_if.grant           = requester_if.grant; \
assign  requester_if.free             = arbitrator_if.free; \
assign  requester_if.start_of_packet  = arbitrator_if.start_of_packet; \
assign  requester_if.end_of_packet    = arbitrator_if.end_of_packet; \

`endif
