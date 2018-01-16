function automatic logic is_header_flit(input noc_flit flit);
  return (flit.flit_type == NOC_HEADER_FLIT) ? '1 : '0;
endfunction

function automatic logic is_payload_flit(input noc_flit flit);
  return (flit.flit_type == NOC_PAYLOAD_FLIT);
endfunction

function automatic logic is_tail_flit(input noc_flit flit);
  return flit.tail;
endfunction

function automatic noc_common_header get_common_header(input noc_flit flit);
  return noc_common_header'(flit.data[COMMON_HEADER_WIDTH-1:0]);
endfunction

function automatic noc_request_header get_request_header(input noc_flit flit);
  return noc_request_header'(flit.data[REQUEST_HEADER_WIDTH-1:0]);
endfunction

function automatic noc_response_header get_response_header(input noc_flit flit);
  return noc_response_header'(flit.data[RESPONSE_HEADER_WIDTH-1:0]);
endfunction

function automatic noc_payload get_payload(input noc_flit flit);
  return noc_payload'(flit.data[PAYLOD_WIDTH-1:0]);
endfunction

function automatic noc_flit set_common_header(input noc_flit flit, input noc_common_header header);
  noc_flit  flit_out;
  flit_out                                = flit;
  flit_out.data[COMMON_HEADER_WIDTH-1:0]  = header;
  return flit;
endfunction
