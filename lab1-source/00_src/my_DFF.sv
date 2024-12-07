module my_DFF (
    clk,
    reset_n,
    data_in,
    data_delayed
);
  parameter N = 24;

  input clk, reset_n;
  input logic signed [N-1:0] data_in;
  output logic signed [N-1:0] data_delayed;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      data_delayed <= 0;
    end else begin
      data_delayed <= data_in;
    end
  end
endmodule
