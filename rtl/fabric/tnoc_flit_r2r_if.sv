interface tnoc_flit_r2r_if
  import  tnoc_pkg::*;
#(
  parameter tnoc_packet_config  PACKET_CONFIG = TNOC_DEFAULT_PACKET_CONFIG
)(
  tnoc_types  types
);
  tnoc_flit_if #(
    .PACKET_CONFIG  (PACKET_CONFIG      ),
    .PORT_TYPE      (TNOC_INTERNAL_PORT )
  ) p2m_if(types);

  tnoc_flit_if #(
    .PACKET_CONFIG  (PACKET_CONFIG      ),
    .PORT_TYPE      (TNOC_INTERNAL_PORT )
  ) m2p_if(types);
endinterface
