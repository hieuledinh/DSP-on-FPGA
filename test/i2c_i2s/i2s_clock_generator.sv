module i2s_clock_generator (
    input clk,          // Clock chính 50MHz
    output reg bclk,    // Bit Clock (BCLK) ~2.304 MHz
    output reg lrclk    // Left/Right Clock (LRCLK) 48kHz
);

    reg [15:0] bclk_divider = 0;
    reg [15:0] lrclk_divider = 0;

    always @(posedge clk) begin
        // Tạo Bit Clock (2.304 MHz cho 24-bit, 48kHz stereo)
        bclk_divider <= bclk_divider + 1;
        if (bclk_divider == 16'd11) begin // Chia xung từ 50MHz xuống ~2.304 MHz
            bclk <= ~bclk;
            bclk_divider <= 0;
        end

        // Tạo Left/Right Clock (48kHz)
        lrclk_divider <= lrclk_divider + 1;
        if (lrclk_divider == 16'd1041) begin // Chia từ 50MHz xuống 48kHz
            lrclk <= ~lrclk;
            lrclk_divider <= 0;
        end
    end

endmodule
