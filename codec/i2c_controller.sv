module i2c_controller (
    input  logic       clk,        // Clock đầu vào
    input  logic       rst_n,      // Reset (active low)
    input  logic       start,      // Tín hiệu bắt đầu giao tiếp I2C
    input  logic [6:0] dev_addr,   // Địa chỉ thiết bị (7-bit)
    input  logic [7:0] reg_addr,   // Địa chỉ thanh ghi cần ghi
    input  logic [7:0] data,       // Dữ liệu cần ghi vào thanh ghi
    output logic       busy,       // Báo trạng thái bận
    output logic       ack_error,  // Báo lỗi ACK
    inout  logic       sda,        // Đường dữ liệu I2C
    output logic       scl         // Đường clock I2C
);

  // **Trạng thái FSM của I2C**
  typedef enum logic [2:0] {
    IDLE,
    START,
    SEND_DEV_ADDR,
    SEND_REG_ADDR,
    SEND_DATA,
    STOP
  } state_t;

  state_t state, next_state;

  // **Các tín hiệu nội bộ**
  logic [7:0] shift_reg;  // Thanh ghi dịch để gửi dữ liệu
  logic [2:0] bit_cnt;  // Bộ đếm bit (8 bit mỗi lần truyền)
  logic       sda_dir;  // Định hướng cho SDA (input/output)

  // **Trạng thái bận và lỗi ACK**
  assign busy = (state != IDLE);
  assign ack_error = (state == SEND_DEV_ADDR && sda == 1'b1 && bit_cnt == 3'd7);

  // **SCL Clock Divider**: Tạo tín hiệu SCL (thấp hơn tần số clock hệ thống)
  logic scl_enable;
  reg [7:0] clk_div;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) clk_div <= 0;
    else clk_div <= clk_div + 1;
  end

  assign scl = clk_div[7];  // SCL có tần số bằng 1/256 của clock đầu vào

  // **FSM để điều khiển giao tiếp I2C**
    if (!rst_n) begin
      state   <= IDLE;
      bit_cnt <= 3'd0;
      sda_dir <= 1'b1;  // Ban đầu, SDA ở chế độ output
    end else begin
      state <= next_state;
      if (state == SEND_DEV_ADDR || state == SEND_REG_ADDR || state == SEND_DATA)
        bit_cnt <= bit_cnt + 1;  // Đếm số bit đã truyền
      else bit_cnt <= 3'd0;  // Reset bộ đếm bit
    end
  end

  // **Chuyển trạng thái FSM**
  always_comb begin
    next_state = state;  // Mặc định giữ nguyên trạng thái
    case (state)
      IDLE: begin
        if (start) next_state = START;
      end
      START: begin
        next_state = SEND_DEV_ADDR;
      end
      SEND_DEV_ADDR: begin
        if (bit_cnt == 3'd7) next_state = SEND_REG_ADDR;
      end
      SEND_REG_ADDR: begin
        if (bit_cnt == 3'd7) next_state = SEND_DATA;
      end
      SEND_DATA: begin
        if (bit_cnt == 3'd7) next_state = STOP;
      end
      STOP: begin
        next_state = IDLE;
      end
    endcase
  end

  // **Quản lý tín hiệu SDA**
  assign sda = (sda_dir) ? shift_reg[7] : 1'bz;  // Chế độ output hoặc high-Z
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= 8'd0;
    end else begin
      case (state)
        START: begin
          sda_dir   <= 1'b1;  // Output
          shift_reg <= {dev_addr, 1'b0};  // Device Address + Write bit
        end
        SEND_DEV_ADDR: begin
          if (clk_div[7]) shift_reg <= {shift_reg[6:0], 1'b0};  // Dịch bit
        end
        SEND_REG_ADDR: begin
          if (clk_div[7]) shift_reg <= {reg_addr[6:0], 1'b0};  // Dịch thanh ghi
        end
        SEND_DATA: begin
          if (clk_div[7]) shift_reg <= {data[6:0], 1'b0};  // Dịch dữ liệu
        end
        STOP: begin
          sda_dir <= 1'b0;  // Input
        end
        default: shift_reg <= 8'd0;
      endcase
    end
  end

endmodule
