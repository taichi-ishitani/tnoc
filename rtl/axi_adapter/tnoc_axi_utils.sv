interface tnoc_axi_utils
  import  tnoc_pkg::*,
          tnoc_axi_pkg::*;
#(
  parameter tnoc_packet_config  PACKET_CONFIG = TNOC_DEFAULT_PACKET_CONFIG,
  parameter tnoc_axi_config     AXI_CONFIG    = TNOC_DEFAULT_AXI_CONFIG
)(
  tnoc_types      packet_types,
  tnoc_axi_types  axi_types
);
  typedef packet_types.tnoc_byte_size               tnoc_byte_size;
  typedef packet_types.tnoc_address                 tnoc_address;
  typedef packet_types.tnoc_byte_length             tnoc_byte_length;
  typedef packet_types.tnoc_byte_end                tnoc_byte_end;
  typedef packet_types.tnoc_header_fields           tnoc_header_fields;
  typedef axi_types.tnoc_axi_address                tnoc_axi_address;

  function automatic tnoc_address align_address(
    tnoc_axi_address    address,
    tnoc_axi_burst_size burst_size
  );
    tnoc_axi_address  mask;
    mask  = '1;
    mask  = mask << burst_size;
    return tnoc_address'(address & mask);
  endfunction

  function automatic tnoc_byte_length calc_byte_length(
    tnoc_axi_burst_length burst_length,
    tnoc_axi_burst_size   burst_size
  );
    tnoc_axi_unpacked_burst_length  unpacked_length;
    tnoc_byte_length                byte_length;
    unpacked_length = tnoc_axi_unpacked_burst_length'(burst_length) + 8'd1;
    byte_length     = tnoc_byte_length'(unpacked_length << burst_size);
    return byte_length;
  endfunction

  localparam  tnoc_axi_burst_size MAX_BURST_SIZE  =
    tnoc_axi_burst_size'($clog2(AXI_CONFIG.data_width) - 3);

  function automatic tnoc_axi_burst_size clip_burst_size(
    tnoc_byte_size  byte_size
  );
    tnoc_axi_burst_size burst_size;
    burst_size  = tnoc_axi_burst_size'(byte_size);
    if (burst_size >= MAX_BURST_SIZE) begin
      return MAX_BURST_SIZE;
    end
    else begin
      return burst_size;
    end
  endfunction

  function automatic tnoc_axi_burst_size get_burst_size(
    tnoc_header_fields  header
  );
    return clip_burst_size(header.byte_size);
  endfunction

  localparam  tnoc_byte_length  BURST_SIZE_OFFSET[8]  = '{
    tnoc_byte_length'(0), tnoc_byte_length'(1), tnoc_byte_length'(3), tnoc_byte_length'(7),
    tnoc_byte_length'(15), tnoc_byte_length'(31), tnoc_byte_length'(63), tnoc_byte_length'(127)
  };

  function automatic tnoc_axi_burst_length calc_burst_length(
    tnoc_header_fields  header
  );
    tnoc_axi_burst_size             burst_size;
    tnoc_byte_length                mask_and_offset;
    tnoc_axi_unpacked_burst_length  burst_length;
    burst_size      = get_burst_size(header);
    mask_and_offset = BURST_SIZE_OFFSET[burst_size];
    burst_length    = (
      (header.address & mask_and_offset) + header.byte_length + mask_and_offset
    ) >> burst_size;
    return tnoc_axi_burst_length'(burst_length - 9'd1);
  endfunction
endinterface
