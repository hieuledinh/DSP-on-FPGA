module i2s_audio (
    input clk,              // Clock chính
    input bclk,             // Bit Clock (BCLK)
    input lrclk,            // Left/Right Clock (LRCLK)
    input [23:0] audio_in,  // Dữ liệu âm thanh đầu vào (24-bit)
    output reg [23:0] audio_out, // Dữ liệu âm thanh đầu ra (24-bit)
    output reg sdin,        // Dữ liệu I2S truyền đi
    input sdin_in           // Dữ liệu I2S nhận về
);

    reg [4:0] bit_count;      // Đếm bit (0 đến 23)
    reg [23:0] shift_reg_in;  // Thanh ghi dịch dữ liệu đầu vào
    reg [23:0] shift_reg_out; // Thanh ghi dịch dữ liệu đầu ra

    // Truyền dữ liệu âm thanh đầu vào qua I2S
    always @(posedge bclk) begin
        if (bit_count < 24) begin
            // Truyền dữ liệu MSB trước
            sdin <= audio_in[23 - bit_count];
            bit_count <= bit_count + 1;
        end else begin
            bit_count <= 0;
        end
    end

    // Nhận dữ liệu âm thanh từ I2S
    always @(negedge bclk) begin
        if (bit_count < 24) begin
            shift_reg_out <= {shift_reg_out[22:0], sdin_in}; // Nhận dữ liệu MSB trước
        end
    end

    // Cập nhật audio_out mỗi chu kỳ LRCLK
    always @(negedge lrclk) begin
        audio_out <= shift_reg_out;
    end

endmodule
