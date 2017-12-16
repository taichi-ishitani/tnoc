module top();
  timeunit  1ns/1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_config_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;
  import  noc_router_tests_pkg::*;

  localparam  noc_config  CONFIG  = NOC_DEFAULT_CONFIG;

  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  bit clk = 0;
  initial begin
    forever #(0.5ns) begin
      clk ^= 1;
    end
  end

  bit rst_n = 1;
  initial begin
    rst_n = 0;
    #(20ns);
    rst_n = 1;
  end

  noc_flit_if flit_in_if();
  noc_flit_if flit_out_if();

  noc_bfm_flit_if bfm_flit_in_if (clk, rst_n);
  noc_bfm_flit_if bfm_flit_out_if (clk, rst_n);

  assign  flit_in_if.valid      = bfm_flit_in_if.valid;
  assign  flit_in_if.flit       = convert_to_dut_flit(bfm_flit_in_if.flit);
  assign  bfm_flit_in_if.ready  = flit_in_if.ready;

  assign  bfm_flit_out_if.valid = flit_out_if.valid;
  assign  bfm_flit_out_if.flit  = convert_to_bfm_flit(flit_out_if.flit);
  assign  flit_out_if.ready     = bfm_flit_out_if.ready;
  assign  bfm_flit_out_if.ready = '1;

  function automatic noc_flit convert_to_dut_flit(input noc_bfm_flit bfm_flit);
    noc_flit  dut_flit;
    dut_flit.flit_type  = noc_flit_type'(bfm_flit.flit_type);
    dut_flit.tail       = bfm_flit.tail;
    dut_flit.data       = bfm_flit.data;
    return dut_flit;
  endfunction

  function automatic noc_bfm_flit convert_to_bfm_flit(input noc_flit dut_flit);
    noc_bfm_flit  bfm_flit;
    bfm_flit.flit_type  = noc_bfm_flit_type'(dut_flit.flit_type);
    bfm_flit.tail       = dut_flit.tail;
    bfm_flit.data       = dut_flit.data;
    return bfm_flit;
  endfunction

  noc_input_fifo u_dut (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .flit_in_if   (flit_in_if   ),
    .flit_out_if  (flit_out_if  )
  );

  initial begin
    noc_bfm_configuration cfg = new();
    assert(cfg.randomize() with {
      address_width == NOC_DEFAULT_CONFIG.address_width;
      data_width    == NOC_DEFAULT_CONFIG.data_width;
      id_x_width    == NOC_DEFAULT_CONFIG.id_x_width;
      id_y_width    == NOC_DEFAULT_CONFIG.id_y_width;
      tag_width     == NOC_DEFAULT_CONFIG.tag_width;
      length_width  == NOC_DEFAULT_CONFIG.length_width;
    });
    cfg.tx_vif  = bfm_flit_in_if;
    cfg.rx_vif  = bfm_flit_out_if;
    uvm_config_db #(noc_bfm_configuration)::set(null, "", "configuration", cfg);
    run_test();
  end
endmodule
