module noc_port_controller
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input   logic                   clk,
  input   logic                   rst_n,
  input   logic [CHANNELS-1:0]    i_vc_available,
  noc_port_control_if.arbitrator  port_control_if[5],
  output  logic [4:0]             o_output_grant,
  input   logic                   i_output_free
);
  logic [4:0]           port_grant[CHANNELS];
  logic [4:0]           port_vc_request[CHANNELS];
  logic [4:0]           port_vc_free[CHANNELS];
  logic [CHANNELS-1:0]  vc_request;
  logic [CHANNELS-1:0]  vc_grant;
  logic [CHANNELS-1:0]  vc_free;
  logic [4:0]           output_grant_temp;
  logic                 output_grant_valid;
  logic [4:0]           output_grant;
  logic                 fifo_push;
  logic                 fifo_full;

//--------------------------------------------------------------
//  Port Arbitration
//--------------------------------------------------------------
  generate for (genvar i = 0;i < CHANNELS;++i) begin : g_port_arbitration
    logic [4:0] port_request;
    logic [4:0] port_free;

    for (genvar j = 0;j < 5;++j) begin
      assign  port_request[j]                   = port_control_if[j].port_request[i];
      assign  port_control_if[j].port_grant[i]  = port_grant[i][j];
      assign  port_free[j]                      = port_control_if[j].port_free[i];
    end

    noc_round_robin_arbiter #(
      .REQUESTS     (5  ),
      .KEEP_RESULT  (1  )
    ) u_port_arbiter (
      .clk        (clk            ),
      .rst_n      (rst_n          ),
      .i_request  (port_request   ),
      .o_grant    (port_grant[i]  ),
      .i_free     (port_free      )
    );
  end endgenerate

//--------------------------------------------------------------
//  VC Arbitration
//--------------------------------------------------------------
  generate for (genvar i = 0;i < CHANNELS;++i) begin
    assign  vc_request[i] = (i_vc_available[i] && (!fifo_full)) ? |port_vc_request[i] : '0;
    assign  vc_free[i]    = |port_vc_free[i];

    for (genvar j = 0;j < 5;++j) begin
      assign  port_vc_request[i][j]           = (port_grant[i][j]) ? port_control_if[j].vc_request[i] : '0;
      assign  port_control_if[j].vc_grant[i]  = (port_grant[i][j]) ? vc_grant[i]                      : '0;
      assign  port_vc_free[i][j]              = (port_grant[i][j]) ? port_control_if[j].vc_free[i]    : '0;
    end
  end endgenerate

  noc_round_robin_arbiter #(
    .REQUESTS     (CHANNELS ),
    .KEEP_RESULT  (1        )
  ) u_port_arbiter (
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .i_request  (vc_request ),
    .o_grant    (vc_grant   ),
    .i_free     (vc_free    )
  );

//--------------------------------------------------------------
//  Output Grant
//--------------------------------------------------------------
  noc_mux #(
    .WIDTH    (5          ),
    .ENTRIES  (CHANNELS   )
  ) u_output_grant_mux (
    .i_select (vc_grant           ),
    .i_value  (port_grant         ),
    .o_value  (output_grant_temp  )
  );

  assign  fifo_push       = |vc_free;
  assign  o_output_grant  = (output_grant_valid) ? output_grant : '0;
  noc_fifo #(
    .WIDTH  (5  ),
    .DEPTH  (2  )
  ) u_output_grant_fifo (
    .clk            (clk                ),
    .rst_n          (rst_n              ),
    .i_clear        ('0                 ),
    .o_empty        (),
    .o_full         (fifo_full          ),
    .o_almost_full  (),
    .i_valid        (fifo_push          ),
    .o_ready        (),
    .i_data         (output_grant_temp  ),
    .o_valid        (output_grant_valid ),
    .i_ready        (i_output_free      ),
    .o_data         (output_grant       )
  );
endmodule
