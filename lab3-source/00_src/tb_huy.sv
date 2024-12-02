module tb_audio_equalizer ();
    localparam FILE_PATH = "C:/Users/huyng/Downloads/audio_equalizer/00_src/input.hex";
    localparam OUT_PATH  = "C:/Users/huyng/Downloads/audio_equalizer/00_src/output.hex";
    localparam BASS_PATH = "C:/Users/huyng/Downloads/audio_equalizer/00_src/bass_scaled.hex";  // New file for bass_scaled
    localparam MID_PATH = "C:/Users/huyng/Downloads/audio_equalizer/00_src/mid_scaled.hex";  // New file for bass_scaled
    localparam TREB_PATH = "C:/Users/huyng/Downloads/audio_equalizer/00_src/treb_scaled.hex";  // New file for bass_scaled
    localparam O_S_BASS_PATH = "C:/Users/huyng/Downloads/audio_equalizer/00_src/output_sample_bass.hex";  // New file for bass_scaled
    localparam O_S_MID_PATH = "C:/Users/huyng/Downloads/audio_equalizer/00_src/output_sample_mid.hex";  // New file for bass_scaled
    localparam O_S_TREB_PATH = "C:/Users/huyng/Downloads/audio_equalizer/00_src/output_sample_treb.hex";  // New file for bass_scaled
  
    localparam FREQ = 100_000_000;
  
    localparam WD_IN       = 24;  // Data width
    localparam WD_OUT      = 24;  // Output data width
    localparam PERIOD      = 1_000_000_000 / FREQ;
    localparam HALF_PERIOD = PERIOD / 2;
  
    // Testbench signals
    reg               sample_clock, reset;
    //reg [2:0]         gain_switch;
    //reg [1:0]         band_select;
    reg [WD_IN-1:0]   input_sample;
    wire [WD_OUT-1:0] output_sample;
    wire [47:0]       bass_scaled;  // Wire to capture the bass_scaled value
    wire [47:0]       mid_scaled;
    wire [47:0]       treb_scaled;
    wire signed [23:0] output_sample_treb, output_sample_mid, output_sample_bass;
  
    integer file, status, outfile, bassfile, midfile, trebfile, o_s_bassfile,o_s_midfile, o_s_trebfile;  // File descriptors
  
    real analog_in, analog_out;
    assign analog_in  = $itor($signed(input_sample));
    assign analog_out = $itor($signed(output_sample));
  
    // Instantiate the audio_equalizer module
    audio_equalizer dut (
      .sample_clock   (sample_clock),
      .reset          (reset),
      //.band_select    (band_select),
     // .gain_switch    (gain_switch),
      .input_sample   (input_sample),
      .output_sample  (output_sample)
    );
  
    // Clock generation
    always #HALF_PERIOD sample_clock = ~sample_clock;
  
    // Test procedure
    initial begin
      // Initialize inputs
      sample_clock = 0;
      reset = 0;
      input_sample = 0;
      //gain_switch = 0;
     // band_select = 0;
  
      // Apply reset
      #PERIOD reset = 1;  // Deassert reset after a period
      //gain_switch = 3'b001;
     // band_select = 2'b00;
  
      // Open hex input file and output files
      file = $fopen(FILE_PATH, "r");
      outfile = $fopen(OUT_PATH, "w");
      bassfile = $fopen(BASS_PATH, "w");  // Open bass_scaled output file
      midfile = $fopen(MID_PATH, "w"); 
      trebfile = $fopen(TREB_PATH, "w"); 
      o_s_bassfile = $fopen(O_S_BASS_PATH, "w"); 
      o_s_midfile = $fopen(O_S_MID_PATH, "w"); 
      o_s_trebfile = $fopen(O_S_TREB_PATH, "w"); 
      
      if (file == 0) $error("Hex file not opened");
      if (outfile == 0) $error("Output file not opened");
    if (bassfile == 0) $error("Bass scaled file not opened");
    if (midfile == 0) $error("Bass scaled file not opened");
    if (trebfile == 0) $error("Bass scaled file not opened");
    if (o_s_bassfile == 0) $error("Bass scaled file not opened");
    if (o_s_midfile == 0) $error("Bass scaled file not opened");
    if (o_s_trebfile == 0) $error("Bass scaled file not opened");

    // Read hex file and apply input samples
    do begin
      status = $fscanf(file, "%h", input_sample);

      // Wait for sample clock edge
      @(posedge sample_clock);

      // Write output_sample to output.hex
      $fdisplay(outfile, "%h", output_sample);
      
      // Write bass_scaled value to bass_scaled.hex
      // Capture bass_scaled signal value (scaled bass signal)
      $fdisplay(bassfile, "%h", dut.bass_scaled[47:24]);  // Use the upper 24 bits of bass_scaled
      $fdisplay(midfile, "%h", dut.mid_scaled[47:24]);  // Use the upper 24 bits of bass_scaled
      $fdisplay(trebfile, "%h", dut.treb_scaled[47:24]);  // Use the upper 24 bits of bass_scaled
      $fdisplay(o_s_bassfile, "%h", dut.output_sample_bass[23:0]);  // Use the upper 24 bits of bass_scaled
      $fdisplay(o_s_midfile, "%h", dut.output_sample_mid[23:0]);  // Use the upper 24 bits of bass_scaled
      $fdisplay(o_s_trebfile, "%h", dut.output_sample_treb[23:0]);  // Use the upper 24 bits of bass_scaled

    end while (status != -1);

    // Wait for a while to observe output
    #100 $finish;  // Stop simulation after 100 time units

    // Close files
    $fclose(file);
    $fclose(outfile);
    $fclose(bassfile);  // Close bass_scaled output file
    $fclose(midfile);
    $fclose(trebfile);
    $fclose(o_s_bassfile);
    $fclose(o_s_midfile);
    $fclose(o_s_trebfile);
  end
  // Monitor signals for debugging
  initial begin
    $monitor("Time = %0t | Reset = %b | Data In = %h | Data Out = %h | Bass Scaled = %h | mid Scaled = %h | treb Scaled = %h | o_s_bass  = %h | o_s_mid = %h | o_s_treb  = %h",
      $time, reset, input_sample, output_sample, dut.bass_scaled[47:24], dut.mid_scaled[47:24], dut.treb_scaled[47:24], dut.output_sample_bass[23:0],dut.output_sample_mid[23:0],dut.output_sample_treb[23:0]);  // Monitor bass_scaled
  end

endmodule