`define SIM 1
`include "rom.v"

module test();

    reg         rom_ce =  1'b0;
    reg         rom_oce = 1'b0;
    reg [10:0]  AB = 11'b0;
    reg [7:0]   wDI;
    wire [7:0]  rom_dout;
    reg         clk=0;
    reg         reset=0;

    rom rom(
        .dout(rom_dout),
        .clk(clk),
        .oce(rom_oce),
        .ce(rom_ce),
        .reset(reset),
        .ad(AB[10:0])
    );

  always
    #1  clk = ~clk;

  initial begin
    #3 reset = 1;
    #3 reset = 0;
  end

  initial begin
    rom_ce = 1'b0;
    rom_oce = 1'b0;
    #10 AB = 11'h000;
    #1 rom_ce = 1'b1;
    rom_oce = 1'b1;
    #2 AB = 11'h001;
    #2 AB = 11'h002;
    #2 AB = 11'h003;
    #2 AB = 11'h004;
    #2 AB = 11'h005;
  end

  initial begin
    #500 $finish;
  end

  initial begin
    $dumpfile("romtest.vcd");
    $dumpvars(0, test);
  end
endmodule