module gain_control (
    input logic clk,
    input logic [2:0] sw_bass,
    sw_mid,
    sw_treble,
    output logic [7:0] gain_bass,
    gain_mid,
    gain_treble
);
  always @(posedge clk) begin
    case (sw_bass)
      3'b000: gain_bass <= 8'b00000000;  //0 
      3'b001: gain_bass <= 8'b00100000;  //0.25
      3'b010: gain_bass <= 8'b01000000;  //0.5 
      3'b011: gain_bass <= 8'b01100000;  //0.75
      3'b100: gain_bass <= 8'b10000000;  //1
      3'b101: gain_bass <= 8'b10100000;  //1.25
      3'b110: gain_bass <= 8'b11000000;  //1.5
      3'b111: gain_bass <= 8'b11100000;  //2.0
      default: begin
        gain_bass <= 8'b10000000;  //1
      end
    endcase

    case (sw_mid)
      3'b000: gain_mid <= 8'b00000000;  //0 
      3'b001: gain_mid <= 8'b00100000;  // 0.25
      3'b010: gain_mid <= 8'b01000000;  //0.5 
      3'b011: gain_mid <= 8'b01100000;  //0.75
      3'b100: gain_mid <= 8'b10000000;  //1
      3'b101: gain_mid <= 8'b10100000;  //1.25
      3'b110: gain_mid <= 8'b11000000;  //1.5
      3'b111: gain_mid <= 8'b11100000;  //1.5
      default: begin
        gain_mid <= 8'b10000000;  //1
      end
    endcase

    case (sw_treble)
      3'b000: gain_treble <= 8'b00000000;  //0 
      3'b001: gain_treble <= 8'b00100000;  // 0.25
      3'b010: gain_treble <= 8'b01000000;  //0.5 
      3'b011: gain_treble <= 8'b01100000;  //0.75
      3'b100: gain_treble <= 8'b10000000;  //1
      3'b101: gain_treble <= 8'b10100000;  //1.25
      3'b110: gain_treble <= 8'b11000000;  //1.5
      3'b111: gain_treble <= 8'b11100000;  //1.5
      default: begin
        gain_treble <= 8'b10000000;  //1
      end
    endcase
  end
endmodule
