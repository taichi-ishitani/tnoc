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
