module noc_input_fifo
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG,
  parameter int         DEPTH   = 8
)(
  input logic         clk,
  input logic         rst_n,
  noc_flit_if.slave   flit_in_if,
  noc_flit_if.master  flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"
  `include  "noc_packet_utils.svh"
  `include  "noc_flit_utils.svh"

  noc_flit_if #(CONFIG) flit_fifo_in_if[2]();
  noc_flit_if #(CONFIG) flit_fifo_out_if[2]();
  genvar                g_i;

//--------------------------------------------------------------
//  Input Control
//--------------------------------------------------------------
  //  State
  logic input_busy;
  logic input_start;
  logic input_done;

  assign  input_start   = (flit_in_if.valid && (!input_busy)    && is_header_flit(flit_in_if.flit)) ? '1 : '0;
  assign  input_done    = (flit_in_if.valid && flit_in_if.ready && is_tail_flit(flit_in_if.flit)  ) ? '1 : '0;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      input_busy  <= '0;
    end
    else if (input_done) begin
      input_busy  <= '0;
    end
    else if (input_start) begin
      input_busy  <= '1;
    end
  end

  //  FIFO Selection
  noc_common_header input_header;
  logic [1:0]       fifo_in;
  logic [1:0]       fifo_in_temp;

  assign  input_header    = get_common_header(flit_in_if.flit);
  assign  fifo_in_temp[0] = is_response_header(input_header);
  assign  fifo_in_temp[1] = is_request_header(input_header);

  noc_value_keeper #(.WIDTH(2)) u_fifo_in_keeper (
    .clk      (clk          ),
    .rst_n    (rst_n        ),
    .i_clear  (input_done   ),
    .i_valid  (input_start  ),
    .i_value  (fifo_in_temp ),
    .o_value  (fifo_in      )
  );

  //  Interface Connection
  noc_flit_if_demux #(.IFS(2)) u_fifo_in_demux (
    .i_select     (fifo_in          ),
    .flit_in_if   (flit_in_if       ),
    .flit_out_if  (flit_fifo_in_if  )
  );

//--------------------------------------------------------------
//  FIFO
//--------------------------------------------------------------
  generate for (g_i = 0;g_i < 2;++g_i) begin : g_fifo
    noc_flit_if_fifo #(.CONFIG(CONFIG), .DEPTH(DEPTH)) u_fifo (
      .clk          (clk                    ),
      .rst_n        (rst_n                  ),
      .flit_in_if   (flit_fifo_in_if[g_i]   ),
      .flit_out_if  (flit_fifo_out_if[g_i]  ),
      .i_clear      ('0                     ),
      .o_empty      (),
      .o_full       ()
    );
  end endgenerate

//--------------------------------------------------------------
//  Output Control
//--------------------------------------------------------------
  logic [1:0] output_request;
  logic [1:0] output_grant;
  logic [1:0] output_release;

  generate for (g_i = 0;g_i < 2;++g_i) begin
    assign  output_request[g_i] = (flit_fifo_out_if[g_i].valid &&                                is_header_flit(flit_fifo_out_if[g_i].flit)) ? '1 : '0;
    assign  output_release[g_i] = (flit_fifo_out_if[g_i].valid && flit_fifo_out_if[g_i].ready && is_tail_flit(flit_fifo_out_if[g_i].flit)  ) ? '1 : '0;
  end endgenerate

  noc_round_robin_arbiter #(.REQUESTS(2)) u_fifo_out_arbiter (
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .i_request  (output_request ),
    .o_grant    (output_grant   ),
    .i_release  (output_release )
  );

  noc_flit_if_mux #(.CONFIG(CONFIG), .IFS(2)) u_fifo_out_mux (
    .i_select     (output_grant     ),
    .flit_in_if   (flit_fifo_out_if ),
    .flit_out_if  (flit_out_if      )
  );
endmodule
