module top();
  timeunit  1ns/1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tnoc_config_pkg::*;
  import  tnoc_bfm_types_pkg::*;
  import  tnoc_bfm_pkg::*;
  import  tnoc_common_env_pkg::*;
  import  tnoc_fabric_env_pkg::*;
  import  tnoc_fabric_tests_pkg::*;

  `ifndef TNOC_FABRIC_ENV_DATA_WIDTH
    `define TNOC_FABRIC_ENV_DATA_WIDTH TNOC_DEFAULT_CONFIG.data_width
  `endif

  `ifndef TNOC_ROUTER_ENV_VIRTUAL_CHANNELS
    `define TNOC_ROUTER_ENV_VIRTUAL_CHANNELS  TNOC_DEFAULT_CONFIG.virtual_channels
  `endif

  localparam  tnoc_config CONFIG  = '{
    address_width:    TNOC_DEFAULT_CONFIG.address_width,
    data_width:       `TNOC_FABRIC_ENV_DATA_WIDTH,
    id_x_width:       TNOC_DEFAULT_CONFIG.id_x_width,
    id_y_width:       TNOC_DEFAULT_CONFIG.id_y_width,
    virtual_channels: `TNOC_ROUTER_ENV_VIRTUAL_CHANNELS,
    tags:             TNOC_DEFAULT_CONFIG.tags,
    max_burst_length: TNOC_DEFAULT_CONFIG.max_burst_length,
    input_fifo_depth: TNOC_DEFAULT_CONFIG.input_fifo_depth,
    size_x:           TNOC_DEFAULT_CONFIG.size_x,
    size_y:           TNOC_DEFAULT_CONFIG.size_y,
    error_data:       TNOC_DEFAULT_CONFIG.error_data
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

  tnoc_flit_if #(CONFIG)  flit_in_if[9]();
  tnoc_flit_if #(CONFIG)  flit_out_if[9]();

  tnoc_bfm_flit_if  bfm_flit_in_if[9*CONFIG.virtual_channels](clk, rst_n);
  tnoc_bfm_flit_if  bfm_flit_out_if[9*CONFIG.virtual_channels](clk, rst_n);

  tnoc_bfm_flit_vif tx_vif[int][int];
  tnoc_bfm_flit_vif rx_vif[int][int];

  tnoc_flit_array_if_connector #(
    .CONFIG (CONFIG ),
    .IFS    (9      )
  ) u_flit_if_connector (
    .flit_in_if       (flit_in_if       ),
    .flit_out_if      (flit_out_if      ),
    .flit_bfm_in_if   (bfm_flit_in_if   ),
    .flit_bfm_out_if  (bfm_flit_out_if  )
  );

  for (genvar i = 0;i < 9;++i) begin
    for (genvar j = 0;j < CONFIG.virtual_channels;++j) begin
      assign  bfm_flit_out_if[CONFIG.virtual_channels*i+j].ready        = '1;
      assign  bfm_flit_out_if[CONFIG.virtual_channels*i+j].vc_available = '1;

      initial begin
        tx_vif[i][j]  = bfm_flit_in_if[CONFIG.virtual_channels*i+j];
        rx_vif[i][j]  = bfm_flit_out_if[CONFIG.virtual_channels*i+j];
      end
    end
  end

  tnoc_fabric #(CONFIG) u_dut (
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .flit_in_if   (flit_in_if   ),
    .flit_out_if  (flit_out_if  )
  );

  function automatic tnoc_fabric_env_configuration create_cfg();
    tnoc_fabric_env_configuration cfg = new();
    cfg.create_sub_cfgs(CONFIG.size_x, CONFIG.size_y, tx_vif, rx_vif);
    assert(cfg.randomize() with {
      error_data == (CONFIG.error_data & ((1 << CONFIG.data_width) - 1));
      foreach (bfm_cfg[i]) {
        bfm_cfg[i].address_width    == CONFIG.address_width;
        bfm_cfg[i].data_width       == CONFIG.data_width;
        bfm_cfg[i].id_x_width       == CONFIG.id_x_width;
        bfm_cfg[i].id_y_width       == CONFIG.id_y_width;
        bfm_cfg[i].virtual_channels == CONFIG.virtual_channels;
        bfm_cfg[i].tags             == CONFIG.tags;
        bfm_cfg[i].max_burst_length == CONFIG.max_burst_length;
      }
    });
    return cfg;
  endfunction

  initial begin
    uvm_wait_for_nba_region();
    uvm_config_db #(tnoc_fabric_env_configuration)::set(null, "", "configuration", create_cfg());
    run_test();
  end
endmodule
