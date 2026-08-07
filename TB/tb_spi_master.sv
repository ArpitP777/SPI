`timescale 1ns / 1ps

module spi_master_tb;
  localparam CLK_PERIOD = 10;
  localparam NUM_TESTS = 5;

  logic clk;
  logic rst;
  logic cs;
  logic miso;
  logic mosi;
  logic [7:0] data_tx;
  logic [7:0] data_rx;
  logic start;
  logic tx_busy;
  logic done;

  spi_master dut (
    .clk(clk),
    .rst(rst),
    .cs(cs),
    .miso(miso),
    .mosi(mosi),
    .data_tx(data_tx),
    .data_rx(data_rx),
    .start(start),
    .tx_busy(tx_busy),
    .done(done)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  initial begin
    rst = 1;
    data_tx = 8'h00;
    miso = 0;
    start = 0;
    #50 rst = 0;
    #20;

    test_single_transfer();
    #2000;

    test_back_to_back();
    #3000;

    test_with_miso_loopback();
    #2000;

    test_all_zeros();
    #2000;

    test_all_ones();
    #2000;

    $finish;
  end

  task test_single_transfer();
    data_tx = 8'hAA;
    start = 1;
    #CLK_PERIOD;
    start = 0;

    wait(done == 1);
    #100;
  endtask

  task test_back_to_back();
    logic [7:0] test_data[2:0];
    test_data[0] = 8'h55;
    test_data[1] = 8'hFF;
    test_data[2] = 8'h00;

    for (int i = 0; i < 3; i++) begin
      data_tx = test_data[i];
      start = 1;
      #CLK_PERIOD;
      start = 0;
      wait(done == 1);
      #CLK_PERIOD;
    end
  endtask

  task test_with_miso_loopback();
    logic miso_bit;
    data_tx = 8'hB4;
    start = 1;
    #CLK_PERIOD;
    start = 0;

    fork
      begin
        wait(mosi == 1);
        #2000 miso = mosi;
      end
      begin
        wait(done == 1);
      end
    join

    #100;
  endtask

  task test_all_zeros();
    data_tx = 8'h00;
    start = 1;
    #CLK_PERIOD;
    start = 0;

    wait(done == 1);
    #100;
  endtask

  task test_all_ones();
    data_tx = 8'hFF;
    start = 1;
    #CLK_PERIOD;
    start = 0;

    wait(done == 1);
    #100;
  endtask

  initial begin
    $dumpfile("spi_master_tb.vcd");
    $dumpvars(0, spi_master_tb);
  end

endmodule