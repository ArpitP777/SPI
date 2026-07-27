`timescale 1ns/1ps

module clk_divide (
    input clk,
    input rst,
    output reg sclk
);

    initial sclk = 1'b0;

    reg [5:0] cnt = 0;
    
    always@(posedge clk) begin
        if(cnt == 50) begin
            sclk <= ~sclk;
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end
endmodule