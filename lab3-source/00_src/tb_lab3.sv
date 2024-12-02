`timescale 1ns / 1ns

module tb_lab3 ();
  localparam FILE_PATH = "C:/Users/HieuLD/OneDrive/Documents/hcmut/4th/fpga/EE3041_DSPonFPGA-main/Lab1/samples/audio.hex";
  localparam OUT_PATH  = "C:/Users/HieuLD/OneDrive/Documents/hcmut/4th/fpga/EE3041_DSPonFPGA-main/Lab1/samples/audio_test_3011.hex";
  localparam FREQ = 100_000_000;

  localparam WD_IN = 24;  // Data width
  localparam WD_OUT = 24;
  localparam PERIOD = 1_000_000_000 / FREQ;
  localparam HALF_PERIOD = PERIOD / 2;

  // Testbench signals
  reg clk, reset_n;
  reg [2:0] sw_gain;
  reg [1:0] sw_mode;

  reg [WD_IN-1:0] data_in;
  wire [WD_OUT-1:0] data_out;

  integer file, status, outfile;

  // Instantiate the DUT
  audio_equalizer dut (
      .clk     (clk),
      .reset_n (reset_n),
      .sw_gain (sw_gain),
      .sw_mode (sw_mode),
      .data_in (data_in),
      .data_out(data_out)
  );

  // Clock generation
  always #HALF_PERIOD clk = ~clk;

  // Test procedure
  initial begin
    // Initialize inputs
    clk     = 0;
    reset_n = 0;
    sw_gain = 3'b000;
    sw_mode = 2'b00;
    data_in = 0;

    // Apply reset
    #PERIOD reset_n = 1;

    // Open files
    file = $fopen(FILE_PATH, "r");
    outfile = $fopen(OUT_PATH, "w");
    if (file == 0) $error("Hex file not opened");
    if (outfile == 0) $error("Output file not opened");

    // Read hex file and test different modes
    sw_mode = 2'b01;
    sw_gain = 3'b100;
    repeat (10) @(posedge clk);
    sw_mode = 2'b10;
    sw_gain = 3'b101;
    repeat (20) @(posedge clk);

    sw_mode = 2'b11;
    sw_gain = 3'b011;
    repeat (15) @(posedge clk);
    while (!$feof(
        file
    )) begin
    status  = $fscanf(file, "%h", data_in);
    @(posedge clk);
    $fdisplay(outfile, "%h", data_out);
    // end

    // Close files
    $fclose(file);
    $fclose(outfile);
    $finish;
  end
end

  // Monitor signals
  initial begin
    $monitor("Time=%0t | Reset=%b | Mode=%b | Gain=%b | Data_in=%h | Data_out=%h", $time, reset_n,
             sw_mode, sw_gain, data_in, data_out);
  end
endmodule
