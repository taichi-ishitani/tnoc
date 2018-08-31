module top();
  timeunit  1ns/1ps;

  `include  "tnoc_macros.svh"

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tnoc_enums_pkg::*;
  import  tnoc_config_pkg::*;
  import  tnoc_bfm_types_pkg::*;
  import  tnoc_bfm_pkg::*;
  import  tnoc_common_env_pkg::*;
  import  tnoc_router_env_pkg::*;
  import  tnoc_router_tests_pkg::*;

  `ifndef TNOC_ROUTER_ENV_DATA_WIDTH
    `define TNOC_ROUTER_ENV_DATA_WIDTH TNOC_DEFAULT_CONFIG.data_width
  `endif

  `ifndef TNOC_ROUTER_ENV_VIRTUAL_CHANNELS
    `define TNOC_ROUTER_ENV_VIRTUAL_CHANNELS  TNOC_DEFAULT_CONFIG.virtual_channels
  `endif

  localparam  tnoc_config CONFIG  = '{
    address_width:    TNOC_DEFAULT_CONFIG.address_width,
    data_width:       `TNOC_ROUTER_ENV_DATA_WIDTH,
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

  tnoc_flit_if #(CONFIG)                          flit_in_if[5]();
  tnoc_flit_if #(CONFIG)                          flit_out_if[5]();
  `tnoc_internal_flit_if(CONFIG.virtual_channels) flit_internal_in_if[4]();
  `tnoc_internal_flit_if(CONFIG.virtual_channels) flit_internal_out_if[4]();

  for (genvar i = 0;i < 4;++i) begin : g_internal_port_adapter
    tnoc_rounter_internal_if_adapter #(CONFIG) u_adapetr (
      clk, rst_n, flit_in_if[i], flit_out_if[i], flit_internal_out_if[i], flit_internal_in_if[i]
    );
  end

  tnoc_bfm_flit_if  bfm_flit_in_if[5*CONFIG.virtual_channels](clk, rst_n);
  tnoc_bfm_flit_if  bfm_flit_out_if[5*CONFIG.virtual_channels](clk, rst_n);
  for (genvar i = 0;i < 5*CONFIG.virtual_channels;++i) begin
    assign  bfm_flit_out_if[i].ready        = '1;
    assign  bfm_flit_out_if[i].vc_available = '1;
  end

  virtual tnoc_bfm_flit_if  bfm_flit_in_vif[int][int];
  virtual tnoc_bfm_flit_if  bfm_flit_out_vif[int][int];
  for (genvar i = 0;i < 5;++i) begin
    for (genvar j = 0;j < CONFIG.virtual_channels;++j) begin
      initial begin
        bfm_flit_in_vif[i][j]   = bfm_flit_in_if[CONFIG.virtual_channels*i+j];
        bfm_flit_out_vif[i][j]  = bfm_flit_out_if[CONFIG.virtual_channels*i+j];
      end
    end
  end

  tnoc_flit_array_if_connector #(
    .CONFIG (CONFIG ),
    .IFS    (5      )
  ) u_flit_if_connector (
    .flit_in_if       (flit_in_if       ),
    .flit_out_if      (flit_out_if      ),
    .flit_bfm_in_if   (bfm_flit_in_if   ),
    .flit_bfm_out_if  (bfm_flit_out_if  )
  );

  localparam  bit [CONFIG.id_x_width-1:0] ID_X  = 1;
  localparam  bit [CONFIG.id_y_width-1:0] ID_Y  = 1;
  tnoc_router #(
    .CONFIG (CONFIG )
  ) u_dut (
    .clk                  (clk                      ),
    .rst_n                (rst_n                    ),
    .i_id_x               (ID_X                     ),
    .i_id_y               (ID_Y                     ),
    .flit_in_if_x_plus    (flit_internal_in_if[0]   ),
    .flit_out_if_x_plus   (flit_internal_out_if[0]  ),
    .flit_in_if_x_minus   (flit_internal_in_if[1]   ),
    .flit_out_if_x_minus  (flit_internal_out_if[1]  ),
    .flit_in_if_y_plus    (flit_internal_in_if[2]   ),
    .flit_out_if_y_plus   (flit_internal_out_if[2]  ),
    .flit_in_if_y_minus   (flit_internal_in_if[3]   ),
    .flit_out_if_y_minus  (flit_internal_out_if[3]  ),
    .flit_in_if_local     (flit_in_if[4]            ),
    .flit_out_if_local    (flit_out_if[4]           )
  );

  task run();
    tnoc_router_env_configuration cfg = new();
    assert(cfg.randomize() with {
      id_x       == 1;
      id_y       == 1;
      size_x     == CONFIG.size_x;
      size_y     == CONFIG.size_y;
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

    for (int i = 0;i < 5;++i) begin
      for (int j = 0;j < CONFIG.virtual_channels;++j) begin
        cfg.bfm_cfg[i].tx_vif[j]  = bfm_flit_in_vif[i][j];
        cfg.bfm_cfg[i].rx_vif[j]  = bfm_flit_out_vif[i][j];
      end
    end

    uvm_config_db #(tnoc_router_env_configuration)::set(null, "", "configuration", cfg);
    run_test();
  endtask

  initial begin
    uvm_wait_for_nba_region();
    run();
  end
endmodule
