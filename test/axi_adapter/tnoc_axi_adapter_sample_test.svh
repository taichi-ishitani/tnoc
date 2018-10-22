`ifndef TNOC_AXI_ADAPTER_SAMPLE_TEST_SVH
`define TNOC_AXI_ADAPTER_SAMPLE_TEST_SVH
class tnoc_axi_adapter_sample_test_sequence extends tnoc_axi_adapter_test_sequence_base;
  task body();
    foreach (p_sequencer.axi_master_sequencer[i, j]) begin
      fork
        automatic int ii  = i;
        automatic int jj  = j;
        do_access(ii, jj);
      join_none
    end
    wait fork;
  endtask

  task do_access(int y , int x);
    tvip_axi_master_sequencer sequencer;
    sequencer = p_sequencer.axi_master_sequencer[y][x];
    for (int i = 0;i < 30;++i) begin
      tvip_axi_master_access_sequence write_sequence;
      tvip_axi_master_access_sequence read_sequence;
      `uvm_do_on_with(write_sequence, sequencer, {
        access_type == TVIP_AXI_WRITE_ACCESS;
      })
      `uvm_do_on_with(read_sequence, sequencer, {
        access_type  == TVIP_AXI_READ_ACCESS;
        address      == write_sequence.address;
        burst_size   == write_sequence.burst_size;
        burst_length == write_sequence.burst_length;
      })
    end
  endtask

  `tue_object_default_constructor(tnoc_axi_adapter_sample_test_sequence)
  `uvm_object_utils(tnoc_axi_adapter_sample_test_sequence)
endclass

class tnoc_axi_adapter_sample_test extends tnoc_axi_adapter_test_base;
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    set_default_sequence(sequencer, "main_phase", tnoc_axi_adapter_sample_test_sequence::type_id::get());
  endfunction
  `tue_component_default_constructor(tnoc_axi_adapter_sample_test)
  `uvm_component_utils(tnoc_axi_adapter_sample_test)
endclass
`endif
