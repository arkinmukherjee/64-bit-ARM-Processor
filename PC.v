`timescale 1ns / 1ps

// module to track the Program Counter
module PC(iaddrbusIn, iaddrbus, reset, clk);
    
    input [63:0] iaddrbusIn;
    input reset, clk;
    output reg [63:0] iaddrbus = 'h0000000000000000;
    
    always @ (posedge clk) begin
        if (reset)
            iaddrbus = 64'h0000000000000000;
        else
            iaddrbus = iaddrbusIn;
    end
endmodule
