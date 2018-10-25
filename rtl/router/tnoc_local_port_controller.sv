module tnoc_local_port_controller
  `include  "tnoc_default_imports.svh"
#(
  parameter   tnoc_config CONFIG    = TNOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input   logic                   clk,
  input   logic                   rst_n,
  input   logic [CHANNELS-1:0]    i_vc_available,
  tnoc_port_control_if.arbitrator port_control_if[5],
  output  logic [4:0]             o_output_grant[CHANNELS],
  input   logic                   i_output_free[CHANNELS]
);
  logic [4:0]           port_grant[CHANNELS];
  logic [CHANNELS-1:0]  vc_grant[5];
  logic [CHANNELS-1:0]  vc_free[5];
  logic [CHANNELS-1:0]  vc_available;
  logic [CHANNELS-1:0]  fifo_full;

//--------------------------------------------------------------
//  Port Arbitration
//--------------------------------------------------------------
  for (genvar i = 0;i < CHANNELS;++i) begin : g_port_arbitration
    logic [4:0] port_request;
    logic [4:0] port_free;

    for (genvar j = 0;j < 5;++j) begin
      assign  port_request[j] = port_control_if[j].start_of_packet[i];
      assign  port_free[j]    = port_control_if[j].end_of_packet[i];
    end

    tbcm_round_robin_arbiter #(
      .REQUESTS     (5  ),
      .KEEP_RESULT  (1  )
    ) u_port_arbiter (
      .clk        (clk            ),
      .rst_n      (rst_n          ),
      .i_request  (port_request   ),
      .o_grant    (port_grant[i]  ),
      .i_free     (port_free      )
    );
  end

//--------------------------------------------------------------
//  VC Arbitration
//--------------------------------------------------------------
  assign  vc_available  = i_vc_available & (~fifo_full);

  for (genvar i = 0;i < 5;++i) begin : g_vc_arbiter
    if (CHANNELS >= 2) begin : g_multi_vc
      logic [CHANNELS-1:0]  vc_request;

      for (genvar j = 0;j < CHANNELS;++j) begin
        assign  vc_request[j] = port_grant[j][i] & port_control_if[i].request[j] & vc_available[j];
        assign  vc_free[i][j] = port_grant[j][i] & port_control_if[i].free[j];
      end

      tbcm_round_robin_arbiter #(
        .REQUESTS     (CHANNELS ),
        .KEEP_RESULT  (1        )
      ) u_vc_arbiter (
        .clk        (clk          ),
        .rst_n      (rst_n        ),
        .i_request  (vc_request   ),
        .o_grant    (vc_grant[i]  ),
        .i_free     (vc_free[i]   )
      );
    end
    else begin : g_single_vc
      assign  vc_grant[i] = port_grant[0][i] & port_control_if[i].request & vc_available;
      assign  vc_free[i]  = port_grant[0][i] & port_control_if[i].free;
    end
  end

//--------------------------------------------------------------
//  Grant
//--------------------------------------------------------------
  for (genvar i = 0;i < CHANNELS;++i) begin : g_grant
    logic [4:0] output_grant;
    logic [4:0] fifo_push_temp;
    logic       fifo_push;
    logic       fifo_pop;

    for (genvar j = 0;j < 5;++j) begin
      assign  port_control_if[j].grant[i] = vc_grant[j][i];
      assign  output_grant[j]             = vc_grant[j][i];
      assign  fifo_push_temp[j]           = vc_free[j][i];
    end

    assign  fifo_push = |fifo_push_temp;
    assign  fifo_pop  = i_output_free[i];
    tbcm_fifo #(
      .WIDTH        (5  ),
      .DEPTH        (2  ),
      .DATA_FF_OUT  (1  ),
      .FLAG_FF_OUT  (1  )
    ) u_grant_fifo (
      .clk            (clk                ),
      .rst_n          (rst_n              ),
      .i_clear        ('0                 ),
      .o_empty        (),
      .o_almost_full  (),
      .o_full         (fifo_full[i]       ),
      .i_push         (fifo_push          ),
      .i_data         (output_grant       ),
      .i_pop          (fifo_pop           ),
      .o_data         (o_output_grant[i]  )
    );
  end
endmodule
