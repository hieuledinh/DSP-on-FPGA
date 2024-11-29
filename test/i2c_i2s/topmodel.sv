module topmodel (
    input  logic               clk,
    reset_n,
    input  logic               lrclk,     // Left-right clock (I2S)
    input  logic               bclk,
    input  logic        [ 2:0] sw_gain,
    input  logic        [ 1:0] sw_mode,
    // input  logic signed [23:0] data_in,
    output logic signed [23:0] data_out,
    inout  logic               i2c_sda,   // I2C data line
    output logic               i2c_scl,
    
);

  logic [23:0] data_in;
  logic data_ready;
  logic config_done;

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

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      data_out <= 0;
    end else if (config_done) begin
      gain_out_bass = firbass * gain_bass;
      gain_out_mid = firmid * gain_mid;
      gain_out_high = firhigh * gain_high;

      sum_out = gain_out_bass + gain_out_mid + gain_out_high;

      // sum_out = gain_out_bass;
      // sum_out = gain_out_mid;
      // sum_out = gain_out_high;


      data_out = sum_out >>> 7;
    end
  end


  i2s_controller i2s_inst (
      .clk(clk),
      .reset(reset_n),
      .lrclk(lrclk),
      .bclk(bclk),
      .audio_in(data_in),
      .data_ready(data_ready),
      .audio_out(data_out)
  );

  i2c_controller i2c_inst (
      .clk(clk),
      .reset(reset),
      .i2c_scl(i2c_scl),
      .i2c_sda(i2c_sda),
      .config_done(config_done)
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
