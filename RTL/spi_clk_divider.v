`timescale 1ns/1ps

module clk_divide (
    input clk,
    input rst,
    output reg sclk
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
                cnt <= 6'd0;
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
    end
endmodule