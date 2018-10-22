module top();
  timeunit  1ns/1ps;

  import  tnoc_config_pkg::*;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tnoc_bfm_pkg::*;
  import  tvip_axi_types_pkg::*;
  import  tvip_axi_pkg::*;
  import  tnoc_axi_adapter_env_pkg::*;
  import  tnoc_axi_adapter_tests_pkg::*;

  `ifndef TNOC_AXI_ADAPTER_ENV_DATA_WIDTH
    `define TNOC_AXI_ADAPTER_ENV_DATA_WIDTH TNOC_DEFAULT_CONFIG.data_width
  `endif

  localparam  tnoc_config CONFIG  = '{
    address_width:    TNOC_DEFAULT_CONFIG.address_width,
    data_width:       `TNOC_AXI_ADAPTER_ENV_DATA_WIDTH,
    id_x_width:       TNOC_DEFAULT_CONFIG.id_x_width,
    id_y_width:       TNOC_DEFAULT_CONFIG.id_y_width,
    virtual_channels: 2,
    tags:             32,
    max_burst_length: 256,
    input_fifo_depth: 5,
    size_x:           3,
    size_y:           2,
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
    repeat (20) begin
      @(posedge clk);
    end
    rst_n = 1;
  end

//--------------------------------------------------------------
//  AXI VIP Connections
//--------------------------------------------------------------
  localparam  int MASTER_ID_X[3]  = '{0, 2, 1};
  localparam  int MASTER_ID_Y[3]  = '{0, 0, 1};
  localparam  int SLAVE_ID_X[3]   = '{1, 0, 2};
  localparam  int SLAVE_ID_Y[3]   = '{0, 1, 1};

  tvip_axi_if   axi_master_if[3](clk, rst_n);
  tvip_axi_vif  axi_master_vif[int][int];
  tvip_axi_if   axi_slave_if[3](clk, rst_n);
  tvip_axi_vif  axi_slave_vif[int][int];

  for (genvar i = 0;i < 3;++i) begin
    initial begin
      axi_master_vif[MASTER_ID_Y[i]][MASTER_ID_X[i]]  = axi_master_if[i];
      axi_slave_vif[SLAVE_ID_Y[i]][SLAVE_ID_X[i]]     = axi_slave_if[i];
    end
  end

//--------------------------------------------------------------
//  Flit IF Connections
//--------------------------------------------------------------
  localparam  int BFM_IFS = 6 * CONFIG.virtual_channels;

  tnoc_bfm_flit_if  flit_tx_if[BFM_IFS](clk, rst_n);
  tnoc_bfm_flit_vif flit_tx_vif[int][int];

  tnoc_bfm_flit_if  flit_rx_if[BFM_IFS](clk, rst_n);
  tnoc_bfm_flit_vif flit_rx_vif[int][int];

  tnoc_flit_array_if_connector #(
    .CONFIG       (CONFIG ),
    .IFS          (6      ),
    .ACTIVE_MODE  (0      )
  ) u_flit_if_connector (
    .flit_in_if       (u_dut_wrapper.adapter_to_fabric_if ),
    .flit_out_if      (u_dut_wrapper.fabric_to_adapter_if ),
    .flit_bfm_in_if   (flit_tx_if                         ),
    .flit_bfm_out_if  (flit_rx_if                         )
  );

  for (genvar i = 0;i < 6;++i) begin
    for (genvar j = 0;j < CONFIG.virtual_channels;++j) begin
      initial begin
        flit_tx_vif[i][j] = flit_tx_if[CONFIG.virtual_channels*i+j];
        flit_rx_vif[i][j] = flit_rx_if[CONFIG.virtual_channels*i+j];
      end
    end
  end

//--------------------------------------------------------------
//  DUT
//--------------------------------------------------------------
  tnoc_axi_adapter_dut_wrapper #(CONFIG) u_dut_wrapper (
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .slave_if   (axi_master_if  ),
    .master_if  (axi_slave_if   )
  );

