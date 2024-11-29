module i2s_interface (
    input  logic [23:0] audio_left,  // Âm thanh kênh trái
    input  logic [23:0] audio_right, // Âm thanh kênh phải
    input  logic clk,                // Clock chính
    input  logic reset,              // Reset
    output logic i2s_clk,            // Clock I2S
    output logic i2s_ws,             // Word select (trái/phải)
    output logic i2s_data            // Dữ liệu âm thanh
);
    logic [47:0] shift_reg; // Shift register chứa dữ liệu
    logic [5:0] bit_cnt;    // Bộ đếm bit

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 0;
            bit_cnt   <= 0;
            i2s_ws    <= 0;
            i2s_data  <= 0;
        end else begin
            if (bit_cnt == 0) begin
                // Nạp dữ liệu kênh trái/phải
                shift_reg <= {audio_left, audio_right};
                i2s_ws    <= ~i2s_ws;
            end else begin
                // Xuất từng bit
                i2s_data <= shift_reg[47];
                shift_reg <= {shift_reg[46:0], 1'b0};
            end
            bit_cnt <= bit_cnt + 1;
        end
    end

    assign i2s_clk = clk; // Sử dụng clock chính làm clock I2S
endmodule
