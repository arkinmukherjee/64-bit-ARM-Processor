`timescale 1ns / 1ps

// module for 64-bit D flip-flop
module dff64 (D, clk, Q);

    // inputs and outputs
    input [63:0] D;
    input clk;
    output reg [63:0] Q;
    
    initial begin
        Q = 0;
    end
    // Q is set to D at the positive edge of the clock
    always @ (posedge clk) begin
        Q = D;
    end
endmodule

// module for 32-bit D flip-flop
module dff32 (D, clk, Q);

    // inputs and outputs
    input [31:0] D;
    input clk;
    output reg [31:0] Q;
    
    initial begin
        Q = 0;
    end
    // Q is set to D at the positive edge of the clock
    always @ (posedge clk) begin
        Q = D;
    end
endmodule

// module for 32-bit D flip-flop triggered on negative edge
module negdff32 (D, clk, Q, Dsel);

    // inputs and outputs
    input [63:0] D;
    input clk, Dsel;
    output reg [63:0] Q;
    
    // Q is set to D at the negative edge of the clock
    always @ (negedge clk) begin
        if (Dsel == 1'b1)
            Q = D;
    end
endmodule
