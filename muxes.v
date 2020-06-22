`timescale 1ns / 1ps

// 64-bit 2x1 multiplexer
module mux64 (D0, D1, S, Y);
    output reg [63:0] Y;
    input [63:0] D0, D1;
    input S;
    
    always @ (D0, D1, S) begin
        if (S)
            Y = D1;
        else
            Y = D0;
    end
endmodule

// 32-bit 2x1 multiplexer
module mux32 (D0, D1, S, Y);
    output reg [31:0] Y;
    input [31:0] D0, D1;
    input S;
    
    always @ (D0, D1, S) begin
        if (S)
            Y = D1;
        else
            Y = D0;
    end
endmodule

// 6-bit 2x1 multiplexer for shift amount
module shiftMux (D0, D1, S, Y);
    output reg [5:0] Y;
    input [5:0] D0, D1;
    input S;
    
    always @ (D0, D1, S) begin
        if (S)
            Y = D1;
        else
            Y = D0;
    end
endmodule