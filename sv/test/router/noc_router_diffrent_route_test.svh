`ifndef NOC_ROUTER_DIFFRENT_ROUTE_TEST_SEQUENCE_SVH
`define NOC_ROUTER_DIFFRENT_ROUTE_TEST_SEQUENCE_SVH
class noc_router_diffrent_route_test_sequence extends noc_router_test_sequence_base;
  noc_bfm_location_id sources[2];
  noc_bfm_location_id destinations[2];

  task body();
    setup();
    fork
      do_noc_accesses(sources[0], destinations[0]);
      do_noc_accesses(sources[1], destinations[1]);
    join
  endtask

  function void setup();
    noc_bfm_location_id port_list[5]  = '{
      '{x: 2, y: 1}, '{x: 0, y: 1},
      '{x: 1, y: 2}, '{x: 1, y: 0},
      '{x: 1, y: 1}
    };

    port_list.shuffle();
    sources[0]  = port_list[0];
    sources[1]  = port_list[1];

    port_list.shuffle();
    destinations[0] = port_list[0];
    destinations[1] = port_list[1];
  endfunction

  task do_noc_accesses(
    noc_bfm_location_id source,
    noc_bfm_location_id destination
  );
    int index;

    foreach (configuration.bfm_cfg[i]) begin
      if (
        (configuration.bfm_cfg[i].id_x == source.x) &&
        (configuration.bfm_cfg[i].id_y == source.y)
      ) begin
        index = i;
        break;
      end
    end

    repeat (20) begin
      noc_bfm_packet_item packet_item;
      `uvm_do_on_with(packet_item, p_sequencer.bfm_sequencer[index], {
        destination_id == local::destination;
      })
    end
  endtask

  `tue_object_default_constructor(noc_router_diffrent_route_test_sequence)
  `uvm_object_utils(noc_router_diffrent_route_test_sequence)
endclass

class noc_router_diffrent_route_test extends noc_router_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    set_default_sequence(sequencer, "main_phase", noc_router_diffrent_route_test_sequence::type_id::get());
  endfunction

  `tue_component_default_constructor(noc_router_diffrent_route_test)
  `uvm_component_utils(noc_router_diffrent_route_test)
endclass
`endif
