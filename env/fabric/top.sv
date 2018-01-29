module top();
  timeunit  1ns/1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  noc_config_pkg::*;
  import  noc_bfm_types_pkg::*;
  import  noc_bfm_pkg::*;
  import  noc_common_env_pkg::*;
  import  noc_fabric_env_pkg::*;
  import  noc_fabric_tests_pkg::*;

  `ifndef NOC_FABRIC_ENV_DATA_WIDTH
    `define NOC_FABRIC_ENV_DATA_WIDTH NOC_DEFAULT_CONFIG.data_width
  `endif

  localparam  noc_config  CONFIG  = '{
    address_width:    NOC_DEFAULT_CONFIG.address_width,
    data_width:       `NOC_FABRIC_ENV_DATA_WIDTH,
    id_x_width:       NOC_DEFAULT_CONFIG.id_x_width,
    id_y_width:       NOC_DEFAULT_CONFIG.id_y_width,
    vc_width:         NOC_DEFAULT_CONFIG.vc_width,
    length_width:     NOC_DEFAULT_CONFIG.length_width,
    tag_width:        NOC_DEFAULT_CONFIG.tag_width,
    virtual_channels: NOC_DEFAULT_CONFIG.virtual_channels,
    input_fifo_depth: NOC_DEFAULT_CONFIG.input_fifo_depth,
    size_x:           NOC_DEFAULT_CONFIG.size_x,
    size_y:           NOC_DEFAULT_CONFIG.size_y
  };

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

  noc_flit_if_connector #(
    .CONFIG (CONFIG ),
    .IFS    (9      )
  ) u_flit_if_connector (
    .flit_in_if       (flit_in_if       ),
    .flit_out_if      (flit_out_if      ),
    .flit_bfm_in_if   (bfm_flit_in_if   ),
    .flit_bfm_out_if  (bfm_flit_out_if  )
  );

  for (genvar g_i = 0;g_i < 9;++g_i) begin
    assign  bfm_flit_out_if[g_i].ready        = '1;
    assign  bfm_flit_out_if[g_i].vc_available = '1;

    initial begin
      tx_vif[g_i] = bfm_flit_in_if[g_i];
      rx_vif[g_i] = bfm_flit_out_if[g_i];
    end
  end

  noc_fabric #(CONFIG) u_dut (
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
