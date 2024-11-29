module top_wrapper (
    input  logic CLOCK_50,  // Clock 50 MHz từ kit DE10
    input  logic RESET_N,   // Nút reset từ DE10
    output wire I2C_SCL,   // Clock I2C
    inout  wire I2C_SDA,   // Dữ liệu I2C
    input  logic I2S_WS,    // Word Select của I2S
    input  logic I2S_SCLK,  // Serial Clock của I2S
    inout  wire I2S_SD     // Dữ liệu âm thanh I2S
);

  // Clock và Reset
  logic clk;
  logic rst_n;

  assign clk   = CLOCK_50;  // Sử dụng clock 50 MHz từ DE10
  assign rst_n = RESET_N;  // Reset active-low từ nút bấm

  // Tín hiệu nội bộ
  logic [23:0] audio_in, audio_out;

  // Kết nối module điều khiển I2C
  i2c_controller i2c_instt (
      .clk      (clk),
      .rst_n    (rst_n),
      .start    (1'b1),     // Luôn bắt đầu cấu hình khi khởi động
      .dev_addr (7'h34),    // Địa chỉ codec
      .reg_addr (8'h12),    // Thanh ghi codec
      .data     (8'h80),    // Giá trị cấu hình
      .busy     (),
      .ack_error(),
      .sda      (I2C_SDA),
      .scl      (I2C_SCL)
  );

  // Kết nối module điều khiển I2S
  i2s_controller i2s_inst (
      .clk(clk),
      .rst_n(rst_n),
      .din(audio_out),
      .dout(audio_in),
      .ws(I2S_WS),
      .sclk(I2S_SCLK),
      .sd(I2S_SD)
  );

  // Kết nối module lọc âm thanh FIR
  fir_filter #(
      .TAPS(5)
  ) fir_inst (
      .clk  (clk),
      .rst_n(rst_n),
      .din  (audio_in),
      .dout (audio_out)
  );

endmodule
