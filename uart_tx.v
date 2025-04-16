
module uart_tx(
    input clk,
    input rst,
    input [7:0] data_in,
    input valid,
    output reg tx
);

    parameter CLK_FREQ = 12000000;
    parameter BAUD_RATE = 9600;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [3:0] bit_index;
    reg [13:0] clk_count;
    reg [9:0] tx_shift_reg;
    reg tx_active;
    reg [1:0] state;
    reg [7:0] digits[0:3];
    reg [1:0] digit_index;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bit_index <= 0;
            clk_count <= 0;
            tx_shift_reg <= 10'b1111111111;
            tx <= 1;
            tx_active <= 0;
            state <= 0;
            digit_index <= 0;
        end else begin
            case (state)
                0: begin // Wait for valid input
                    if (valid && !tx_active) begin
                        // Convert temperature to ASCII digits
                        digits[0] <= (data_in / 100) + 8'd48; // hundreds
                        digits[1] <= ((data_in % 100) / 10) + 8'd48; // tens
                        digits[2] <= (data_in % 10) + 8'd48; // ones
                        digits[3] <= 8'd10; // '\n' newline

                        digit_index <= 0;
                        state <= 1;
                    end
                end
                1: begin // Load digit into shift register
                    if (!tx_active) begin
                        tx_shift_reg <= {1'b1, digits[digit_index], 1'b0}; // stop, data, start
                        tx_active <= 1;
                        bit_index <= 0;
                        clk_count <= 0;
                        state <= 2;
                    end
                end
                2: begin // Transmit each bit
                    if (tx_active) begin
                        if (clk_count == CLKS_PER_BIT - 1) begin
                            clk_count <= 0;
                            tx <= tx_shift_reg[bit_index];
                            bit_index <= bit_index + 1;
                            if (bit_index == 9) begin
                                tx_active <= 0;
                                tx <= 1;
                                if (digit_index == 3)
                                    state <= 0;
                                else begin
                                    digit_index <= digit_index + 1;
                                    state <= 1;
                                end
                            end
                        end else begin
                            clk_count <= clk_count + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule
