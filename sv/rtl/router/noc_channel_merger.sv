module noc_channe_merger
  import  noc_config_pkg::*;
#(
  parameter   noc_config  CONFIG    = NOC_DEFAULT_CONFIG,
  localparam  int         CHANNELS  = CONFIG.virtual_channels
)(
  input logic                 clk,
  input logic                 rst_n,
  noc_flit_channel_if.target  flit_in_if[CHANNELS],
  noc_flit_if.initiator       flit_out_if
);
  localparam  int COUNTER_WIDTH = $clog2(CONFIG.timeout);

  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic [CHANNELS-1:0]        request;
  logic [CHANNELS-1:0]        grant;
  logic [CHANNELS-1:0]        valid;
  logic                       ready;
  logic [$bits(noc_flit)-1:0] flit_in[CHANNELS];
  logic [$bits(noc_flit)-1:0] flit_out;
  noc_flit                    flit;
  logic                       timeout;
  logic [COUNTER_WIDTH-1:0]   timeout_counter;
  genvar                      g_i;

//--------------------------------------------------------------
//  Channel Arbitration/Flit Selection
//--------------------------------------------------------------
  generate for (g_i = 0;g_i < CHANNELS;++g_i) begin : g_input_control
    logic     flit_active;
    logic     flit_timeout;
    logic     flit_pending;
    logic     flit_escaped;
    noc_flit  flit_temp;

    assign  request[g_i]          = (flit_active && ready && flit_out_if.ready[g_i]) ? '1 : '0;
    assign  flit_in[g_i]          = (!flit_escaped) ? flit_in_if[g_i].flit : flit_temp;
    assign  flit_in_if[g_i].ready = (grant[g_i] && (!flit_escaped)) ? '1 : '0;

    assign  flit_active   = (flit_in_if[g_i].valid || flit_escaped) ? '1 : '0;
    assign  flit_timeout  = (timeout && valid[g_i] && (!flit_out_if.ready[g_i])) ? '1 : '0;
    assign  flit_escaped  = (flit_timeout || flit_pending) ? '1 : '0;

    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        flit_pending  <= '0;
      end
      else if (grant[g_i]) begin
        flit_pending  <= '0;
      end
      else if (flit_timeout) begin
        flit_pending  <= '1;
      end
    end

    always_ff @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
        flit_temp <= '0;
      end
      else if (grant[g_i]) begin
        flit_temp <= flit_in[g_i];
      end
    end
  end endgenerate

  noc_round_robin_arbiter #(
    .REQUESTS     (CHANNELS ),
    .KEEP_RESULT  (0        )
  ) u_channel_arbiter (
    .clk        (clk      ),
    .rst_n      (rst_n    ),
    .i_request  (request  ),
    .o_grant    (grant    ),
    .i_free     ('0       )
  );

  noc_mux #(
    .WIDTH     (FLIT_WIDTH    ),
    .ENTRIES   (CHANNELS      )
  ) u_flit_mux (
    .i_select (grant    ),
    .i_value  (flit_in  ),
    .o_value  (flit_out )
  );

//--------------------------------------------------------------
//  Output Control
//--------------------------------------------------------------
  assign  flit_out_if.valid = valid;
  assign  flit_out_if.flit  = flit;

  assign  ready = (
    (valid == '0) || ((valid & flit_out_if.ready) != '0) || timeout
  ) ? '1 : '0;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      valid <= '0;
      flit  <= '0;
    end
    else if (ready) begin
      valid <= grant;
      flit  <= flit_out;
    end
  end

  //  Timeout
  localparam  bit [COUNTER_WIDTH-1:0] TIMEOUT_COUNT = CONFIG.timeout;

  assign  timeout = (timeout_counter >= TIMEOUT_COUNT) ? '1 : '0;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      timeout_counter <= 0;
    end
    else if ((valid == '0) || (grant != '0) || timeout) begin
      timeout_counter <= 0;
    end
    else begin
      timeout_counter <= timeout_counter + 1;
    end
  end
endmodule
