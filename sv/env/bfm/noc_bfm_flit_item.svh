`ifndef NOC_BFM_FLIT_ITEM_SVH
`define NOC_BFM_FLIT_ITEM_SVH

typedef tue_sequence_item #(
  noc_bfm_configuration, noc_bfm_status
)  noc_bfm_flit_item_base;

class noc_bfm_flit_item extends noc_bfm_flit_item_base;
  rand  noc_bfm_flit_type flit_type;
  rand  bit               tail;
  rand  noc_bfm_flit_data data;

  function bit is_header_flit();
    return (flit_type == NOC_BFM_HEADER_FLIT) ? '1 : '0;
  endfunction

  function bit is_payload_flit();
    return (flit_type == NOC_BFM_PAYLOAD_FLIT) ? '1 : '0;
  endfunction

  function bit is_tail_flit();
    return tail;
  endfunction

  function void pack_flit(ref noc_bfm_flit flit);
    flit.flit_type  = flit_type;
    flit.tail       = tail;
    flit.data       = data;
  endfunction

  function void unpack_flit(const ref noc_bfm_flit flit);
    flit_type = flit.flit_type;
    tail      = flit.tail;
    data      = flit.data;
  endfunction

  function noc_bfm_flit get_flit();
    noc_bfm_flit  flit;
    pack_flit(flit);
    return flit;
  endfunction

  `tue_object_default_constructor(noc_bfm_flit_item)
  `uvm_object_utils_begin(noc_bfm_flit_item)
    `uvm_field_enum(noc_bfm_flit_type, flit_type, UVM_DEFAULT)
    `uvm_field_int(tail, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass

`endif
