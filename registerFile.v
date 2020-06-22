`timescale 1ns / 1ps

// module for the 64-bit register file with 32 registers
module regfile(Aselect, Bselect, Dselect, dbus, clk, abus, bbus);
    
    // inputs and outputs
    input [31:0] Aselect, Bselect, Dselect;
    input [63:0] dbus;
    input clk;
    output [63:0] abus, bbus;
    
    wire [2047:0] Q;
    
    // set R31 to 0
    assign Q[2047:1984] = 0;
    
    negdff32 dff [30:0](
        .D(dbus),
        .clk(clk),
        .Q(Q[1983:0]),
        .Dsel(Dselect[30:0])
    );
    
    tristatebuf32 tsbA [31:0](
        .sel(Aselect),
        .Q(Q),
        .bus(abus)
    );
    
    tristatebuf32 tsbB [31:0] (
        .sel(Bselect),
        .Q(Q),
        .bus(bbus)
    );
endmodule
