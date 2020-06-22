`timescale 1ns / 1ps

// module for 64-bit tri-state buffer
module tristatebuf64(sel, Q, bus);
    // inputs and outputs
    input [63:0] Q;
    input sel;
    output[63:0] bus;
    
    assign bus = sel ? Q : 64'bz;
endmodule

// module for 32-bit tri-state buffer
module tristatebuf32(sel, Q, bus);
    // inputs and outputs
    input [63:0] Q;
    input sel;
    output[63:0] bus;
    
    assign bus = sel ? Q : 64'bz;
endmodule