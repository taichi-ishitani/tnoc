module top();
  timeunit  1ns/1ps;

  import  tnoc_config_pkg::*;
  import  uvm_pkg::*;
  import  tue_pkg::*;
  import  tnoc_bfm_pkg::*;
  import  tvip_axi_pkg::*;

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
    input_fifo_depth: 4,
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

  tvip_axi_if master_if[3](clk, rst_n);
  tvip_axi_if slave_if[3](clk, rst_n);

  tnoc_axi_adapter_dut_wrapper #(CONFIG) u_dut_wrapper (
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .slave_if   (master_if  ),
    .master_if  (slave_if   )
  );
endmodule
