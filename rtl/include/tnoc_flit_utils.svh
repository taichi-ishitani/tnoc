function automatic logic is_header_flit(input tnoc_flit flit);
  return (flit.flit_type == TNOC_HEADER_FLIT) ? '1 : '0;
endfunction

function automatic logic is_payload_flit(input tnoc_flit flit);
  return (flit.flit_type == TNOC_PAYLOAD_FLIT);
endfunction

function automatic logic is_head_flit(input tnoc_flit flit);
  return flit.head;
endfunction

function automatic logic is_tail_flit(input tnoc_flit flit);
  return flit.tail;
endfunction

function automatic tnoc_common_header get_common_header(input tnoc_flit flit);
  return tnoc_common_header'(flit.data[COMMON_HEADER_WIDTH-1:0]);
endfunction

function automatic tnoc_payload get_payload(input tnoc_flit flit);
  return tnoc_payload'(flit.data[PAYLOD_WIDTH-1:0]);
endfunction

function automatic tnoc_flit set_common_header(input tnoc_flit flit, input tnoc_common_header header);
  tnoc_flit flit_out;
  flit_out                                = flit;
  flit_out.data[COMMON_HEADER_WIDTH-1:0]  = header;
  return flit;
endfunction
