`ifndef NOC_FABRIC_ENV_MODEL_SVH
`define NOC_FABRIC_ENV_MODEL_SVH
class noc_fabric_env_model extends tue_component #(noc_fabric_env_configuration);
  uvm_analysis_imp #(noc_bfm_packet_item, noc_fabric_env_model) packet_export;
  uvm_analysis_port #(noc_bfm_packet_item)                      packet_port[int][int];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    packet_export = new("packet_export", this);
    for (int y = 0;y < configuration.size_y;++y) begin
      for (int x = 0;x < configuration.size_x;++x) begin
        packet_port[y][x] = new($sformatf("packet_port[%0d][%0d]", y, x), this);
      end
    end
  endfunction

  function void write(noc_bfm_packet_item item);
    noc_bfm_location_id destination_id  = item.destination_id;
    if (!packet_port.exists(destination_id.y)) begin
      return;
    end
    if (!packet_port[destination_id.y].exists(destination_id.x)) begin
      return;
    end
    packet_port[destination_id.y][destination_id.x].write(item);
  endfunction

  `tue_component_default_constructor(noc_fabric_env_model)
  `uvm_component_utils(noc_fabric_env_model)
endclass
`endif
