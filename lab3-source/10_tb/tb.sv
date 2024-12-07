`timescale 1ns / 1ns

module tb ();
  localparam FILE_AUDIO_ORG_PATH ="C:/Users/HieuLD/OneDrive/Documents/hcmut/4th/fpga/EE3041_DSPonFPGA-main/Lab1/samples/audio.hex";

  localparam OUT_PATH  = "C:/Users/HieuLD/OneDrive/Documents/hcmut/4th/fpga/EE3041_DSPonFPGA-main/Lab1/samples/o_audio_v3_1.hex";
  localparam FREQ = 100_000_000;

  localparam WD_IN = 24;  // Data width
  localparam WD_OUT = 24;
  localparam PERIOD = 1_000_000_000 / FREQ;
  localparam HALF_PERIOD = PERIOD / 2;

  // Testbench signals
  reg clk, reset_n;
  reg  [ WD_IN-1:0] data_in;
  wire [WD_OUT-1:0] data_out;
  reg [2:0] sw_bass, sw_mid, sw_treble;
  integer file, status, outfile;

  real analog_in, analog_out;
  assign analog_in  = $itor($signed(data_in));
  assign analog_out = $itor($signed(data_out));

  //   assign sw_bass = 3'b100;
  //   assign sw_mid = 3'b000;
  //   assign sw_treble = 3'b100;
  audio_equalizer dut (
      .clk      (clk),
      .reset_n  (reset_n),
      .sw_bass  (sw_bass),
      .sw_mid   (sw_mid),
      .sw_treble(sw_treble),
      .data_in  (data_in),
      .data_out (data_out)
  );
  initial begin
    sw_bass = 3'b010;
    sw_mid = 3'b010;
    sw_treble = 3'b010;
  end
  // Clock generation
  always #HALF_PERIOD clk = ~clk;


  // Test procedure
  initial begin
    // Initialize inputs
    clk     = 0;
    reset_n = 0;
    data_in = 0;

    // Apply reset
    #PERIOD reset_n = 1;  // Deassert reset after a period

    // Read hex file
    file = $fopen(FILE_AUDIO_ORG_PATH, "r");
    outfile = $fopen(OUT_PATH, "w");
    if (file == 0) $error("Hex file not opened");
    if (outfile == 0) $error("Output file not opened");
    do begin
      status = $fscanf(file, "%h", data_in);
      @(posedge clk);
      $fdisplay(outfile, "%h", data_out);
    end while (status != -1);

    // Wait for a while to observe output
    #100 $finish;  // Stop simulation after 100 time units
    $fclose(file);
    $fclose(outfile);
  end

  // Monitor signals for debugging
  initial begin
    $monitor("Time = %0t | Reset = %b | Data In = %h | Data Out = %h", $time, reset_n, data_in,
             data_out);
  end

endmodule
