module tnoc_port_control_if_renamer (
  tnoc_port_control_if.arbitrator arbitrator_if,
  tnoc_port_control_if.requester  requester_if
);
  assign  requester_if.request          = arbitrator_if.request;
  assign  arbitrator_if.grant           = requester_if.grant;
  assign  requester_if.free             = arbitrator_if.free;
  assign  requester_if.start_of_packet  = arbitrator_if.start_of_packet;
  assign  requester_if.end_of_packet    = arbitrator_if.end_of_packet;
endmodule
