module test (
    input logic clk,
    reset,
    input logic signed [23:0] audio_in,
    output logic signed [23:0] audio_out
);
  logic signed [31:0] audioOutt;

  always_comb begin
    // audioOutt = audio_in * 8'b10100000;
    // audio_out = audioOutt >>> 7;
    audioOutt = audio_in * 8'b00100000;
    audio_out = audioOutt >>> 7;
  end

endmodule

// module  (
//     input logic clk,reset_n,
//     input logic signed [23:0] audio_in,
//     output logic signed [23:0] audio_out
// );
