module gain_control (
    input logic clk,
    input logic [2:0] sw,
    output logic [7:0] gain
);
  always @(posedge clk) begin
    case (sw)
      3'b000: gain <= 8'b00000000;  //0 
      3'b001: gain <= 8'b00100000;  // 0.25
      3'b010: gain <= 8'b01000000;  //0.5 
      3'b011: gain <= 8'b01100000;  //0.75
      3'b100: gain <= 8'b10000000;  //1
      3'b101: gain <= 8'b10100000;  //1.25
      3'b110: gain <= 8'b11000000;  //1.5
      3'b111: gain <= 8'b11100000;  //1.5
      default: begin
        gain <= 8'b10000000;  //1
      end
    endcase
  end
endmodule
