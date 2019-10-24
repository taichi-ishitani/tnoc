`ifndef TNOC_AXI_PKG_SV
`define TNOC_AXI_PKG_SV
package tnoc_axi_pkg;
  function automatic int get_id_width(
    tnoc_pkg::tnoc_packet_config  packet_config
  );
    return (
      tnoc_pkg::get_location_id_width(packet_config) +
      tnoc_pkg::get_tag_width(packet_config)
    );
  endfunction

  typedef logic [7:0] tnoc_axi_burst_length;
  typedef logic [8:0] tnoc_axi_unpacked_burst_length;

  function automatic tnoc_axi_burst_length pack_burst_length(
    tnoc_axi_unpacked_burst_length  burst_length
  );
    return tnoc_axi_burst_length'(burst_length - 1);
  endfunction

  function automatic tnoc_axi_unpacked_burst_length unpack_burst_length(
    tnoc_axi_burst_length burst_length
  );
    return tnoc_axi_unpacked_burst_length'(burst_length) + 1;
  endfunction

  typedef enum logic [2:0] {
    TNOC_AXI_BURST_SIZE_1_BYTE    = 0,
    TNOC_AXI_BURST_SIZE_2_BYTES   = 1,
    TNOC_AXI_BURST_SIZE_4_BYTES   = 2,
    TNOC_AXI_BURST_SIZE_8_BYTES   = 3,
    TNOC_AXI_BURST_SIZE_16_BYTES  = 4,
    TNOC_AXI_BURST_SIZE_32_BYTES  = 5,
    TNOC_AXI_BURST_SIZE_64_BYTES  = 6,
    TNOC_AXI_BURST_SIZE_128_BYTES = 7
  } tnoc_axi_burst_size;

  typedef enum logic [1:0] {
    TNOC_AXI_FIXED_BURST        = 0,
    TNOC_AXI_INCREMENTING_BURST = 1,
    TNOC_AXI_WRAP_BURST         = 2
  } tnoc_axi_burst_type;

  typedef enum logic [1:0] {
    TNOC_AXI_OKAY         = 0,
    TNOC_AXI_EXOKAY       = 1,
    TNOC_AXI_SLAVE_ERROR  = 2,
    TNOC_AXI_DECODE_ERROR = 3
  } tnoc_axi_response;
endpackage
`endif
