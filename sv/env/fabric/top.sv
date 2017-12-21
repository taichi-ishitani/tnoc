module top();
  timeunit  1ns/1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_config_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;
  import  noc_fabric_env_pkg::*;
  import  noc_fabric_tests_pkg::*;

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

  noc_flit_if #(CONFIG) flit_in_if[9]();
  noc_flit_if #(CONFIG) flit_out_if[9]();

  noc_bfm_flit_if bfm_flit_in_if[9](clk, rst_n);
  noc_bfm_flit_if bfm_flit_out_if[9](clk, rst_n);

  noc_bfm_flit_vif  tx_vif[int];
  noc_bfm_flit_vif  rx_vif[int];

  for (genvar g_i = 0;g_i < 9;++g_i) begin
    assign  flit_in_if[g_i].valid     = bfm_flit_in_if[g_i].valid;
    assign  bfm_flit_in_if[g_i].ready = flit_in_if[g_i].ready;
    assign  flit_in_if[g_i].flit      = convert_to_dut_flit(bfm_flit_in_if[g_i].flit);

    assign  bfm_flit_out_if[g_i].valid  = flit_out_if[g_i].valid;
    assign  flit_out_if[g_i].ready      = bfm_flit_out_if[g_i].ready;
    assign  bfm_flit_out_if[g_i].flit   = convert_to_bfm_flit(flit_out_if[g_i].flit);
    assign  bfm_flit_out_if[g_i].ready  = '1;

    initial begin
      tx_vif[g_i] = bfm_flit_in_if[g_i];
      rx_vif[g_i] = bfm_flit_out_if[g_i];
    end
  end

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

  noc_fabric #(
    .CONFIG     (CONFIG ),
    .FIFO_DEPTH (8      )
  ) u_dut (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .flit_in_if   (flit_in_if   ),
    .flit_out_if  (flit_out_if  )
  );

  function automatic noc_fabric_env_configuration create_cfg();
    noc_fabric_env_configuration  cfg = new();
    cfg.create_sub_cfgs(CONFIG.size_x, CONFIG.size_y, tx_vif, rx_vif);
    assert(cfg.randomize() with {
      foreach (bfm_cfg[i]) {
        bfm_cfg[i].address_width     == CONFIG.address_width;
        bfm_cfg[i].data_width        == CONFIG.data_width;
        bfm_cfg[i].id_x_width        == CONFIG.id_x_width;
        bfm_cfg[i].id_y_width        == CONFIG.id_y_width;
        bfm_cfg[i].vc_width          == CONFIG.vc_width;
        bfm_cfg[i].tag_width         == CONFIG.tag_width;
        bfm_cfg[i].length_width      == CONFIG.length_width;
        bfm_cfg[i].virtual_channels  == CONFIG.virtual_channels;
      }
    });
    return cfg;
  endfunction

  initial begin
    uvm_wait_for_nba_region();
    uvm_config_db #(noc_fabric_env_configuration)::set(null, "", "configuration", create_cfg());
    run_test();
  end
endmodule
