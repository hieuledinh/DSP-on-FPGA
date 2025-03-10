module FIR_direct (clk, reset_n, data_in, data_out);

parameter N = 24 ;
parameter N_coeff = 16;
parameter N_taps = 9; 

input logic clk, reset_n;
input logic signed [N-1:0] data_in;
output logic signed [N-1:0] data_out;

logic signed [N_coeff-1:0] b[N_taps-1:0] = '{ 
16'h17CC, 
16'h0510, 
16'h055F, 
16'h0594, 
16'h05A9, 
16'h0594, 
16'h055F, 
16'h0510, 
16'h17CC};

logic signed [N-1:0] x_delay [0:N_taps-1];


logic signed [2*N-1:0] add_final;
logic signed [2*N-1:0] temp_sum;
logic signed [2*N-1:0] multi[0:N_taps-1];

        // DFF DFF0 (clk, 0, data_in, x_delay[1]);
        // DFF DFF1 (clk, 0, x_delay[1], x_delay[2]);
        // DFF DFF2 (clk, 0, x_delay[2], x_delay[3]);
        genvar i;
        generate;
            for (i=0; i< N_taps;i++) begin :dff_block
                if(i==0) begin
                DFF DFF0 (
                    .clk(clk),
                    .reset_n(reset_n),
                    .data_in(data_in),
                    .data_delayed(x_delay[i])
                );
                end
                else begin
                DFF DFF1 (
                    .clk (clk),
                    .reset_n(reset_n),
                    .data_in(x_delay[i-1]),
                    .data_delayed(x_delay[i])
                );
                end
            end
        endgenerate

  always_ff @(posedge clk or negedge reset_n) begin: mult_block
	if (!reset_n) begin
        for(int j = 0; j < N_taps; j++) begin
            x_delay[j] <= 0;
            multi[j] <= 0;
        end

	end
    else begin
        multi[0] <= b[0]*x_delay[0];
        multi[1] <= b[1]*x_delay[1];
        multi[2] <= b[2]*x_delay[2];
        multi[3] <= b[3]*x_delay[3];
        multi[4] <= b[4]*x_delay[4];
        multi[5] <= b[5]*x_delay[5];
        multi[6] <= b[6]*x_delay[6];
        multi[7] <= b[7]*x_delay[7];
        multi[8] <= b[8]*x_delay[8];
  end
end

always_comb begin: sum_block
    add_final = 0;   
    add_final = multi[8] + multi[7] + multi[6]+ multi[5]+ multi[4]+ multi[3]+ multi[2]+ multi[1]+ multi[0];
    data_out = add_final[2*N-1:N-1];
end
    
    
endmodule

module DFF(clk, reset_n, data_in, data_delayed);
parameter N = 24;

input clk, reset_n;
input logic signed [N-1:0] data_in;
output logic signed [N-1:0] data_delayed;

always_ff@(posedge clk or negedge reset_n) begin: dff
    if (!reset_n) begin
        data_delayed <= 0;
    end
    else begin
        data_delayed <= data_in;
    end
end
endmodule
