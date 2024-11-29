module i2s_controller (
    input  logic        clk,
    input  logic        reset,
    input  logic        lrclk,
    input  logic        bclk,
    input  logic [23:0] audio_in,
    output logic [23:0] audio_out,
    output logic        data_ready
);

    logic [4:0] bit_counter;
    logic [23:0] audio_buffer;

    always_ff @(posedge bclk or posedge reset) begin
        if (reset) begin
            bit_counter <= 0;
            data_ready <= 0;
        end else if (bit_counter == 23) begin
            bit_counter <= 0;
            audio_out <= audio_buffer;
            data_ready <= 1;
        end else begin
            bit_counter <= bit_counter + 1;
            audio_buffer <= {audio_buffer[22:0], audio_in[23]};
            data_ready <= 0;
        end
    end

endmodule
