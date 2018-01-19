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
  logic [4:0]           request[CHANNELS];
  logic [4:0]           grant[CHANNELS];
  logic [4:0]           free[CHANNELS];
  logic [4:0]           port_grant[CHANNELS];
  logic [CHANNELS-1:0]  vc_request;
  logic [CHANNELS-1:0]  vc_grant;
  logic [CHANNELS-1:0]  vc_free;
  logic [CHANNELS-1:0]  vc_available;
  logic                 fifo_empty;
  logic                 fifo_full;
  logic                 fifo_push;
  logic                 fifo_pop;
  logic [4:0]           output_grant;
  logic [4:0]           output_grant_temp;

  generate for (genvar i = 0;i < CHANNELS;++i) begin
    for (genvar j = 0;j < 5;++j) begin
      assign  request[i][j]               = port_control_if[j].request[i];
      assign  port_control_if[j].grant[i] = grant[i][j];
      assign  free[i][j]                  = port_control_if[j].free[i];
    end
  end endgenerate

//--------------------------------------------------------------
//  Port Arbitration
//--------------------------------------------------------------
  generate for (genvar i = 0;i < CHANNELS;++i) begin : g_port_arbitration
    logic [4:0] port_request;
    logic [4:0] port_free;

    for (genvar j = 0;j < 5;++j) begin
      assign  port_request[j] = port_control_if[j].start_of_packet[i];
      assign  port_free[j]    = port_control_if[j].end_of_packet[i];
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
  assign  vc_available  = i_vc_available & {CHANNELS{~fifo_full}};

  generate for (genvar i = 0;i < CHANNELS;++i) begin : g_vc_arbitration
    assign  vc_request[i] = |(request[i] & port_grant[i] & {5{vc_available[i]}});
    assign  vc_free[i]    = |(free[i]    & port_grant[i]                       );
  end endgenerate

  noc_round_robin_arbiter #(
    .REQUESTS     (CHANNELS ),
    .KEEP_RESULT  (1        )
  ) u_vc_arbiter (
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .i_request  (vc_request ),
    .o_grant    (vc_grant   ),
    .i_free     (vc_free    )
  );

//--------------------------------------------------------------
//  Grant
//--------------------------------------------------------------
  generate for (genvar i = 0;i < CHANNELS;++i) begin
    assign  grant[i]  = (vc_grant[i]) ? port_grant[i] : '0;
  end endgenerate

  noc_mux #(
    .WIDTH    (5  ),
    .ENTRIES  (2  )
  ) u_grant_mux (
    .i_select (vc_grant           ),
    .i_value  (port_grant         ),
    .o_value  (output_grant_temp  )
  );

  assign  fifo_push = |vc_free;
  assign  fifo_pop  = i_output_free;

  noc_fifo #(
    .WIDTH  (5  ),
    .DEPTH  (2  )
  ) u_grant_fifo (
    .clk            (clk                ),
    .rst_n          (rst_n              ),
    .i_clear        ('0                 ),
    .o_empty        (fifo_empty         ),
    .o_full         (fifo_full          ),
    .o_almost_full  (),
    .i_push         (fifo_push          ),
    .i_data         (output_grant_temp  ),
    .i_pop          (fifo_pop           ),
    .o_data         (output_grant       )
  );

  assign  o_output_grant  = (!fifo_empty) ? output_grant : '0;
endmodule
