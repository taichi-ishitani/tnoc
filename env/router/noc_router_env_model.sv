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
    bit [3:0] result;

    result[0] = (item.destination_id.x > configuration.id_x) ? '1 : '0;
    result[1] = (item.destination_id.x < configuration.id_x) ? '1 : '0;
    result[2] = (item.destination_id.y > configuration.id_y) ? '1 : '0;
    result[3] = (item.destination_id.y < configuration.id_y) ? '1 : '0;

    if (item.routing_mode == NOC_BFM_X_Y_ROUTING) begin
      case (1)
        result[0]:  packet_port[0].write(item);
        result[1]:  packet_port[1].write(item);
        result[2]:  packet_port[2].write(item);
        result[3]:  packet_port[3].write(item);
        default:    packet_port[4].write(item);
      endcase
    end
    else begin
      case (1)
        result[2]:  packet_port[2].write(item);
        result[3]:  packet_port[3].write(item);
        result[0]:  packet_port[0].write(item);
        result[1]:  packet_port[1].write(item);
        default:    packet_port[4].write(item);
      endcase
    end
  endfunction

  `tue_component_default_constructor(noc_router_env_model)
  `uvm_component_utils(noc_router_env_model)
endclass
`endif
