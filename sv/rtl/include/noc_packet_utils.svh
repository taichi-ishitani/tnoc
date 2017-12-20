function logic is_request_header(input noc_common_header header);
  return (header.packet_type[7] == '0) ? '1 : '0;
endfunction

function logic is_response_header(input noc_common_header header);
  return (header.packet_type[7] == '1) ? '1 : '0;
endfunction
