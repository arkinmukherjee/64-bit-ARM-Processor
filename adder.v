`timescale 1ns / 1ps

module adder64(a, b, d);
    input [63:0] a, b;
    output [63:0] d;
    
    assign d = a + b;
endmodule