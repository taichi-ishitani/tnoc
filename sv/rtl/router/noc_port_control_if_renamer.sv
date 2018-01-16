module noc_port_control_if_renamer (
  noc_port_control_if.arbitrator  arbitrator_if,
  noc_port_control_if.requester   requester_if
);
  assign  requester_if.port_request = arbitrator_if.port_request;
  assign  arbitrator_if.port_grant  = requester_if.port_grant;
  assign  requester_if.port_free    = arbitrator_if.port_free;
  assign  requester_if.vc_request   = arbitrator_if.vc_request;
  assign  arbitrator_if.vc_grant    = requester_if.vc_grant;
  assign  requester_if.vc_free      = arbitrator_if.vc_free;
endmodule
