module fpga_6502 (
    input clk,
    input btn1,
    output uartTx,
    output reg [5:0] led
);

localparam SYS_FREQ = 27000000;  // 27 MHz

// Reset must be high for at least 1 cycle.
reg reset = 1;
always @(posedge clk)
    reset <= (~btn1);

wire   [15:0] AB;
reg     [7:0] DI = 8'hEA;
wire    [7:0] DO;
reg           IRQ = 1'd0;
reg           NMI = 1'd0;
reg           RDY = 1'd1;     
wire          SYNC;
wire          WE;

cpu_65c02 cpu(
    .clk (clk),
    .reset (reset),
    .DI (DI),  
    .IRQ (IRQ), 
    .NMI (NMI),    
    .RDY (RDY),
    .AB (AB),  
    .DO (DO),   
    .SYNC (SYNC),  
    .WE (WE)
);

wire ram_select;
wire io_select;
wire rom_select;
wire uart_select;

assign ram_select = (AB[15:11] == 5'b0000_0); // 0x0000 - 0x07FF
assign io_select = (AB[15:11] == 5'b1100_0); // 0xC000 - 0xC7FF 
assign uart_select = (AB[15:11] == 5'b1010_0); // 0xA000 - 0xA7FF
assign rom_select = (AB[15:11] == 5'b11111);  // 0xF800 - 0xFFFF


reg [7:0]  rom_dout;
reg [7:0]  ram_dout;
reg [7:0]  uart_dout;
reg [15:0] addr_reg;

always @(posedge clk) begin
    addr_reg <= AB;
end

always @(*)
    DI = (addr_reg[15:11] == 5'b11111) ? rom_dout : 
//         (addr_reg == 16'hA000) ? 8'b0000_0000 :
         (addr_reg == 16'hA000) ? uart_dout :
         (addr_reg == 16'hA001) ? uart_status :
         ram_dout;

ram ram (
    .clk(clk),
    .ad(AB[10:0]),
    .dout(ram_dout),
    .oce(1'b1), 
    .ce(ram_select),
    .we(WE),
    .din(DO)
);

rom rom(
    .clk(clk),
    .ad(AB[10:0]),
    .dout(rom_dout),
    .oce(1'b1),
    .ce(rom_select)
);

reg [13:0]uart_timebase = SYS_FREQ/115200 -1;

wire txready;
uart_tx utx(
  .clk      (clk),
  .timebase (uart_timebase),
  .txout    (uartTx),
  .din      (DO),
  .load     (uart_select & WE),
  .ready    (txready)
);      

wire rxready;
wire uart_rx = 1'b1; // TODO: connect to actual RX pin
wire [7:0] uart_rxdata;
uart_rx urx(
  .clk      (clk),
  .timebase (uart_timebase),
  .rxin     (uart_rx),
  .dout     (uart_rxdata),
  .read     (uart_select & ~WE & AB[0]),
  .ready    (rxready)
);

reg [7:0] uart_status;

always @(posedge clk) begin
    if(io_select & WE)
        led[5:0] <= ~DO[5:0];
end

always @(posedge clk) begin
    uart_status <= (uart_select & ~WE & AB[0]) ?
      {1'b0, rxready, 4'b0, txready, 1'b0} :
      0 ;
    uart_dout <= (uart_select & ~WE & ~AB[0]) ?
      uart_rxdata :
      0 ; 
end
    
endmodule
