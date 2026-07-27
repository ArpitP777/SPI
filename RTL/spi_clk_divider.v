`timescale 1ns/1ps

module spi_clk_divider (
    input clk,
    input rst,
    output reg sclk,
    output reg spi_tick
);

    reg [5:0] cnt = 0;
    
    always@(posedge clk) begin
        if(rst) begin
            sclk <= 1'b0;
            cnt <= 6'd0;
        end
        else begin
            if(cnt == 6'd24) begin
                sclk <= ~sclk;
                spi_tick <= 1'b1;
                cnt <= 6'd0;
            end
            else begin
                cnt <= cnt + 1'b1;
                spi_tick <= 1'b0;
            end
        end
    end
endmodule