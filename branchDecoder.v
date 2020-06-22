`timescale 1ns / 1ps

// module to find the value to set RD to for set instructions
module branchDecoder(N, V, Z, B, bdOut);

    input N, V, Z;
    input [2:0] B;
    output reg bdOut;

    always @ (N, V, Z, B) begin
        // default value
        bdOut = 0;
        
        if (B == 3'b000) // B
            bdOut = 1;
        else if (B == 3'b001) begin // BEQ
            if (Z == 1)
                bdOut = 1;
        end else if (B == 3'b010) begin // BNE
            if (Z == 0)
                bdOut = 1;
        end else if (B == 3'b011) begin // BLT
            if (N != V)
                bdOut = 1;
        end else if (B == 3'b100) begin // BGE
            if (N == V)
                bdOut = 1;
        end
    end

endmodule