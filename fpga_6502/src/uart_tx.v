
module uart_tx(
    input   clk,
    input   [13:0] timebase,
    output  txout,
    input   [7:0] din, 
    input   load,
    output  ready
);

reg [13:0] cnt;
reg [10:0] shifter=11'b000_0000_0001;

assign ready = (shifter == 11'b000_0000_0001);
assign txout = shifter[0];
always @ (posedge clk) begin
  if (~ready)
    if (cnt == 0) begin
      shifter <= {1'b0 , shifter[10:1]};
      cnt <= timebase;
      end 
    else 
      cnt <= cnt - 1;
  else 
    if (load) begin
      shifter <= {2'b11, din[7:0], 1'b0};
      cnt <= timebase ;
    end
end


endmodule