//--------------------------------------------------------------
//  UVM
//--------------------------------------------------------------
  function automatic tnoc_axi_adapter_env_configuration create_cfg();
    tnoc_axi_adapter_env_configuration  cfg = new();
    cfg.create_sub_cfgs(3, 2, flit_tx_vif, flit_rx_vif, axi_master_vif, axi_slave_vif);
    assert (cfg.randomize() with {
      foreach (axi_master_cfg[i]) {
        axi_master_cfg[i].id_width         == $clog2(CONFIG.tags);
        axi_master_cfg[i].address_width    == CONFIG.address_width;
        axi_master_cfg[i].max_burst_length == CONFIG.max_burst_length;
        axi_master_cfg[i].data_width       == CONFIG.data_width;

        axi_master_cfg[i].min_write_data_delay                          == 0;
        axi_master_cfg[i].max_write_data_delay                          == 10;
        axi_master_cfg[i].write_data_delay_weight[TVIP_AXI_ZERO_DELAY ] == 17;
        axi_master_cfg[i].write_data_delay_weight[TVIP_AXI_SHORT_DELAY] == 2;
        axi_master_cfg[i].write_data_delay_weight[TVIP_AXI_LONG_DELAY ] == 1;

        axi_master_cfg[i].min_bready_delay                          == 0;
        axi_master_cfg[i].max_bready_delay                          == 10;
        axi_master_cfg[i].bready_delay_weight[TVIP_AXI_ZERO_DELAY ] == 7;
        axi_master_cfg[i].bready_delay_weight[TVIP_AXI_SHORT_DELAY] == 2;
        axi_master_cfg[i].bready_delay_weight[TVIP_AXI_LONG_DELAY ] == 1;

        axi_master_cfg[i].min_rready_delay                          == 0;
        axi_master_cfg[i].max_rready_delay                          == 10;
        axi_master_cfg[i].rready_delay_weight[TVIP_AXI_ZERO_DELAY ] == 7;
        axi_master_cfg[i].rready_delay_weight[TVIP_AXI_SHORT_DELAY] == 2;
        axi_master_cfg[i].rready_delay_weight[TVIP_AXI_LONG_DELAY ] == 1;
      }
      foreach (axi_slave_cfg[i]) {
        axi_slave_cfg[i].id_width         == (CONFIG.id_x_width + CONFIG.id_y_width + $clog2(CONFIG.tags));
        axi_slave_cfg[i].address_width    == CONFIG.address_width;
        axi_slave_cfg[i].max_burst_length == CONFIG.max_burst_length;
        axi_slave_cfg[i].data_width       == CONFIG.data_width;

        axi_slave_cfg[i].min_response_start_delay                          == 0;
        axi_slave_cfg[i].max_response_start_delay                          == 10;
        axi_slave_cfg[i].response_start_delay_weight[TVIP_AXI_ZERO_DELAY ] == 7;
        axi_slave_cfg[i].response_start_delay_weight[TVIP_AXI_SHORT_DELAY] == 2;
        axi_slave_cfg[i].response_start_delay_weight[TVIP_AXI_LONG_DELAY ] == 1;

        axi_slave_cfg[i].min_response_delay                          == 0;
        axi_slave_cfg[i].max_response_delay                          == 10;
        axi_slave_cfg[i].response_delay_weight[TVIP_AXI_ZERO_DELAY ] == 17;
        axi_slave_cfg[i].response_delay_weight[TVIP_AXI_SHORT_DELAY] == 2;
        axi_slave_cfg[i].response_delay_weight[TVIP_AXI_LONG_DELAY ] == 1;

        axi_slave_cfg[i].min_awready_delay                          == 0;
        axi_slave_cfg[i].max_awready_delay                          == 10;
        axi_slave_cfg[i].awready_delay_weight[TVIP_AXI_ZERO_DELAY ] == 7;
        axi_slave_cfg[i].awready_delay_weight[TVIP_AXI_SHORT_DELAY] == 2;
        axi_slave_cfg[i].awready_delay_weight[TVIP_AXI_LONG_DELAY ] == 1;

        axi_slave_cfg[i].min_wready_delay                          == 0;
        axi_slave_cfg[i].max_wready_delay                          == 10;
        axi_slave_cfg[i].wready_delay_weight[TVIP_AXI_ZERO_DELAY ] == 7;
        axi_slave_cfg[i].wready_delay_weight[TVIP_AXI_SHORT_DELAY] == 2;
        axi_slave_cfg[i].wready_delay_weight[TVIP_AXI_LONG_DELAY ] == 1;

        axi_slave_cfg[i].min_arready_delay                          == 0;
        axi_slave_cfg[i].max_arready_delay                          == 10;
        axi_slave_cfg[i].arready_delay_weight[TVIP_AXI_ZERO_DELAY ] == 7;
        axi_slave_cfg[i].arready_delay_weight[TVIP_AXI_SHORT_DELAY] == 2;
        axi_slave_cfg[i].arready_delay_weight[TVIP_AXI_LONG_DELAY ] == 1;

        if (i == 5) {
          axi_slave_cfg[i].response_ordering == TVIP_AXI_OUT_OF_ORDER;
          axi_slave_cfg[i].interleave_depth inside {[2:32]};
        }
      }
      foreach (fabric_env_cfg.bfm_cfg[i]) {
        fabric_env_cfg.bfm_cfg[i].agent_mode       == UVM_PASSIVE;
        fabric_env_cfg.bfm_cfg[i].address_width    == CONFIG.address_width;
        fabric_env_cfg.bfm_cfg[i].data_width       == CONFIG.data_width;
        fabric_env_cfg.bfm_cfg[i].id_x_width       == CONFIG.id_x_width;
        fabric_env_cfg.bfm_cfg[i].id_y_width       == CONFIG.id_y_width;
        fabric_env_cfg.bfm_cfg[i].virtual_channels == CONFIG.virtual_channels;
        fabric_env_cfg.bfm_cfg[i].tags             == CONFIG.tags;
        fabric_env_cfg.bfm_cfg[i].max_burst_length == CONFIG.max_burst_length;
      }
      fabric_env_cfg.error_data == CONFIG.error_data[CONFIG.data_width-1:0];
    });
    return cfg;
  endfunction

  initial begin
    uvm_wait_for_nba_region();
    uvm_config_db #(tnoc_axi_adapter_env_configuration)::set(
      null, "", "configuration", create_cfg()
    );
    run_test();
  end
endmodule
