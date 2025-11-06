/*=============================================================

  UartRXi   A UART receiver

            Data loads on any clock, forcing the output to 1.
            Data is shifted out on shift strobe, introducing
            1's at the top.  The transmitter operates 
            continuously -- after shifting out the data, 1's
            are shifted out.

            Busy is not implemented, so make sure to leave
            ample time for the bits to shift out.

Note: during load, the output immediately reflects the flops;
it was necessary to add an additional 1 flop to make sure
that output stays at 1 for the remainder of the shift cycle.
Then, the 0 start bit will go out.
*/

module uart_rx(
    input   clk,                  // 
    input   [13:0] timebase,
    input   rxin,
    output  reg [7:0] dout,
    input   read, 
    output  reg ready=0 
);


   // Registers
reg [13:0] rx_bit_cnt = 0;
reg [9:0]  rx_shift_reg=10'b11_1111_1111;
reg        rxin1;
reg        rxin2;
wire       rx_busy;                      

reg [7:0] temp;                          // data held here
// Assignments
assign rx_busy = rx_shift_reg != 10'b1111111111;

   // UART Receiver
always @ (posedge clk) begin                 // input
  rxin1 <= rxin;
  rxin2 <= rxin1; 

  dout <= read ? temp : 8'b00000000;

  if (read) 
    ready <= 1'b0;

  if (!rx_shift_reg[0]) begin             // low bit == 0?
    temp <= rx_shift_reg[9:2];            // received data
    rx_shift_reg <= 10'b1111111111;       // reset shift reg
    ready <= 1'b1;                        // signal
  end 
  else if (rx_busy) begin                 // in progress?
    if (rx_bit_cnt == 0) begin            // baud clock rang?
         rx_bit_cnt <= timebase;
         rx_shift_reg <= {rxin2, rx_shift_reg[9:1]}; // >>1
    end 
    else rx_bit_cnt <= rx_bit_cnt - 1;       // keep the clock
  end 
  else if (!rxin1 && rxin2) begin           // free, and 1 then 0
    rx_shift_reg <= 10'b0111111111;       // start receiver
    rx_bit_cnt <= {1'b0,timebase[13:1]};           // 1/2 clock for this 0
  end
end
endmodule

