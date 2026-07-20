`timescale 1ns/1ps

module spi_master (
    input clk,
    input rst,
    output sclk,
    output cs,
    input miso,
    output mosi
);

    reg tx_busy;
    reg done;

endmodule