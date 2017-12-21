module top();
  timeunit  1ns/1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_config_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;
  import  noc_common_env_pkg::*;
  import  noc_router_env_pkg::*;
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

  noc_flit_if flit_in_if[5]();
  noc_flit_if flit_out_if[5]();

  noc_bfm_flit_if bfm_flit_in_if[5](clk, rst_n);
  noc_bfm_flit_if bfm_flit_out_if[5](clk, rst_n);

  for (genvar g_i = 0;g_i < 5;++g_i) begin
    assign  flit_in_if[g_i].valid     = bfm_flit_in_if[g_i].valid;
    assign  bfm_flit_in_if[g_i].ready = flit_in_if[g_i].ready;
    assign  flit_in_if[g_i].flit      = convert_to_dut_flit(bfm_flit_in_if[g_i].flit);

    assign  bfm_flit_out_if[g_i].valid  = flit_out_if[g_i].valid;
    assign  flit_out_if[g_i].ready      = bfm_flit_out_if[g_i].ready;
    assign  bfm_flit_out_if[g_i].flit   = convert_to_bfm_flit(flit_out_if[g_i].flit);
    assign  bfm_flit_out_if[g_i].ready  = '1;
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

  noc_router #(
    .X  (1  ),
    .Y  (1  )
  ) u_dut (
    .clk                  (clk            ),
    .rst_n                (rst_n          ),
    .flit_in_if_x_plus    (flit_in_if[0]  ),
    .flit_out_if_x_plus   (flit_out_if[0] ),
    .flit_in_if_x_minus   (flit_in_if[1]  ),
    .flit_out_if_x_minus  (flit_out_if[1] ),
    .flit_in_if_y_plus    (flit_in_if[2]  ),
    .flit_out_if_y_plus   (flit_out_if[2] ),
    .flit_in_if_y_minus   (flit_in_if[3]  ),
    .flit_out_if_y_minus  (flit_out_if[3] ),
    .flit_in_if_local     (flit_in_if[4]  ),
    .flit_out_if_local    (flit_out_if[4] )
  );

  initial begin
    noc_router_env_configuration  cfg = new();
    assert(cfg.randomize() with {
      id_x == 1;
      id_y == 1;
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

    cfg.bfm_cfg[0].tx_vif = bfm_flit_in_if[0];
    cfg.bfm_cfg[0].rx_vif = bfm_flit_out_if[0];
    cfg.bfm_cfg[1].tx_vif = bfm_flit_in_if[1];
    cfg.bfm_cfg[1].rx_vif = bfm_flit_out_if[1];
    cfg.bfm_cfg[2].tx_vif = bfm_flit_in_if[2];
    cfg.bfm_cfg[2].rx_vif = bfm_flit_out_if[2];
    cfg.bfm_cfg[3].tx_vif = bfm_flit_in_if[3];
    cfg.bfm_cfg[3].rx_vif = bfm_flit_out_if[3];
    cfg.bfm_cfg[4].tx_vif = bfm_flit_in_if[4];
    cfg.bfm_cfg[4].rx_vif = bfm_flit_out_if[4];

    uvm_config_db #(noc_router_env_configuration)::set(null, "", "configuration", cfg);
    run_test();
  end
endmodule
