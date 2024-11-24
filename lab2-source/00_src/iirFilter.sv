module iirFilter (
    clk,
    rst_n,
    data_in,
    data_out
);
  // 6 taps = 3 section 

  parameter N = 24;

  input logic clk, rst_n;
  input logic signed [N-1:0] data_in;
  output logic signed [N-1:0] data_out;

  // logic signed [N-1:0] b_section1[0:2] = '{25687, 51374, 25687};
  // logic signed [N-1:0] a_section1[0:1] = '{-1833333, 887505};

  // logic signed [N-1:0] b_section2[0:2] = '{22671, 45342, 22671};
  // logic signed [N-1:0] a_section2[0:1] = '{-1618079, 660188};

  // logic signed [N-1:0] b_section3[0:2] = '{21229, 42458, 21229};
  // logic signed [N-1:0] a_section3[0:1] = '{-1515355, 551719};

  // //fc = 6k
  // logic signed [N-1:0] b_section1[0:2] = '{129804, 259608, 129804};
  // logic signed [N-1:0] a_section1[0:1] = '{-1253503, 724145};

  // logic signed [N-1:0] b_section2[0:2] = '{102374, 204747, 102374};
  // logic signed [N-1:0] a_section2[0:1] = '{-988606, 349525};

  // logic signed [N-1:0] b_section3[0:2] = '{91241, 182482, 91241};
  // logic signed [N-1:0] a_section3[0:1] = '{-881104, 197494};

      logic signed [N-1:0] b_section1[0:2] = '{5509, 11019, 5509};
  logic signed [N-1:0] a_section1[0:1] = '{-1998080, 971584};

  logic signed [N-1:0] b_section2[0:2] = '{5180, 10360, 5180};
  logic signed [N-1:0] a_section2[0:1] = '{-1878592, 850752};

  logic signed [N-1:0] b_section3[0:2] = '{5007, 10014, 5007};
  logic signed [N-1:0] a_section3[0:1] = '{-1815872, 787328};

  logic signed [N-1:0] section12, section23;

  logic signed [2*N-1:0] x_delaySection1[0:1];
  logic signed [2*N-1:0] y_delaySection1[0:1];

  logic signed [2*N-1:0] x_delaySection2[0:1];
  logic signed [2*N-1:0] y_delaySection2[0:1];


  logic signed [2*N-1:0] x_delaySection3[0:1];
  logic signed [2*N-1:0] y_delaySection3[0:1];


  logic signed [2*N-1:0] add_b_setion1, add_b_setion2, add_b_setion3;
  logic signed [2*N-1:0] add_a_section1, add_a_section2, add_a_section3;

  // section 1
  assign add_b_setion1 = data_in* b_section1[0] + x_delaySection1[0]*b_section1[1] + x_delaySection1[1]*b_section1[2];
  assign add_a_section1 = add_b_setion1 - y_delaySection1[0]*a_section1[0] - y_delaySection1[1]*a_section1[1];
  assign section12 = add_a_section1 >> 20;


  // section 2
  assign add_b_setion2 = section12* b_section2[0] + x_delaySection2[0]*b_section2[1] + x_delaySection2[1]*b_section2[2];
  assign add_a_section2 = add_b_setion2 - y_delaySection2[0]*a_section2[0] - y_delaySection2[1]*a_section2[1];
  assign section23 = add_a_section2 >> 20;

  // section 3
  assign add_b_setion3 = section23* b_section3[0] + x_delaySection3[0]*b_section3[1] + x_delaySection3[1]*b_section3[2];
  assign add_a_section3 = add_b_setion3 - y_delaySection3[0]*a_section3[0] - y_delaySection3[1]*a_section3[1];
  assign data_out = add_a_section3 >> 20;


  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      for (int i = 0; i < 2; i++) begin
        x_delaySection1[i] <= 24'd0;
        y_delaySection1[i] <= 24'd0;

        x_delaySection2[i] <= 24'd0;
        y_delaySection2[i] <= 24'd0;

        x_delaySection3[i] <= 24'd0;
        y_delaySection3[i] <= 24'd0;
      end
    end else begin
      // section 1
      x_delaySection1[0] <= data_in;
      x_delaySection1[1] <= x_delaySection1[0];

      y_delaySection1[0] <= section12;
      y_delaySection1[1] <= y_delaySection1[0];

      // section 2
      x_delaySection2[0] <= section12;
      x_delaySection2[1] <= x_delaySection2[0];

      y_delaySection2[0] <= section23;
      y_delaySection2[1] <= y_delaySection2[0];

      // section 3
      x_delaySection3[0] <= section23;
      x_delaySection3[1] <= x_delaySection3[0];

      y_delaySection3[0] <= data_out;
      y_delaySection3[1] <= y_delaySection3[0];
    end
  end
endmodule
