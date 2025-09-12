module fpga_6502(
    input wire clk,
    input wire btn1,
    output wire [5:0] led

);

    cpu cpu( clk, reset, AB, DI, DO, WE, IRQ, NMI, RDY );

    reg         reset;     // reset signal
    wire [15:0] AB;        // address bus
    wire  [7:0]  DI;        // data in, read bus
    wire [7:0]  DO;        // data out, write bus
    wire        WE;        // write enable
    reg         IRQ = 0;   // interrupt request
    reg         NMI = 0;   // non-maskable interrupt request
    reg         RDY = 1;   // Ready signal. Pauses CPU when RDY=0 
    reg [5:0]   led_reg;

    wire         rom_ce;
    reg          rom_oce;
    reg [7:0]   wDI = 8'hAA;
    wire [7:0]  rom_dout;
    reg [10:0]  reset_cntr=11'b0; 
    reg [15:0]  address;  

    rom rom(
        .dout(rom_dout),
        .clk(clk),
        .oce(rom_oce),
        .ce(rom_ce),
        .reset(reset),
        .ad(AB[10:0])
    );

    always @(posedge clk) begin
        if (reset_cntr < 11'h1) begin
            reset_cntr <= reset_cntr + 11'b1;
            reset <= 1'b0;
        end else if (reset_cntr < 11'h2) begin
            reset_cntr <= reset_cntr + 11'b1;
            reset <= 1'b1;
        end else begin  
            reset <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (WE && (AB == 16'h6000)) begin
            led_reg <= DO[5:0];
        end
    end 

    always @(posedge clk) begin
        address <= AB;
        case (AB[15:8])
            8'h60: begin 
                rom_oce <= 1'b0;
                if (AB[0] == 1'b0) begin
                    wDI <= 8'b0; // output to leds
                end else begin
                    wDI <= {7'b0, btn1}; // input from button
                end
            end

            8'h80: begin
                rom_oce <= 1'b1;
            end

            8'hFF: begin
                rom_oce <= 1'b0;
                case (AB[7:0])
                    8'hFA: begin
                        wDI <= 8'h00; // open bus
                    end
                    8'hFB: begin
                        wDI <= 8'h80; // open bus
                    end
                    8'hFC: begin
                        wDI <= 8'h00; // open bus
                    end 
                    8'hFD: begin
                        wDI <= 8'h80; // open bus
                    end
                    8'hFE: begin
                        wDI <= 8'h00; // open bus
                    end
                    8'hFF: begin
                        wDI <= 8'h80; // open bus
                    end
                    default: begin
                        wDI <= 8'h00; // open bus
                    end
                endcase
            end

            default: begin
                rom_oce <= 1'b0;
                wDI <= 8'haa; // open bus
            end
        endcase
    end

    assign rom_ce = (AB[15:8] == 8'h80) ? 1'b1 : 1'b0; // $0000-$07FF 

    assign DI = rom_oce ? rom_dout : wDI;
    assign led = ~led_reg;

endmodule