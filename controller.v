`timescale 1ns / 1ps

// top level module for the controller that handles the Instruction Decode stage
module controller(ibus, clk, Aselect, Bselect, DselFromIFID, ImmFromIFID, SFromIFID, CinFromIFID, LoadFromIFID, StoreFromIFID, 
                  BranchFromIFID, CBFromIFID, BFromIFID, CbzFromIFID, IMFromIFID, FLAGSFromIFID, shamtFromIFID, signExtFromIFID, MOVshiftFromIFID);
    
    // inputs and outputs
    input [31:0] ibus;
    input clk;
    output [31:0] Aselect, Bselect, DselFromIFID;
    output ImmFromIFID, CinFromIFID, LoadFromIFID, StoreFromIFID, BranchFromIFID, CBFromIFID, CbzFromIFID, IMFromIFID, FLAGSFromIFID;
    output [3:0] SFromIFID;
    output [2:0] BFromIFID;
    output [5:0] shamtFromIFID, MOVshiftFromIFID;
    output[63:0] signExtFromIFID;
    
    
    wire [31:0] instruction;
    
    dff32 IFID(
        .D(ibus),
        .clk(clk),
        .Q(instruction)
    );
    
    // R instructions
    wire [10:0] opcodeRD = instruction[31:21]; // for R and D
    wire [4:0] Rm = instruction[20:16];
    assign shamtFromIFID = instruction[15:10];
    wire [4:0] Rn = instruction[9:5]; // for R, I, and D
    wire [4:0] Rd = instruction[4:0]; // for R, I, and IM
    
    // I instructions
    wire [9:0] opcodeI = instruction[31:22];
    wire [11:0] ALUImm = instruction[21:10];
    
    // D instructions
    wire [8:0] DTaddr = instruction[20:12];
    wire [1:0] op = instruction[11:10];
    wire [4:0] Rt = instruction[4:0]; // for D and CB
    
    // B6 instructions
    wire [5:0] opcodeB6 = instruction[31:26];
    wire [25:0] B6addr = instruction[25:0];
       
    // CB instructions
    wire [7:0] opcodeCB = instruction[31:24];
    wire [18:0] CBaddr = instruction[23:5];
    
    // IM instructions
    wire [8:0] opcodeIM = instruction[31:23];
    wire [1:0] mov = instruction[22:21];
    assign MOVshiftFromIFID = mov << 4;
    wire [15:0] MOVImm = instruction[20:5];
       
    // sets values from opcode decoder
    opcodeDecoder od(
        .opcodeRD(opcodeRD), 
        .opcodeI(opcodeI), 
        .opcodeB6(opcodeB6),
        .opcodeCB(opcodeCB), 
        .opcodeIM(opcodeIM), 
        .Imm(ImmFromIFID), 
        .S(SFromIFID), 
        .Cin(CinFromIFID), 
        .Load(LoadFromIFID), 
        .Store(StoreFromIFID), 
        .Branch(BranchFromIFID), 
        .CB(CBFromIFID), 
        .B(BFromIFID), 
        .Cbz(CbzFromIFID), 
        .IM(IMFromIFID), 
        .FLAGS(FLAGSFromIFID)
    );
    
    
    // sets Aselect value
    registerDecoder RnValue(
        .registerNum(Rn),
        .select(Aselect)
    );
    
    wire [31:0] RtVal, RmVal;
    
    // sets RmVal value
    registerDecoder Rmvalue(
        .registerNum(Rm),
        .select(RmVal)
    );
    
    // sets RtVal value
    registerDecoder Rtvalue(
        .registerNum(Rt),
        .select(RtVal)
    );
    
    wire BselectMuxSel;
    assign BselectMuxSel = CBFromIFID | StoreFromIFID;
    
    // takes RtVal if instruction type is CB
    mux32 BselectMux(
        .D0(RmVal),
        .D1(RtVal),
        .S(BselectMuxSel),
        .Y(Bselect)
    );
    
    wire [31:0] rdDecoderToImmMux;
    
    // sets value from Rd decoder
    registerDecoder Rdvalue(
        .registerNum(Rd),
        .select(DselFromIFID)
    );
   
    // extends the constant or address to 32 bits for I format
    signExtension se(
        .Imm(ImmFromIFID), 
        .Load(LoadFromIFID), 
        .Store(StoreFromIFID), 
        .B(BFromIFID), 
        .CB(CBFromIFID), 
        .IM(IMFromIFID), 
        .ALUImm(ALUImm), 
        .DTaddr(DTaddr), 
        .B6addr(B6addr), 
        .CBaddr(CBaddr), 
        .MOVImm(MOVImm), 
        .signExt(signExtFromIFID)
    );
       
endmodule

// decodes the opcode to generate flags used in future stages
module opcodeDecoder (opcodeRD, opcodeI, opcodeB6, opcodeCB, opcodeIM, Imm, S, Cin, Load, Store, Branch, CB, B, Cbz, IM, FLAGS);
    
    // inputs and outputs
    input [10:0] opcodeRD;
    input [9:0] opcodeI;
    input [5:0] opcodeB6;
    input [7:0] opcodeCB;
    input [8:0] opcodeIM;
 
    output reg Imm, Cin, Load, Store, Branch, CB, Cbz, IM, FLAGS;
    output reg [2:0] B; // used for determining type of branch instruction
    output reg [3:0] S; // used for determining type of ALU operation
    
    always @ (opcodeRD, opcodeI, opcodeB6, opcodeCB, opcodeIM) begin
    
        // default values
        Imm = 0;
        S = 4'bzzzz;
        Cin = 0;
        Load = 0;
        Store = 0;
        Branch = 0;
        CB = 0;
        B = 3'b111;
        Cbz = 0;
        IM = 0;
        FLAGS = 0;
        
        // R format
        if (opcodeRD == 11'b10001011000) begin // ADD
            S = 4'b0010;
        end else if (opcodeRD == 11'b10101011000) begin // ADDS
            S = 4'b0010;
            FLAGS = 1;
        end else if (opcodeRD == 11'b11001011000) begin // SUB
            S = 4'b0011;
            Cin = 1;
        end else if (opcodeRD == 11'b11101011000) begin // SUBS
            S = 4'b0011;
            Cin = 1;
            FLAGS = 1;
        end else if (opcodeRD == 11'b11001010000) begin // EOR
            S = 4'b0000;
        end else if (opcodeRD == 11'b10001010000) begin // AND
            S = 4'b0110;
        end else if (opcodeRD == 11'b11101010000) begin // ANDS
            S = 4'b0110;
            FLAGS = 1;
        end else if (opcodeRD == 11'b10101010000) begin // ORR
            S = 4'b0100;
        end else if (opcodeRD == 11'b11010011011) begin // LSL
            S = 4'b1000;
            Load = 1;
        end else if (opcodeRD == 11'b11010011010) begin // LSR
            S = 4'b1001;
        end
        
        // D format
        if (opcodeRD == 11'b11111000010) begin // LDUR
            S = 4'b0010;
            Load = 1;
        end else if (opcodeRD == 11'b11111000000) begin // STUR
            S = 4'b0010;
            Store = 1;
        end
        
        // I format
        if (opcodeI == 10'b1001000100) begin // ADDI
            Imm = 1;
            S = 4'b0010;
        end else if (opcodeI == 10'b1011000100) begin // ADDIS
            Imm = 1;
            S = 4'b0010;
            FLAGS = 1;
        end else if (opcodeI == 10'b1101000100) begin // SUBI
            Imm = 1;
            S = 4'b0011;
            Cin = 1;
        end else if (opcodeI == 10'b1111000100) begin // SUBIS
            Imm = 1;
            S = 4'b0011;
            Cin = 1;
            FLAGS = 1;
        end else if (opcodeI == 10'b1101001000) begin // EORI
            Imm = 1;
            S = 4'b0000;
        end else if (opcodeI == 10'b1001001000) begin // ANDI
            Imm = 1;
            S = 4'b0110;
        end else if (opcodeI == 10'b1111001000) begin // ANDIS
            Imm = 1;
            S = 4'b0110;
            FLAGS = 1;
        end else if (opcodeI == 10'b1011001000) begin // ORRI
            Imm = 1;
            S = 4'b0100;
        end
        
        // B6 format
        if (opcodeB6 == 6'b000101) begin // B
            Branch = 1;
            S = 4'b0010;
            B = 3'b000;
        end
               
        // CB format
        if (opcodeCB == 8'b10110100) begin // CBZ
            CB = 1;
            Cbz = 1;
            Branch = 1;
            S = 4'b0010;
        end else if (opcodeCB == 8'b10110101) begin // CBNZ
            CB = 1;
            Cbz = 0;
            Branch = 1;
            S = 4'b0010;
        end else if (opcodeCB == 8'b01010101) begin // BEQ
            CB = 1;
            Branch = 1;
            S = 4'b0010;
            B = 3'b001;
        end else if (opcodeCB == 8'b01010110) begin // BNE
            CB = 1;
            Branch = 1;
            S = 4'b0010;
            B = 3'b010;
        end else if (opcodeCB == 8'b01010111) begin // BLT
            CB = 1;
            Branch = 1;
            S = 4'b0010;
            B = 3'b011;
        end else if (opcodeCB == 8'b01011000) begin // BGE
            CB = 1;
            Branch = 1;
            S = 4'b0010;
            B = 3'b100;
        end
        
        // IM format
        if (opcodeIM == 9'b110100101) begin // MOVZ
            IM = 1;
            S = 4'b1000; // shift left
        end
  
    end
endmodule

// determines the select value from rs, rt, or rd value
module registerDecoder(registerNum, select);
    
    // inputs and outputs
    input [4:0] registerNum;
    output [31:0] select;
    
    assign select = 32'h00000001 << registerNum;

endmodule

// extends the constant or address to 64 bits to their appropriate format
module signExtension(Imm, Load, Store, B, CB, IM, ALUImm, DTaddr, B6addr, CBaddr, MOVImm, signExt);
    input Imm, Load, Store, CB, IM;
    input [2:0] B;
    input [11:0] ALUImm;
    input [8:0] DTaddr;
    input [25:0] B6addr;
    input [18:0] CBaddr;
    input [15:0] MOVImm;
    
    output reg [63:0] signExt;
    
    always @ (Imm, Load, Store, B, CB, IM, ALUImm, DTaddr, B6addr, CBaddr, MOVImm) begin
        if (Imm) // I type
            signExt[63:0] = { 52'b0, ALUImm };
        else if (Load || Store) // D type
            signExt[63:0] = { { 55{DTaddr[8]}}, DTaddr };
        else if (B == 3'b000) // B6 type
            signExt[63:0] = { { 36{B6addr[25]}}, B6addr, 2'b0 };
        else if (CB) // CB type
            signExt[63:0] = { { 43{CBaddr[18]}}, CBaddr, 2'b0 };
        else if (IM) // IM type
            signExt[63:0] = { 48'b0, MOVImm };
    end

endmodule