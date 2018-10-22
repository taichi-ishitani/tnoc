`ifndef TNOC_AXI_TYPES_PKG_SV
`define TNOC_AXI_TYPES_PKG_SV
package tnoc_axi_types_pkg;
  typedef logic [7:0] tnoc_axi_packed_burst_length;
  typedef logic [8:0] tnoc_axi_unpacked_burst_length;

  function automatic tnoc_axi_packed_burst_length pack_burst_length(
    input tnoc_axi_unpacked_burst_length  burst_length
  );
    return tnoc_axi_packed_burst_length'(burst_length - 1);
  endfunction

  function automatic tnoc_axi_unpacked_burst_length unpack_burst_length(
    input tnoc_axi_packed_burst_length  burst_length
  );
    return tnoc_axi_unpacked_burst_length'(burst_length) + 1;
  endfunction

  typedef enum logic [2:0] {
    TNOC_AXI_BURST_SIZE_1_BYTE    = 'b000,
    TNOC_AXI_BURST_SIZE_2_BYTES   = 'b001,
    TNOC_AXI_BURST_SIZE_4_BYTES   = 'b010,
    TNOC_AXI_BURST_SIZE_8_BYTES   = 'b011,
    TNOC_AXI_BURST_SIZE_16_BYTES  = 'b100,
    TNOC_AXI_BURST_SIZE_32_BYTES  = 'b101,
    TNOC_AXI_BURST_SIZE_64_BYTES  = 'b110,
    TNOC_AXI_BURST_SIZE_128_BYTES = 'b111
  } tnoc_axi_burst_size;

  typedef enum logic [1:0] {
    TNOC_AXI_FIXED_BURST        = 'b00,
    TNOC_AXI_INCREMENTING_BURST = 'b01,
    TNOC_AXI_WRAPPING_BURST     = 'b10
  } tnoc_axi_burst_type;

  typedef enum logic [1:0] {
    TNOC_AXI_OKAY         = 'b00,
    TNOC_AXI_EXOKAY       = 'b01,
    TNOC_AXI_SLAVE_ERROR  = 'b10,
    TNOC_AXI_DECODE_ERROR = 'b11
  } tnoc_axi_response;
endpackage
`endif
