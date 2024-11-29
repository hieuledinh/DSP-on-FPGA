module i2c_controller (
    input  logic        clk,            // System clock
    input  logic        reset,          // System reset
    output logic        i2c_scl,        // I2C clock line
    inout  logic        i2c_sda,        // I2C data line
    output logic        config_done     // Indicates configuration is complete
);

    typedef enum logic [1:0] {
        IDLE,
        START,
        WRITE,
        STOP
    } state_t;

    state_t current_state, next_state;

    logic [7:0] reg_data [0:7];  // Configuration data to send
    logic [3:0] reg_index;       // Register index
    logic [2:0] bit_counter;     // Bit counter for I2C

    // I2C clock divider
    logic [15:0] clk_divider;
    logic scl_enable;

    // Initialize configuration data (example for WM8731 setup)
    initial begin
        reg_data[0] = 8'h1A; // Register 0x0A: Reset
        reg_data[1] = 8'h0F; // Power down control
        reg_data[2] = 8'h42; // Left headphone out
        reg_data[3] = 8'h42; // Right headphone out
        reg_data[4] = 8'h10; // Analog audio path control
        reg_data[5] = 8'h00; // Digital audio path control
        reg_data[6] = 8'h10; // Sample rate control
        reg_data[7] = 8'h0C; // Activate digital interface
    end

    // I2C SCL Clock Generation
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider <= 0;
            scl_enable <= 0;
        end else begin
            clk_divider <= clk_divider + 1;
            scl_enable <= (clk_divider == 0);
        end
    end

    assign i2c_scl = scl_enable ? 1'b0 : 1'b1;

    // I2C State Machine
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            reg_index <= 0;
            bit_counter <= 0;
            config_done <= 0;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: if (reg_index < 8) next_state = START;
            START: next_state = WRITE;
            WRITE: if (bit_counter == 7) next_state = STOP;
            STOP: if (reg_index < 8) next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // I2C Write Logic
    always_ff @(posedge clk) begin
        if (current_state == WRITE) begin
            i2c_sda <= reg_data[reg_index][7 - bit_counter];
            bit_counter <= bit_counter + 1;
        end else if (current_state == STOP) begin
            bit_counter <= 0;
            reg_index <= reg_index + 1;
        end else if (current_state == IDLE && reg_index == 8) begin
            config_done <= 1; // Configuration complete
        end
    end

endmodule
