`define SIM 1
`include "fpga_6502.v"
`include "cpu.v"
`include "mALU.v"
`include "rom.v"

module test();

  fpga_6502 fpga_6502( clk, btn1, led);
  reg clk=0;
  reg btn1=0;
  wire [5:0] led;

  always
    #1  clk = ~clk;

  initial begin
    #500 $finish;
  end

  initial begin
    $dumpfile("6502_test.vcd");
    $dumpvars(0, test);
  end
endmodule