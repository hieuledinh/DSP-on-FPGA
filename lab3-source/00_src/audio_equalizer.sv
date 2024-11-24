module audio_equalizer (
    input logic clk,
    reset_n,
    input logic [2:0] sw_gain,
    input logic [1:0] sw_mode,
    input logic signed [23:0] data_in,
    output logic signed [23:0] data_out
);

  logic [7:0] gain_bass, gain_mid, gain_high;
  logic signed [23:0] firbass, firmid, firhigh;
  logic signed [31:0] gain_out_bass, gain_out_mid, gain_out_high;
  logic signed [31:0] sum_out;

  always @(posedge clk or posedge reset_n) begin
    if (reset) begin
      gain_bass <= 8'b10000000;
      gain_mid  <= 8'b10000000;
      gain_high <= 8'b10000000;
    end else begin
      case (sw_mode)
        2'b01: gain_bass <= gain;
        2'b10: gain_mid <= gain;
        2'b11: gain_high <= gain;
        default: begin
          gain_bass <= 8'b10000000;
          gain_mid  <= 8'b10000000;
          gain_high <= 8'b10000000;
        end
      endcase
    end
  end
  always_comb begin
    gain_out_bass = firbass * gain_bass;
    gain_out_mid = firmid * gain_mid;
    gain_out_high = firhigh * gain_high;

    sum_out = gain_out_bass + gain_out_mid + gain_out_high;
    data_out = sum_out >>> 7;
  end

  fir_pass firpass (
      .clk(clk),
      .reset_n(reset_n),
      .data_in(data_in),
      .data_out(firbass)
  );
  fir_mid firmid (
      .clk(clk),
      .reset_n(reset_n),
      .data_in(data_in),
      .data_out(firmid)
  );
  fir_high firhigh (
      .clk(clk),
      .reset_n(reset_n),
      .data_in(data_in),
      .data_out(firhigh)
  );

  gain_control gaindut (
      .clk (clk),
      .sw  (sw_gain),
      .gain(gain)
  );

endmodule
