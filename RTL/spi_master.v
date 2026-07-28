module spi_master (
    input clk,
    input rst,
    output reg cs,
    input miso,
    output reg mosi,
    input [7:0] data_tx,
    output reg [7:0] data_rx,
    input start,
    output reg tx_busy,
    output reg done
);

    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [2:0] bit_c;
    reg [1:0] ps,ns;
    wire sclk;
    wire spi_tick;

    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam TRANSFER = 2'b10;
    localparam DONE = 2'b11;

    spi_clk_divider inst(.clk(clk), .rst(rst), .sclk(sclk), .spi_tick(spi_tick));

    always@(posedge clk) begin
        if(rst) begin
            ps <= IDLE;
        end
        else begin
            ps <= ns;
            if(ps == LOAD) begin
                bit_c <= 3'd0;
                tx_shift_reg <= data_tx;
                rx_shift_reg <= 8'd0;
                mosi <= data_tx[7];
            end
            else if(ps == TRANSFER && spi_tick) begin
                /////////// posedge sclk
                if(sclk) begin
                    rx_shift_reg <= {rx_shift_reg[6:0], miso};
                    if(bit_c == 3'd7) begin
                        bit_c <= 3'd7;
                    end
                    else begin
                        bit_c <= bit_c + 1;
                    end
                end
                /////////// nededge sclk
                else begin
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    mosi <= tx_shift_reg[6];
                end
            end
            else if(ps == DONE) begin
                data_rx <= rx_shift_reg;
            end
        end
    end

    always@(*) begin
        ns = ps;
        ns = ps;
        tx_busy = 1'b0;
        cs = 1'b1;
        done = 1'b0;

        if(rst) begin
            ns = IDLE; 
        end
        case(ps)
            IDLE: if(start) begin
                ns = LOAD;
            end
            else begin
                tx_busy = 1'b0;
                cs = 1'b1;
                done = 1'b0;
            end
            LOAD: begin
                // data_tx <= tx_shift_reg;
                tx_busy = 1'b1;
                cs = 1'b0;
                // bit_c <= 3'd0;
                // rx_shift_reg <= 8'd0;
                ns = TRANSFER;
            end
            TRANSFER: begin 
                tx_busy = 1'b1;
                cs = 1'b0;
                if(spi_tick && sclk && bit_c == 3'd7) begin
                    ns = DONE;
                end
            end
            DONE: begin
                cs = 1'b1;
                tx_busy = 1'b0;
                done = 1'b1;
                ns = IDLE;
            end
            default: begin
                ns = IDLE;
                tx_busy = 1'b0;
                cs = 1'b1;
            end
        endcase
    end

endmodule