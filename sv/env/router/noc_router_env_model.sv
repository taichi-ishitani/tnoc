`ifndef NOC_ROUTER_ENV_MODEL_SVH
`define NOC_ROUTER_ENV_MODEL_SVH
class noc_router_env_model extends tue_component #(noc_router_env_configuration);
  uvm_analysis_imp #(noc_bfm_packet_item, noc_router_env_model) packet_export;
  uvm_analysis_port #(noc_bfm_packet_item)                      packet_port[5];

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    packet_export = new("packet_export", this);
    foreach (packet_port[i]) begin
      packet_port[i]  = new($sformatf("packet_port[%0d]", i), this);
    end
  endfunction

  function void write(noc_bfm_packet_item item);
    case (1)
      (item.destination_id.x > configuration.id_x):
        packet_port[0].write(item);
      (item.destination_id.x < configuration.id_x):
        packet_port[1].write(item);
      (item.destination_id.y > configuration.id_y):
        packet_port[2].write(item);
      (item.destination_id.y < configuration.id_y):
        packet_port[3].write(item);
      default:
        packet_port[4].write(item);
    endcase
  endfunction

  `tue_component_default_constructor(noc_router_env_model)
  `uvm_component_utils(noc_router_env_model)
endclass
`endif
