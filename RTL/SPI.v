`timescale 1ns/1ps

module spi_master (
    input clk,
    input rst,
    output sclk,
    output reg cs,
    input miso,
    output reg mosi,
    input [7:0] data_tx,
    output [7:0] data_rx,
    input start,
    output reg tx_busy,
    output reg done
);

    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [2:0] bit_c;

endmodule