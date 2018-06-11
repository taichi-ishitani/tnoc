function automatic logic is_request_header(input tnoc_common_header header);
  return (header.packet_type[7] == '0) ? '1 : '0;
endfunction

function automatic logic is_response_header(input tnoc_common_header header);
  return (header.packet_type[7] == '1) ? '1 : '0;
endfunction

function automatic logic is_packet_with_payload(input tnoc_common_header header);
  return (header.packet_type[6] == '1) ? '1 : '0;
endfunction

function automatic logic is_packet_without_payload(input tnoc_common_header header);
  return (header.packet_type[6] == '0) ? '1 : '0;
endfunction
