module fir_bass (
    clk,
    reset_n,
    data_in,
    data_out
);

  parameter N = 24;
  parameter N_coeff = 16;
  // parameter N_taps = 50;
  parameter N_taps = 61;

  input logic clk, reset_n;
  input logic signed [N-1:0] data_in;
  output logic signed [N-1:0] data_out;

  // logic signed [N_coeff-1:0] b [0:8] = '{16'h1,16'h2,16'h1,16'h1};
  // logic signed [N_coeff-1:0] b [0:8] = '{16'h04F6,16'h0AE4,16'h1089,16'h1496,16'h106F,16'h1496,16'h1089,16'h0AE4,16'h04F6};

  // fir filter pass fix 
  // 20Hz - 250Hz (bandpass)
  // logic signed [N_coeff-1:0] b[N_taps-1:0] = '{
  //     16'h0014,
  //     16'h001A,
  //     16'h002A,
  //     16'h003F,
  //     16'h005B,
  //     16'h007D,
  //     16'h00A7,
  //     16'h00D9,
  //     16'h0113,
  //     16'h0155,
  //     16'h019E,
  //     16'h01EF,
  //     16'h0246,
  //     16'h02A1,
  //     16'h02FF,
  //     16'h035E,
  //     16'h03BD,
  //     16'h0418,
  //     16'h046E,
  //     16'h04BD,
  //     16'h0502,
  //     16'h053C,
  //     16'h0569,
  //     16'h0587,
  //     16'h0597,
  //     16'h0597,
  //     16'h0587,
  //     16'h0569,
  //     16'h053C,
  //     16'h0502,
  //     16'h04BD,
  //     16'h046E,
  //     16'h0418,
  //     16'h03BD,
  //     16'h035E,
  //     16'h02FF,
  //     16'h02A1,
  //     16'h0246,
  //     16'h01EF,
  //     16'h019E,
  //     16'h0155,
  //     16'h0113,
  //     16'h00D9,
  //     16'h00A7,
  //     16'h007D,
  //     16'h005B,
  //     16'h003F,
  //     16'h002A,
  //     16'h001A,
  //     16'h0014
  // };
  // ;

  logic signed [N_coeff-1:0] b[N_taps-1:0] = {
    16'h01DD,
    16'h01E5,
    16'h01ED,
    16'h01F4,
    16'h01FC,
    16'h0203,
    16'h020A,
    16'h0210,
    16'h0217,
    16'h021D,
    16'h0223,
    16'h0229,
    16'h022F,
    16'h0234,
    16'h0239,
    16'h023E,
    16'h0242,
    16'h0246,
    16'h024A,
    16'h024E,
    16'h0251,
    16'h0254,
    16'h0256,
    16'h0259,
    16'h025B,
    16'h025D,
    16'h025E,
    16'h025F,
    16'h0260,
    16'h0260,
    16'h0261,
    16'h0260,
    16'h0260,
    16'h025F,
    16'h025E,
    16'h025D,
    16'h025B,
    16'h0259,
    16'h0256,
    16'h0254,
    16'h0251,
    16'h024E,
    16'h024A,
    16'h0246,
    16'h0242,
    16'h023E,
    16'h0239,
    16'h0234,
    16'h022F,
    16'h0229,
    16'h0223,
    16'h021D,
    16'h0217,
    16'h0210,
    16'h020A,
    16'h0203,
    16'h01FC,
    16'h01F4,
    16'h01ED,
    16'h01E5,
    16'h01DD
  };

  logic signed [N-1:0] x_delay[0:N_taps-1];


  logic signed [2*N-1:0] add_final;
  logic signed [2*N-1:0] temp_sum;
  logic signed [2*N-1:0] mullti[0:N_taps-1];

  // DFF DFF0 (clk, 0, data_in, x_delay[1]);
  // DFF DFF1 (clk, 0, x_delay[1], x_delay[2]);
  // DFF DFF2 (clk, 0, x_delay[2], x_delay[3]);

  genvar i;
  generate
   
    for (i = 0; i < N_taps; i++) begin : dff_block
      if (i == 0) begin
        DFF DFF4 (
            .clk(clk),
            .reset_n(reset_n),
            .data_in(data_in),
            .data_delayed(x_delay[i])
        );
      end else begin
        DFF DFF5 (
            .clk(clk),
            .reset_n(reset_n),
            .data_in(x_delay[i-1]),
            .data_delayed(x_delay[i])
        );
      end
    end
  endgenerate

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      for (int j = 0; j < N_taps; j++) begin
        x_delay[j] <= {24'b0};
        mullti[j]  <= {48'b0};
      end
      add_final <= 0;
    end else begin

      for (int j = 0; j < N_taps; j++) begin
        mullti[j] <= b[j] * x_delay[j];
      end

      add_final = 48'd0;
      temp_sum  = 48'd0;


      for (int j = 0; j < N_taps; j++) begin
        temp_sum = temp_sum + mullti[j];
      end
      add_final <= temp_sum;

    end
  end

  always_comb begin
    data_out = add_final[2*N-1:N-1];
  end



endmodule

