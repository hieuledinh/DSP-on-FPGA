module iirFilterMultiSec (
    clk,
    rst_n,
    data_in,
    data_out
);

  parameter N = 24;

  input logic clk, rst_n;
  input logic signed [N-1:0] data_in;
  output logic signed [N-1:0] data_out;

  logic signed [N-1:0] b_section1 [0:2] = '{245465, 490930, 245465};
  logic signed [N-1:0] a_section1 [0:1] = '{-981860, 915145};

  logic signed [N-1:0] b_section2 [0:2] = '{218059, 436118, 218059};
  logic signed [N-1:0] a_section2 [0:1] = '{-872236, 695896};

  logic signed [N-1:0] b_section3 [0:2] = '{196891, 393782, 196891};
  logic signed [N-1:0] a_section3 [0:1] = '{-787565, 526555};

  logic signed [N-1:0] b_section4 [0:2] = '{180478, 360956, 180478};
  logic signed [N-1:0] a_section4 [0:1] = '{-721912, 395249};

  logic signed [N-1:0] b_section5 [0:2] = '{167778, 335557, 167778};
  logic signed [N-1:0] a_section5 [0:1] = '{-671115, 293654};

  // 5 taps 

  logic signed [N-1:0] b_section6 [0:2] = '{158057, 316115, 158057};
  logic signed [N-1:0] a_section6 [0:1] = '{-632231, 215887};

  logic signed [N-1:0] b_section7 [0:2] = '{150795, 301590, 150795};
  logic signed [N-1:0] a_section7 [0:1] = '{-603181, 157787};

  logic signed [N-1:0] b_section8 [0:2] = '{145627, 291254, 145627};
  logic signed [N-1:0] a_section8 [0:1] = '{-582508, 116441};

  logic signed [N-1:0] b_section9 [0:2] = '{142307, 284614, 142307};
  logic signed [N-1:0] a_section9 [0:1] = '{-569229, 89883};

  logic signed [N-1:0] b_section10[0:2] = '{140683, 281367, 140683};
  logic signed [N-1:0] a_section10[0:1] = '{-562735, 76894};

  logic signed [N-1:0]
      section12,
      section23,
      section34,
      section45,
      section56,
      section67,
      section78,
      section89,
      section910;

  logic signed [2*N-1:0] x_delaySection[0:9][0:1];
  logic signed [2*N-1:0] y_delaySection[0:9][0:1];

  logic signed [2*N-1:0]
      add_b_setion1,
      add_b_setion2,
      add_b_setion3,
      add_b_section4,
      add_b_section5,
      add_b_setion6,
      add_b_setion7,
      add_b_setion8,
      add_b_section9,
      add_b_section10;
  logic signed [2*N-1:0]
      add_a_section1,
      add_a_section2,
      add_a_section3,
      add_a_section4,
      add_a_section5,
      add_a_section6,
      add_a_section7,
      add_a_section8,
      add_a_section9,
      add_a_section10;

  // section 1
  assign add_b_setion1 = data_in* b_section1[0] + x_delaySection[0][0]*b_section1[1] + x_delaySection[0][1]*b_section1[2] ;
  assign add_a_section1 = add_b_setion1 - y_delaySection[0][0]*a_section1[0] - y_delaySection[0][1]*a_section1[1];
  assign section12 = add_a_section1 >> 20;

  // section 2
  assign add_b_setion2 = section12* b_section2[0] + x_delaySection[1][0]*b_section2[1] + x_delaySection[1][1]*b_section2[2];
  assign add_a_section2 = add_b_setion2 - y_delaySection[1][0]*a_section2[0] - y_delaySection[1][1]*a_section2[1];
  assign section23 = add_a_section2 >> 20;

  // section 3
  assign add_b_setion3 = section23* b_section3[0] + x_delaySection[2][0]*b_section3[1] + x_delaySection[2][1]*b_section3[2];
  assign add_a_section3 = add_b_setion3 - y_delaySection[2][0]*a_section3[0] - y_delaySection[2][1]*a_section3[1];
  assign section34 = add_a_section3 >> 20;

  // section 4
  assign add_b_section4 = section34 * b_section4[0] + x_delaySection[3][0]*b_section4[1] + x_delaySection[3][1] * b_section4[2];
  assign add_a_section4 = add_b_section4 - y_delaySection[3][0] *a_section4[0] - y_delaySection[3][1] * a_section4[1];
  assign section45 = add_a_section4 >> 20;

  // section 5 
  assign add_b_section5 = section45 * b_section5[0] + x_delaySection[4][0]*b_section5[1] + x_delaySection[4][1] * b_section5[2];
  assign add_a_section5 = add_b_section5 - y_delaySection[4][0] * a_section5[0] - y_delaySection[4][1] * a_section5[1];
  assign section56 = add_a_section5 >> 20;


    // section 6
  assign add_b_setion6 = section56* b_section6[0] + x_delaySection[5][0]*b_section6[1] + x_delaySection[5][1]*b_section6[2] ;
  assign add_a_section6 = add_b_setion6 - y_delaySection[5][0]*a_section6[0] - y_delaySection[5][1]*a_section6[1];
  assign section67 = add_a_section6 >> 20;

  // section 7
  assign add_b_setion7 = section67* b_section7[0] + x_delaySection[6][0]*b_section7[1] + x_delaySection[6][1]*b_section7[2];
  assign add_a_section7 = add_b_setion7 - y_delaySection[6][0]*a_section7[0] - y_delaySection[6][1]*a_section7[1];
  assign section78 = add_a_section7 >> 20;

  // section 8
  assign add_b_setion8 = section78* b_section8[0] + x_delaySection[7][0]*b_section8[1] + x_delaySection[7][1]*b_section8[2];
  assign add_a_section8 = add_b_setion8 - y_delaySection[7][0]*a_section8[0] - y_delaySection[7][1]*a_section8[1];
  assign section89 = add_a_section8 >> 20;

  // section 9
  assign add_b_section9 = section89 * b_section9[0] + x_delaySection[8][0]*b_section9[1] + x_delaySection[8][1] * b_section9[2];
  assign add_a_section9 = add_b_section9 - y_delaySection[8][0] *a_section9[0] - y_delaySection[8][1] * a_section9[1];
  assign section910 = add_a_section9 >> 20;

  // section 10 
  assign add_b_section10 = section910 * b_section9[0] + x_delaySection[9][0]*b_section10[1] + x_delaySection[9][1] * b_section10[2];
  assign add_a_section10 = add_b_section10 - y_delaySection[9][0] * a_section10[0] - y_delaySection[9][1] * a_section10[1];
  assign data_out = add_a_section10 >> 20;




  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      for (int j = 0; j < 10; j++) begin
        for (int i = 0; i < 2; i++) begin
          x_delaySection[j][i] <= 24'd0;
          y_delaySection[j][i] <= 24'd0;
        end
      end
    end else begin
      // section 1
      x_delaySection[0][0] <= data_in;
      x_delaySection[0][1] <= x_delaySection[0][0];

      y_delaySection[0][0] <= section12;
      y_delaySection[0][1] <= y_delaySection[0][0];

      // section 2
      x_delaySection[1][0] <= section12;
      x_delaySection[1][1] <= x_delaySection[1][0];

      y_delaySection[1][0] <= section23;
      y_delaySection[1][1] <= y_delaySection[1][0];

      // section 3
      x_delaySection[2][0] <= section23;
      x_delaySection[2][1] <= x_delaySection[2][0];

      y_delaySection[2][0] <= section34;
      y_delaySection[2][1] <= y_delaySection[2][0];

      //section 4
      x_delaySection[3][0] <= section34;
      x_delaySection[3][1] <= x_delaySection[3][0];

      y_delaySection[3][0] <= section45;
      y_delaySection[3][1] <= y_delaySection[3][0];

      //section 5
      x_delaySection[4][0] <= section45;
      x_delaySection[4][1] <= x_delaySection[4][0];

      y_delaySection[4][0] <= section56;
      y_delaySection[4][1] <= y_delaySection[4][0];

      //section 6
      x_delaySection[5][0] <= section56;
      x_delaySection[5][1] <= x_delaySection[5][0];

      y_delaySection[5][0] <= section67;
      y_delaySection[5][1] <= y_delaySection[5][0];

      //section 7
      x_delaySection[6][0] <= section67;
      x_delaySection[6][1] <= x_delaySection[6][0];

      y_delaySection[6][0] <= data_out;
      y_delaySection[6][1] <= y_delaySection[6][0];

      //section 8
      x_delaySection[7][0] <= section78;
      x_delaySection[7][1] <= x_delaySection[7][0];

      y_delaySection[7][0] <= section89;
      y_delaySection[7][1] <= y_delaySection[7][0];

      //section 9
      x_delaySection[8][0] <= section89;
      x_delaySection[8][1] <= x_delaySection[8][0];

      y_delaySection[8][0] <= section910;
      y_delaySection[8][1] <= y_delaySection[8][0];

      //section 10
      x_delaySection[9][0] <= section910;
      x_delaySection[9][1] <= x_delaySection[9][0];

      y_delaySection[9][0] <= data_out;
      y_delaySection[9][1] <= y_delaySection[9][0];
    end
  end
endmodule
