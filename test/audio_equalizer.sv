
module audio_equalizer (
    input  logic [23:0] data_in,   // Tín hiệu đầu vào
    output logic        i2s_clk,   // Clock I2S
    output logic        i2s_ws,    // Word Select
    output logic        i2s_data,  // Dữ liệu I2S
    input  logic        clk,       // Clock chính
    input  logic        reset,
    input  logic [ 2:0] sw_gain,
    input  logic [ 1:0] sw_mode    // Reset
);

  logic [23:0] data_out;
  logic data_ready;


  // logic [2:0] sw_gain;
  // logic [1:0] sw_mode;

  // assign sw_gain = 3'b000;
  // assign sw_mode = 2'b11;

  logic [7:0] gain, gain_bass, gain_mid, gain_high;
  logic signed [23:0] firbass, firmid, firhigh;
  logic signed [31:0] gain_out_bass, gain_out_mid, gain_out_high;
  logic signed [31:0] sum_out;

  // gain Q1.7 format 

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
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

    // sum_out = gain_out_bass;
    // sum_out = gain_out_mid;
    // sum_out = gain_out_high;


    data_out = sum_out >>> 7;
  end

  i2s_interface i2s (
      .audio_left(data_out),
      .audio_right(data_out),
      .clk(clk),
      .reset(reset),
      .i2s_clk(i2s_clk),
      .i2s_ws(i2s_ws),
      .i2s_data(i2s_data)
  );

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
  fir_high firhighh (
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
