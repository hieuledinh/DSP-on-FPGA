module audio_equalizer (
    input  logic               clk,
    reset_n,
    input  logic        [ 2:0] sw_bass,
    sw_mid,
    sw_treble,
    input  logic signed [23:0] data_in,
    output logic signed [23:0] data_out
);

  // logic [2:0] sw_gain;
  // logic [1:0] sw_mode;

  // assign sw_gain = 3'b000;
  // assign sw_mode = 2'b11;

  logic [7:0] gain_bass, gain_mid, gain_treble;
  logic signed [23:0] firbass, firmid, firhigh;
  logic signed [31:0] gain_out_bass, gain_out_mid, gain_out_high;
  logic signed [31:0] sum_out;

  // gain Q1.7 format 

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      data_out <= 23'b0;
    end else begin
      gain_out_bass = firbass * gain_bass;
      gain_out_mid = firmid * gain_mid;
      gain_out_high = firhigh * gain_treble;

      sum_out = gain_out_bass + gain_out_mid + gain_out_high;


      data_out = sum_out >>> 7;
    end
  end
  always_comb begin
  end
  fir_bass firbasss (
      .clk(clk),
      .reset_n(reset_n),
      .data_in(data_in),
      .data_out(firbass)
  );
  fir_mid firmidd (
      .clk(clk),
      .reset_n(reset_n),
      .data_in(data_in),
      .data_out(firmid)
  );
  fir_treble fir_trebledut (
      .clk(clk),
      .reset_n(reset_n),
      .data_in(data_in),
      .data_out(firhigh)
  );

  gain_control gaindut (
      .clk(clk),
      .sw_bass(sw_bass),
      .sw_mid(sw_mid),
      .sw_treble(sw_treble),
      .gain_bass(gain_bass),
      .gain_mid(gain_mid),
      .gain_treble(gain_treble)
  );

endmodule
