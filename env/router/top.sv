module top();
  timeunit  1ns/1ps;

  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tnoc_config_pkg::*;
  import  tnoc_bfm_types_pkg::*;
  import  tnoc_bfm_pkg::*;
  import  tnoc_common_env_pkg::*;
  import  tnoc_router_env_pkg::*;
  import  tnoc_router_tests_pkg::*;

  `ifndef TNOC_ROUTER_ENV_DATA_WIDTH
    `define TNOC_ROUTER_ENV_DATA_WIDTH TNOC_DEFAULT_CONFIG.data_width
  `endif

  localparam  tnoc_config CONFIG  = '{
    address_width:      TNOC_DEFAULT_CONFIG.address_width,
    data_width:         `TNOC_ROUTER_ENV_DATA_WIDTH,
    id_x_width:         TNOC_DEFAULT_CONFIG.id_x_width,
    id_y_width:         TNOC_DEFAULT_CONFIG.id_y_width,
    virtual_channels:   TNOC_DEFAULT_CONFIG.virtual_channels,
    tag_width:          TNOC_DEFAULT_CONFIG.tag_width,
    burst_length_width: TNOC_DEFAULT_CONFIG.burst_length_width,
    input_fifo_depth:   TNOC_DEFAULT_CONFIG.input_fifo_depth,
    size_x:             TNOC_DEFAULT_CONFIG.size_x,
    size_y:             TNOC_DEFAULT_CONFIG.size_y
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

  tnoc_flit_if #(CONFIG)  flit_in_if[5]();
  tnoc_flit_if #(CONFIG)  flit_out_if[5]();

  tnoc_bfm_flit_if  bfm_flit_in_if[5](clk, rst_n);
  tnoc_bfm_flit_if  bfm_flit_out_if[5](clk, rst_n);

  tnoc_flit_if_connector #(
    .CONFIG (CONFIG ),
    .IFS    (5      )
  ) u_flit_if_connector (
    .flit_in_if       (flit_in_if       ),
    .flit_out_if      (flit_out_if      ),
    .flit_bfm_in_if   (bfm_flit_in_if   ),
    .flit_bfm_out_if  (bfm_flit_out_if  )
  );

  for (genvar i = 0;i < 5;++i) begin
    assign  bfm_flit_out_if[i].ready        = '1;
    assign  bfm_flit_out_if[i].vc_available = '1;
  end

  tnoc_router #(
    .CONFIG (CONFIG ),
    .X      (1      ),
    .Y      (1      )
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
    tnoc_router_env_configuration cfg = new();
    assert(cfg.randomize() with {
      id_x == 1;
      id_y == 1;
      foreach (bfm_cfg[i]) {
        bfm_cfg[i].address_width      == CONFIG.address_width;
        bfm_cfg[i].data_width         == CONFIG.data_width;
        bfm_cfg[i].id_x_width         == CONFIG.id_x_width;
        bfm_cfg[i].id_y_width         == CONFIG.id_y_width;
        bfm_cfg[i].virtual_channels   == CONFIG.virtual_channels;
        bfm_cfg[i].tag_width          == CONFIG.tag_width;
        bfm_cfg[i].burst_length_width == CONFIG.burst_length_width;
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

    uvm_config_db #(tnoc_router_env_configuration)::set(null, "", "configuration", cfg);
    run_test();
  end
endmodule
