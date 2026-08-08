# SPI Master for FPGA

An 8-bit, MSB-first Serial Peripheral Interface (SPI) master written in Verilog for FPGA projects, with a clock-divider module and a SystemVerilog testbench for functional simulation.

## Overview

This project implements the controller side of a simple SPI link. The `spi_master` module accepts one byte to transmit, drives MOSI and the active-low chip-select signal, and captures one byte from MISO during the same transaction. A small finite-state machine controls the transfer from the initial `start` request through completion.

The design is a useful starting point for connecting an FPGA to SPI peripherals such as sensors, ADCs, DACs, displays, or external memory devices.

## Features

- 8-bit full-duplex SPI transfers
- MSB-first transmission
- Active-low chip select (`cs`)
- SPI-style timing with SCLK idle low, MISO sampled on rising edges, and MOSI advanced on falling edges
- `tx_busy` status signal while a transfer is in progress
- One-cycle `done` indication when received data is ready
- Clock divider that derives SCLK timing from the FPGA system clock
- Self-contained SystemVerilog testbench with multiple transfer scenarios

## Repository Structure

```text
.
|-- RTL/
|   |-- spi_clk_divider.v   # Generates SCLK timing and transfer ticks
|   `-- spi_master.v        # SPI master controller and shift registers
|-- TB/
|   `-- tb_spi_master.sv    # SystemVerilog simulation testbench
|-- SIM/
|   |-- schem_spi.png       # SPI connection diagram
|   `-- image.png           # Simulation reference image
`-- LICENSE                 # MIT License
```

## SPI Interface

| Signal | Direction | Description |
| --- | --- | --- |
| `clk` | Input | FPGA system clock |
| `rst` | Input | Active-high synchronous reset |
| `start` | Input | Requests a new transfer when the controller is idle |
| `data_tx[7:0]` | Input | Byte transmitted on MOSI |
| `data_rx[7:0]` | Output | Byte received from MISO after the transaction completes |
| `cs` | Output | Active-low chip-select signal |
| `mosi` | Output | Master Out, Slave In serial-data line |
| `miso` | Input | Master In, Slave Out serial-data line |
| `tx_busy` | Output | High while a transfer is active |
| `done` | Output | High for one clock cycle after a completed transfer |

## Operation

1. Drive `data_tx` with the byte to send.
2. Pulse `start` while `tx_busy` is low.
3. The controller asserts `cs` low, loads the transmit shift register, and presents bit 7 on MOSI.
4. Across eight clock periods, it samples MISO on rising SCLK edges and shifts the next MOSI bit out on falling edges.
5. When the frame is complete, `cs` returns high, `done` pulses, and `data_rx` contains the received byte.

The clock divider toggles SCLK every 25 input clock cycles, so the generated SCLK frequency is `clk / 50` with the current divider setting. Change the terminal-count value in `RTL/spi_clk_divider.v` to adapt the serial-clock rate to the target board and peripheral.

## Timing and Mode

The current implementation uses an idle-low clock. Data is sampled from MISO on rising SCLK edges and MOSI changes on falling SCLK edges, which corresponds to the common SPI mode 0 timing convention.

Confirm the clock polarity, phase, maximum SCLK frequency, chip-select timing, and bit order required by the target peripheral before using this module in hardware.

## Simulation

The testbench in `TB/tb_spi_master.sv` generates a 100 MHz system clock and exercises the following cases:

- A single transfer of `8'hAA`
- Three back-to-back transfers (`8'h55`, `8'hFF`, and `8'h00`)
- A MISO loopback scenario
- All-zero and all-one transmit values

### Run with Icarus Verilog

From the repository root:

```bash
iverilog -g2012 -o spi_master_tb.vvp RTL/spi_clk_divider.v RTL/spi_master.v TB/tb_spi_master.sv
vvp spi_master_tb.vvp
```

The testbench writes `spi_master_tb.vcd`. If GTKWave is installed, inspect the captured waveforms with:

```bash
gtkwave spi_master_tb.vcd
```

## Example Integration

```verilog
spi_master spi_master_inst (
    .clk     (clk),
    .rst     (rst),
    .cs      (spi_cs_n),
    .miso    (spi_miso),
    .mosi    (spi_mosi),
    .data_tx (tx_byte),
    .data_rx (rx_byte),
    .start   (start_transfer),
    .tx_busy (transfer_busy),
    .done    (transfer_done)
);
```

Only assert `start_transfer` when `transfer_busy` is low. Keep `tx_byte` stable when beginning a transaction, then use `rx_byte` when `transfer_done` is asserted.

## Current Limitation

`spi_master` uses the SCLK signal produced by `spi_clk_divider` internally, but it does not currently expose SCLK as a module output. Before connecting the design to an external SPI slave, add an SCLK output to `spi_master` and route the internally generated `sclk` signal to that port.

## Hardware Notes

- Add the appropriate pin constraints for `cs`, `mosi`, and `miso` in the FPGA project's constraints file. Add an SCLK constraint after exposing the clock signal as an output.
- Match the FPGA I/O voltage standard to the connected peripheral.
- Use a clock rate within the peripheral's supported range.
- This version handles one 8-bit transaction at a time. Multi-byte commands, configurable word lengths, alternate SPI modes, and multiple chip-select outputs can be added as extensions.

## License

This project is available under the [MIT License](LICENSE).
