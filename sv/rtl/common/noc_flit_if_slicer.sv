module noc_flit_if_slicer
  import  noc_config_pkg::*;
#(
  parameter noc_config  CONFIG  = NOC_DEFAULT_CONFIG
)(
  input logic         clk,
  input logic         rst_n,
  noc_flit_if.slave   flit_in_if,
  noc_flit_if.master  flit_out_if
);
  `include  "noc_packet.svh"
  `include  "noc_flit.svh"

  logic     valid;
  logic     ready;
  noc_flit  flit;

  assign  flit_in_if.ready  = ready;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      ready <= '1;
    end
    else begin
      ready <= flit_out_if.ready;
    end
  end

  assign  flit_out_if.valid = valid;
  assign  flit_out_if.flit  = flit;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      valid <= '0;
      flit  <= '{default: '0};
    end
    else if (ready) begin
      valid <= flit_in_if.valid;
      if (flit_in_if.valid) begin
        flit  <= flit_in_if.flit;
      end
    end
  end
endmodule
