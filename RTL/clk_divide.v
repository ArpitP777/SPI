`timescale 1ns/1ps

module clk_divide (
    input clk,
    input rst,
    output reg sclk
);

    initial sclk = 1'b0;
    
    reg [5:0] cnt1 = 0;
    reg [5:0] cnt2 = 0;
    
    always@(posedge clk) begin
        if(cnt2 - cnt1 == 50) begin
            sclk <= ~sclk;
            cnt2 <= 0;
        end
        else begin
            cnt2 <= cnt2 + 1;
        end
    end
endmodule