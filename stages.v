`timescale 1ns / 1ps

// D flip-flop for the ID/EX stage
module IDEX(clk, regFileOutputAFromIFID, regFileOutputBFromIFID, DselFromIFID, ImmFromIFID, SFromIFID, CinFromIFID, LoadFromIFID, StoreFromIFID, 
                BranchFromIFID, CBFromIFID, BFromIFID, CbzFromIFID, IMFromIFID, FLAGSFromIFID, shamtFromIFID, signExtFromIFID, MOVshiftFromIFID,
                regFileOutputAFromIDEX, regFileOutputBFromIDEX, DselFromIDEX, ImmFromIDEX, SFromIDEX, CinFromIDEX, LoadFromIDEX, StoreFromIDEX,
                BranchFromIDEX, CBFromIDEX, BFromIDEX, CbzFromIDEX, IMFromIDEX, FLAGSFromIDEX, shamtFromIDEX, signExtFromIDEX, MOVshiftFromIDEX
            );

    // inputs and outputs
    input clk;
    input [31:0] DselFromIFID;
    input [63:0] regFileOutputAFromIFID, regFileOutputBFromIFID;
    input ImmFromIFID, CinFromIFID, LoadFromIFID, StoreFromIFID, BranchFromIFID, CBFromIFID, CbzFromIFID, IMFromIFID, FLAGSFromIFID;
    input [3:0] SFromIFID;
    input [2:0] BFromIFID;
    input [5:0] shamtFromIFID, MOVshiftFromIFID;
    input [63:0] signExtFromIFID;
    
    output reg [31:0] DselFromIDEX;
    output reg [63:0] regFileOutputAFromIDEX, regFileOutputBFromIDEX;
    output reg ImmFromIDEX, CinFromIDEX, LoadFromIDEX, StoreFromIDEX, BranchFromIDEX, CBFromIDEX, CbzFromIDEX, IMFromIDEX, FLAGSFromIDEX;
    output reg [3:0] SFromIDEX;
    output reg [2:0] BFromIDEX;
    output reg [5:0] shamtFromIDEX, MOVshiftFromIDEX;
    output reg [63:0] signExtFromIDEX;
    
    // values are set at the positive edge of the clock
    always @ (posedge clk) begin
        regFileOutputAFromIDEX = regFileOutputAFromIFID;
        regFileOutputBFromIDEX = regFileOutputBFromIFID;
        DselFromIDEX = DselFromIFID;
        ImmFromIDEX = ImmFromIFID;
        CinFromIDEX = CinFromIFID;
        LoadFromIDEX = LoadFromIFID;
        StoreFromIDEX = StoreFromIFID;
        BranchFromIDEX = BranchFromIFID;
        CBFromIDEX = CBFromIFID;
        CbzFromIDEX = CbzFromIFID;
        IMFromIDEX = IMFromIFID;
        FLAGSFromIDEX = FLAGSFromIFID;
        SFromIDEX = SFromIFID;
        BFromIDEX = BFromIFID;
        shamtFromIDEX = shamtFromIFID;
        signExtFromIDEX = signExtFromIFID;
        MOVshiftFromIDEX = MOVshiftFromIFID;
    end

endmodule

// D flip-flop for the EX/MEM stage
module EXMEM(clk, ALUoutputD, DselFromIDEX, regFileOutputBFromIDEX, LoadFromIDEX, StoreFromIDEX, BranchFromIDEX, daddrbus, DselFromEXMEM,
        regFileOutputBFromEXMEM, LoadFromEXMEM, StoreFromEXMEM, BranchFromEXMEM);

    // inputs and outputs
    input clk, LoadFromIDEX, StoreFromIDEX, BranchFromIDEX;
    input [31:0] DselFromIDEX;
    input [63:0] ALUoutputD, regFileOutputBFromIDEX;
    output reg [31:0] DselFromEXMEM;
    output reg [63:0] daddrbus, regFileOutputBFromEXMEM;
    output reg LoadFromEXMEM, StoreFromEXMEM, BranchFromEXMEM;
    
    // values are set at the positive edge of the clock
    always @ (posedge clk) begin
        daddrbus = ALUoutputD;
        // daddrbus = ALUoutputD;
        DselFromEXMEM = DselFromIDEX;
        regFileOutputBFromEXMEM = regFileOutputBFromIDEX;
        LoadFromEXMEM = LoadFromIDEX;
        StoreFromEXMEM = StoreFromIDEX;
        BranchFromEXMEM = BranchFromIDEX;
    end

endmodule

// D flip-flop for the MEM/WB stage
module MEMWB(clk, daddrbusInputForMEMWB, DselInputForMEMWB, databusInputForMEMWB, LoadInputForMEMWB,
         daddrbusFromMEMWB, Dselect, databusFromMEMWB, LoadFromMEMWB);

    // inputs and outputs
    input clk, LoadInputForMEMWB;
    input [31:0] DselInputForMEMWB;
    input [63:0] daddrbusInputForMEMWB, databusInputForMEMWB;
    output reg [31:0] Dselect;
    output reg [63:0] daddrbusFromMEMWB, databusFromMEMWB;
    output reg LoadFromMEMWB;
    
    // values are set at the positive edge of the clock
    always @ (posedge clk) begin
        daddrbusFromMEMWB = daddrbusInputForMEMWB;
        Dselect = DselInputForMEMWB;
        databusFromMEMWB = databusInputForMEMWB;
        LoadFromMEMWB = LoadInputForMEMWB;
    end

endmodule