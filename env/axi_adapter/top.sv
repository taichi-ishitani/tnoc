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
  localparam  int DATA_WIDTH  = CONFIG.data_width;

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
  tnoc_bfm_flit_vif flit_tx_vif[int][int];
  tnoc_bfm_flit_vif flit_rx_vif[int][int];

  for (genvar i = 0;i < 6;++i) begin
    for (genvar j = 0;j < CONFIG.virtual_channels;++j) begin
      initial begin
        flit_tx_vif[i][j] = u_dut_wrapper.flit_tx_if[CONFIG.virtual_channels*i+j];
        flit_rx_vif[i][j] = u_dut_wrapper.flit_rx_if[CONFIG.virtual_channels*i+j];
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

        axi_master_cfg[i].write_data_delay.min_delay          == 0;
        axi_master_cfg[i].write_data_delay.max_delay          == 10;
        axi_master_cfg[i].write_data_delay.weight_zero_delay  == 17;
        axi_master_cfg[i].write_data_delay.weight_short_delay == 2;
        axi_master_cfg[i].write_data_delay.weight_long_delay  == 1;

        axi_master_cfg[i].bready_delay.min_delay          == 0;
        axi_master_cfg[i].bready_delay.max_delay          == 10;
        axi_master_cfg[i].bready_delay.weight_zero_delay  == 7;
        axi_master_cfg[i].bready_delay.weight_short_delay == 2;
        axi_master_cfg[i].bready_delay.weight_long_delay  == 1;

        axi_master_cfg[i].rready_delay.min_delay          == 0;
        axi_master_cfg[i].rready_delay.max_delay          == 10;
        axi_master_cfg[i].rready_delay.weight_zero_delay  == 7;
        axi_master_cfg[i].rready_delay.weight_short_delay == 2;
        axi_master_cfg[i].rready_delay.weight_long_delay  == 1;
      }
      foreach (axi_slave_cfg[i]) {
        axi_slave_cfg[i].id_width         == (CONFIG.id_x_width + CONFIG.id_y_width + $clog2(CONFIG.tags));
        axi_slave_cfg[i].address_width    == CONFIG.address_width;
        axi_slave_cfg[i].max_burst_length == CONFIG.max_burst_length;
        axi_slave_cfg[i].data_width       == CONFIG.data_width;

        axi_slave_cfg[i].response_start_delay.min_delay          == 0;
        axi_slave_cfg[i].response_start_delay.max_delay          == 10;
        axi_slave_cfg[i].response_start_delay.weight_zero_delay  == 7;
        axi_slave_cfg[i].response_start_delay.weight_short_delay == 2;
        axi_slave_cfg[i].response_start_delay.weight_long_delay  == 1;

        axi_slave_cfg[i].response_delay.min_delay          == 0;
        axi_slave_cfg[i].response_delay.max_delay          == 10;
        axi_slave_cfg[i].response_delay.weight_zero_delay  == 17;
        axi_slave_cfg[i].response_delay.weight_short_delay == 2;
        axi_slave_cfg[i].response_delay.weight_long_delay  == 1;

        axi_slave_cfg[i].awready_delay.min_delay          == 0;
        axi_slave_cfg[i].awready_delay.max_delay          == 10;
        axi_slave_cfg[i].awready_delay.weight_zero_delay  == 7;
        axi_slave_cfg[i].awready_delay.weight_short_delay == 2;
        axi_slave_cfg[i].awready_delay.weight_long_delay  == 1;

        axi_slave_cfg[i].wready_delay.min_delay          == 0;
        axi_slave_cfg[i].wready_delay.max_delay          == 10;
        axi_slave_cfg[i].wready_delay.weight_zero_delay  == 7;
        axi_slave_cfg[i].wready_delay.weight_short_delay == 2;
        axi_slave_cfg[i].wready_delay.weight_long_delay  == 1;

        axi_slave_cfg[i].arready_delay.min_delay          == 0;
        axi_slave_cfg[i].arready_delay.max_delay          == 10;
        axi_slave_cfg[i].arready_delay.weight_zero_delay  == 7;
        axi_slave_cfg[i].arready_delay.weight_short_delay == 2;
        axi_slave_cfg[i].arready_delay.weight_long_delay  == 1;

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
      fabric_env_cfg.error_data == CONFIG.error_data[DATA_WIDTH-1:0];
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
