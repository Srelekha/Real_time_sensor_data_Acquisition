module dht11_reader(
    input clk,
    input rst,
    input dht_data,
    output reg [7:0] temperature,
    output reg data_valid
);

    reg [15:0] counter;
    reg [5:0] bit_index;
    reg [39:0] data_bits;
    reg [3:0] state;

    parameter IDLE = 0, START = 1, WAIT_RESP = 2, READ_BITS = 3, DONE = 4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            bit_index <= 0;
            data_bits <= 0;
            state <= IDLE;
            temperature <= 0;
            data_valid <= 0;
        end else begin
            case (state)
                IDLE: begin
                    counter <= counter + 1;
                    if (counter == 100000) begin
                        counter <= 0;
                        state <= START;
                    end
                end
                START: begin
                    counter <= counter + 1;
                    if (counter < 18000) begin
                    end else begin
                        counter <= 0;
                        state <= WAIT_RESP;
                    end
                end
                WAIT_RESP: begin
                    state <= READ_BITS;
                    bit_index <= 0;
                    data_bits <= 0;
                end
                READ_BITS: begin
                    counter <= counter + 1;
                    if (counter == 500) begin
                        data_bits <= {data_bits[38:0], dht_data};
                        bit_index <= bit_index + 1;
                        counter <= 0;
                        if (bit_index == 39) begin
                            state <= DONE;
                        end
                    end
                end
                DONE: begin
                    temperature <= data_bits[31:24];
                    data_valid <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule