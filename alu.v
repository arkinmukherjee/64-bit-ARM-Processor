`timescale 1ns / 1ps

// top level module for 64-bit ALU
module alu64 (d, Cout, V, a, b, Cin, S, Z, N, FLAGS);
    output [63:0] d;
    output Cout, V, Z, N;
    input [63:0] a, b;
    input Cin, FLAGS;
    input [3:0] S;
   
    wire [63:0] c, g, p, dFromALUcell;
    wire gout, pout;
    
    alu_cell alucell[63:0] (
        .d(d),
        .g(g),
        .p(p),
        .a(a),
        .b(b),
        .c(c),
        .S(S)
    );
   
    lac6 laclevel6(
        .c(c),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(g),
        .p(p)
    );
    
    // sets flags when FLAGS is true. Default value is 0.
    assign Cout = (gout | (pout & Cin)) & FLAGS;
    assign V = (Cout ^ c[63]) & FLAGS;
    assign Z = (d == 64'h0000000000000000) & FLAGS;
    assign N = d[63] & FLAGS;

endmodule

// performs ALU calculations
module alu_cell (d, g, p, a, b, c, S);
    output d, g, p;
    input a, b, c;
    input [3:0] S;
    reg g, p, d, cint, bint;
    
    always @(a, b, c, S, p, g) begin 
        bint = S[0] ^ b;
        g = a & bint;
        p = a ^ bint;
        cint = S[1] & c;
    
        //default when S[2] = 0
        d = p ^ cint;
        
        //overwrites d when S[2] or S[3] = 1
        case (S)
            4'b0100: 
                d = a | b;
            4'b0101:
                d = ~(a | b);
            4'b0110:
                d = a & b;
            4'b0111:
                d = 0;
        endcase
    end
endmodule

// Look Ahead Carry chain to decrease delay to log N
module lac(c, gout, pout, Cin, g, p);

    output [1:0] c;
    output gout;
    output pout;
    input Cin;
    input [1:0] g;
    input [1:0] p;
    
    assign c[0] = Cin;
    assign c[1] = g[0] | ( p[0] & Cin );
    assign gout = g[1] | ( p[1] & g[0] );
    assign pout = p[1] & p[0];
	
endmodule

module lac2 (c, gout, pout, Cin, g, p);
    output [3:0] c;
    output gout, pout;
    input Cin;
    input [3:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac leaf0(
        .c(c[1:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[1:0]),
        .p(p[1:0])
    );
    
    lac leaf1(
        .c(c[3:2]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[3:2]),
        .p(p[3:2])
    );
   
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule   

module lac3 (c, gout, pout, Cin, g, p);
    output [7:0] c;
    output gout, pout;
    input Cin;
    input [7:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac2 leaf0(
        .c(c[3:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[3:0]),
        .p(p[3:0])
    );
    
    lac2 leaf1(
        .c(c[7:4]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[7:4]),
        .p(p[7:4])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac4 (c, gout, pout, Cin, g, p);
    output [15:0] c;
    output gout, pout;
    input Cin;
    input [15:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac3 leaf0(
        .c(c[7:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[7:0]),
        .p(p[7:0])
    );
    
    lac3 leaf1(
        .c(c[15:8]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[15:8]),
        .p(p[15:8])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac5 (c, gout, pout, Cin, g, p);
    output [31:0] c;
    output gout, pout;
    input Cin;
    input [31:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac4 leaf0(
        .c(c[15:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[15:0]),
        .p(p[15:0])
    );
    
    lac4 leaf1(
        .c(c[31:16]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[31:16]),
        .p(p[31:16])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule

module lac6 (c, gout, pout, Cin, g, p);
    output [63:0] c;
    output gout, pout;
    input Cin;
    input [63:0] g, p;
    
    wire [1:0] cint, gint, pint;
    
    lac5 leaf0(
        .c(c[31:0]),
        .gout(gint[0]),
        .pout(pint[0]),
        .Cin(cint[0]),
        .g(g[31:0]),
        .p(p[31:0])
    );
    
    lac5 leaf1(
        .c(c[63:32]),
        .gout(gint[1]),
        .pout(pint[1]),
        .Cin(cint[1]),
        .g(g[63:32]),
        .p(p[63:32])
    );
    
    lac root(
        .c(cint),
        .gout(gout),
        .pout(pout),
        .Cin(Cin),
        .g(gint),
        .p(pint)
    );
endmodule