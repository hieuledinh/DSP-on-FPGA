`timescale 1ns / 1ns

module tb;
  localparam FILE_PATH = "C:/Users/HieuLD/OneDrive/Documents/hcmut/4th/fpga/EE3041_DSPonFPGA-main/Lab1/samples/audio.hex";
  localparam OUT_PATH  = "C:/Users/HieuLD/OneDrive/Documents/hcmut/4th/fpga/EE3041_DSPonFPGA-main/Lab1/samples/audio_test_3011.hex";
  localparam FREQ = 100_000_000;  // 100 MHz clock
  localparam PERIOD = 1_000_000_000 / FREQ;
  localparam HALF_PERIOD = PERIOD / 2;

  // Tín hiệu testbench
  reg clk, reset_n;
  reg [2:0] sw_gain;
  reg [1:0] sw_mode;
  reg signed [23:0] data_in;
  wire signed [23:0] data_out;

  integer file, outfile, status;

  // Gắn DUT
  audio_equalizer dut (
      .clk(clk),
      .reset_n(reset_n),
      .sw_gain(sw_gain),
      .sw_mode(sw_mode),
      .data_in(data_in),
      .data_out(data_out)
  );

  // Tạo tín hiệu đồng hồ
  always #HALF_PERIOD clk = ~clk;

  // Danh sách test case
  typedef struct {
    reg [1:0] mode;
    reg [2:0] gain;
  } test_case_t;

  test_case_t test_cases[8] = '{
      '{2'b01, 3'b010},  // Bass, Gain 2
      '{2'b10, 3'b101},  // Mid, Gain 5
      '{2'b11, 3'b000},  // High, Gain 1
      '{2'b00, 3'b100},  // Default, Gain 4
      '{2'b01, 3'b111},  // Bass, Gain 7
      '{2'b10, 3'b000},  // Mid, Gain 0
      '{2'b11, 3'b011},  // High, Gain 3
      '{2'b00, 3'b110}
  };  // Default, Gain 6

  // Thủ tục kiểm tra
  initial begin
    // Khởi tạo tín hiệu
    clk = 0;
    reset_n = 0;
    data_in = 24'sd0;

    // Đặt lại module
    #PERIOD reset_n = 1;

    // Mở file đầu vào và đầu ra
    file = $fopen(FILE_PATH, "r");
    outfile = $fopen(OUT_PATH, "w");
    if (file == 0) $error("Không mở được file đầu vào!");
    if (outfile == 0) $error("Không mở được file đầu ra!");

    // Đọc dữ liệu từ file và áp dụng các test case
    $display("Đang thực hiện kiểm tra...");
    while (!$feof(
        file
    )) begin
      status = $fscanf(file, "%h", data_in);

      foreach (test_cases[i]) begin
        sw_mode = test_cases[i].mode;  // Thiết lập sw_mode
        sw_gain = test_cases[i].gain;  // Thiết lập sw_gain
        @(posedge clk);

        // Ghi kết quả ra file
        $fdisplay(outfile, "Test case %0d: sw_mode=%b, sw_gain=%b, data_out=%h", i, sw_mode,
                  sw_gain, data_out);

        // Hiển thị thông tin kiểm tra
        $display("Test case %0d | sw_mode=%b | sw_gain=%b | data_in=%h | data_out=%h", i, sw_mode,
                 sw_gain, data_in, data_out);
      end
    end

    // Kết thúc mô phỏng
    $fclose(file);
    $fclose(outfile);
    $display("Kết thúc mô phỏng.");
    #100 $finish;
  end
endmodule
