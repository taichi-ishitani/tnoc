`ifndef TNOC_BFM_FLIT_ITEM_SVH
`define TNOC_BFM_FLIT_ITEM_SVH

typedef tue_sequence_item #(
  tnoc_bfm_configuration, tnoc_bfm_status
)  tnoc_bfm_flit_item_base;

class tnoc_bfm_flit_item extends tnoc_bfm_flit_item_base;
  rand  tnoc_bfm_flit_type  flit_type;
  rand  bit                 head;
  rand  bit                 tail;
  rand  tnoc_bfm_flit_data  data;

  function bit is_header_flit();
    return (flit_type == TNOC_BFM_HEADER_FLIT) ? '1 : '0;
  endfunction

  function bit is_payload_flit();
    return (flit_type == TNOC_BFM_PAYLOAD_FLIT) ? '1 : '0;
  endfunction

  function bit is_head_flit();
    return head;
  endfunction

  function bit is_tail_flit();
    return tail;
  endfunction

  function void pack_flit(ref tnoc_bfm_flit flit);
    flit.flit_type  = flit_type;
    flit.head       = head;
    flit.tail       = tail;
    flit.data       = data;
  endfunction

  function void unpack_flit(const ref tnoc_bfm_flit flit);
    flit_type = flit.flit_type;
    head      = flit.head;
    tail      = flit.tail;
    data      = flit.data;
  endfunction

  function tnoc_bfm_flit get_flit();
    tnoc_bfm_flit  flit;
    pack_flit(flit);
    return flit;
  endfunction

  `tue_object_default_constructor(tnoc_bfm_flit_item)
  `uvm_object_utils_begin(tnoc_bfm_flit_item)
    `uvm_field_enum(tnoc_bfm_flit_type, flit_type, UVM_DEFAULT)
    `uvm_field_int(tail, UVM_DEFAULT | UVM_BIN)
    `uvm_field_int(data, UVM_DEFAULT | UVM_HEX)
  `uvm_object_utils_end
endclass

`endif
