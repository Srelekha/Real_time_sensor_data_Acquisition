`include "uart_tx.v"
`include "dht11_reader.v"

module top(
    input clk,
    input rst,
    input dht_data,
    output tx,
    output led_red,
    output led_green,
    output led_blue
);

    wire [7:0] temperature;
    wire data_valid;

    dht11_reader reader(
        .clk(clk),
        .rst(rst),
        .dht_data(dht_data),
        .temperature(temperature),
        .data_valid(data_valid)
    );

    uart_tx uart(
        .clk(clk),
        .rst(rst),
        .data_in(temperature),
        .valid(data_valid),
        .tx(tx)
    );

    assign led_red   = (temperature > 30);
    assign led_green = (temperature >= 20 && temperature <= 30);
    assign led_blue  = (temperature < 20);

endmodule