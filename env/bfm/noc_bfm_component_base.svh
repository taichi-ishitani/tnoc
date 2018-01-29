`ifndef NOC_BFM_COMPONENT_BASE_SVH
`define NOC_BFM_COMPONENT_BASE_SVH
class noc_bfm_component_base #(
  type  BASE  = uvm_component
) extends BASE;
  function void do_begin_tr(uvm_transaction tr, string stream_name, integer tr_handle);
    noc_bfm_packet_item packet_item;
    if ($cast(packet_item, tr)) begin
      packet_item.tr_handle = tr_handle;
    end
  endfunction

  `tue_component_default_constructor(noc_bfm_component_base)
endclass
`endif
