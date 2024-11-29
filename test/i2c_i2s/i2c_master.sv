module i2c_master (
    input clk,             // Clock chính (50MHz từ DE10-Standard)
    input reset,           // Nút reset
    input [6:0] device_addr, // Địa chỉ I2C của thiết bị
    input [7:0] reg_addr,  // Địa chỉ thanh ghi trong thiết bị
    input [15:0] data,     // Dữ liệu ghi vào thanh ghi
    output reg scl,        // Clock I2C
    inout sda,             // Đường dữ liệu I2C
    output reg done        // Cờ báo hoàn tất
);

    reg [3:0] state;
    reg [7:0] bit_count;
    reg sda_out;
    assign sda = (sda_out) ? 1'bz : 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            scl <= 1;
            sda_out <= 1;
            bit_count <= 0;
            done <= 0;
        end else begin
            case (state)
                0: begin
                    // Bắt đầu giao tiếp (Start condition)
                    sda_out <= 0;
                    scl <= 1;
                    state <= 1;
                end
                1: begin
                    // Gửi địa chỉ thiết bị
                    if (bit_count < 7) begin
                        sda_out <= device_addr[6 - bit_count];
                        scl <= ~scl; // Xung clock
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 0;
                        state <= 2;
                    end
                end
                2: begin
                    // Gửi bit R/W (0: ghi)
                    sda_out <= 0;
                    scl <= ~scl;
                    state <= 3;
                end
                3: begin
                    // Gửi địa chỉ thanh ghi
                    if (bit_count < 8) begin
                        sda_out <= reg_addr[7 - bit_count];
                        scl <= ~scl;
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 0;
                        state <= 4;
                    end
                end
                4: begin
                    // Gửi dữ liệu (MSB trước)
                    if (bit_count < 16) begin
                        sda_out <= data[15 - bit_count];
                        scl <= ~scl;
                        bit_count <= bit_count + 1;
                    end else begin
                        state <= 5;
                    end
                end
                5: begin
                    // Kết thúc giao tiếp (Stop condition)
                    sda_out <= 1;
                    scl <= 1;
                    done <= 1;
                end
            endcase
        end
    end

endmodule
