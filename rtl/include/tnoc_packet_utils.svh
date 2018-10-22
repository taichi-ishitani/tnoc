function automatic logic is_request_header(input tnoc_common_header header);
  return is_request_packet_type(header.packet_type);
endfunction

function automatic logic is_posted_request_header(input tnoc_common_header header);
  return is_posted_request_packet_type(header.packet_type);
endfunction

function automatic logic is_non_posted_request_header(input tnoc_common_header header);
  return is_non_posted_request_packet_type(header.packet_type);
endfunction

function automatic logic is_response_header(input tnoc_common_header header);
  return is_response_packet_type(header.packet_type);
endfunction

function automatic logic is_packet_with_payload(input tnoc_common_header header);
  return is_with_payload_packet_type(header.packet_type);
endfunction

function automatic logic is_no_payload_packet(input tnoc_common_header header);
  return is_no_payload_packet_type(header.packet_type);
endfunction

function automatic tnoc_packed_burst_length pack_burst_length(
  input tnoc_unpacked_burst_length  unpacked_burst_length
);
  return  unpacked_burst_length[TNOC_PACKED_BURST_LENGTH_WIDTH-1:0];
endfunction

function automatic tnoc_unpacked_burst_length unpack_burst_length(
  input tnoc_packed_burst_length  packed_burst_length
);
  if (packed_burst_length == 0) begin
    return  2**TNOC_PACKED_BURST_LENGTH_WIDTH;
  end
  else begin
    return  packed_burst_length;
  end
endfunction
