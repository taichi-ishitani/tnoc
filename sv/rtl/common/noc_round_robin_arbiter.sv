module noc_round_robin_arbiter #(
  parameter int REQUESTS  = 2
)(
  input   logic                 clk,
  input   logic                 rst_n,
  input   logic [REQUESTS-1:0]  i_request,
  output  logic [REQUESTS-1:0]  o_grant,
  input   logic [REQUESTS-1:0]  i_release
);
  localparam  bit [REQUESTS-1:0]  INITIAL_GRANT = 1 << (REQUESTS - 1);

  logic                 busy;
  logic                 grab_grant;
  logic                 release_grant;
  logic [REQUESTS-1:0]  grant;
  logic [REQUESTS-1:0]  current_grant;
  logic [REQUESTS-1:0]  next_grant;
  logic [REQUESTS-1:0]  next_grant_each[REQUESTS];
  genvar                g_i;

//--------------------------------------------------------------
//  State
//--------------------------------------------------------------
  assign  grab_grant    = |(i_request & {REQUESTS{~busy}});
  assign  release_grant = |(i_release & grant);

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      busy  <= '0;
    end
    else if (release_grant) begin
      busy  <= '0;
    end
    else if (grab_grant) begin
      busy  <= '1;
    end
  end

//--------------------------------------------------------------
//  Generating Grant
//--------------------------------------------------------------
  assign  o_grant     = grant;
  assign  grant       = (grab_grant) ? next_grant
                      : (busy      ) ? current_grant
                                     : '0;
  assign  next_grant  = merge_next_grant(next_grant_each);

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      current_grant <= INITIAL_GRANT;
    end
    else if (grab_grant) begin
      current_grant <= next_grant;
    end
  end

  generate for (g_i = 0;g_i < REQUESTS;++g_i) begin : g_next_grant_each
    logic [REQUESTS-1:0]  request;
    logic [REQUESTS-1:0]  grant_each;

    assign  grant_each  = (current_grant[g_i]) ? request & (~(request + '1)) : '0;

    if (g_i < (REQUESTS-1)) begin
      assign  request               = {i_request[g_i:0] , i_request[REQUESTS-1:g_i+1] };
      assign  next_grant_each[g_i]  = {grant_each[g_i:0], grant_each[REQUESTS-1:g_i+1]};
    end
    else begin
      assign  request               = i_request;
      assign  next_grant_each[g_i]  = grant_each;
    end
  end endgenerate

  function automatic logic [REQUESTS-1:0] merge_next_grant(
    input logic [REQUESTS-1:0] next_grant_each[REQUESTS]
  );
    logic [REQUESTS-1:0]  next_grant;
    for (int i = 0;i < REQUESTS;++i) begin
      logic [REQUESTS-1:0]  temp;
      for (int j = 0;j < REQUESTS;++j) begin
        temp[j] = next_grant_each[j][i];
      end
      next_grant[i] = |temp;
    end
    return next_grant;
  endfunction
endmodule
