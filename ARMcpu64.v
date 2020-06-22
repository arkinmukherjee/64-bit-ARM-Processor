`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2020 05:24:38 PM
// Design Name: 
// Module Name: ARMcpu64
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ARMcpu64(ibus, clk, reset, daddrbus, databus, iaddrbus);
    input [31:0] ibus;
    input clk, reset;
    output [63:0] daddrbus, iaddrbus;
    inout [63:0] databus;
    
    wire [63:0] iaddrbusIn;
       
    PC pc(
        .iaddrbusIn(iaddrbusIn), 
        .iaddrbus(iaddrbus), 
        .reset(reset), 
        .clk(clk)
    );
    
    wire [63:0] add1, iaddrbusFromIFID, four;
    
    assign four = 64'h0000000000000004;
    
    adder64 a1(
        .a(iaddrbus),
        .b(four),
        .d(add1)
    );
           
    dff64 iaddrbusForIFID(
        .D(iaddrbus),
        .clk(clk),
        .Q(iaddrbusFromIFID)
    );

    
    wire [31:0] Aselect, Bselect, Dselect, DselFromIFID;
    wire ImmFromIFID, CinFromIFID, LoadFromIFID, StoreFromIFID, BranchFromIFID, CBFromIFID, CbzFromIFID, IMFromIFID, FLAGSFromIFID;
    wire [3:0] SFromIFID;
    wire [2:0] BFromIFID;
    wire [5:0] shamtFromIFID, MOVshiftFromIFID;
    wire [63:0] signExtFromIFID;
        
    // controller instantiation completing IFID
    controller c(
        .ibus(ibus), 
        .clk(clk), 
        .Aselect(Aselect), 
        .Bselect(Bselect), 
        .DselFromIFID(DselFromIFID), 
        .ImmFromIFID(ImmFromIFID), 
        .SFromIFID(SFromIFID), 
        .CinFromIFID(CinFromIFID), 
        .LoadFromIFID(LoadFromIFID), 
        .StoreFromIFID(StoreFromIFID), 
        .BranchFromIFID(BranchFromIFID), 
        .CBFromIFID(CBFromIFID), 
        .BFromIFID(BFromIFID), 
        .CbzFromIFID(CbzFromIFID), 
        .IMFromIFID(IMFromIFID), 
        .FLAGSFromIFID(FLAGSFromIFID), 
        .shamtFromIFID(shamtFromIFID), 
        .signExtFromIFID(signExtFromIFID),
        .MOVshiftFromIFID(MOVshiftFromIFID)
    );
       
    wire [63:0] regFileOutputAFromIFID, regFileOutputBFromIFID, dbus;
    
    // register file instantiation
    regfile reg32(
        .Aselect(Aselect),
        .Bselect(Bselect),
        .Dselect(Dselect),
        .clk(clk),
        .abus(regFileOutputAFromIFID),
        .bbus(regFileOutputBFromIFID),
        .dbus(dbus)
    );
    

    wire [31:0] DselFromIDEX;
    wire [63:0] regFileOutputAFromIDEX, regFileOutputBFromIDEX;
    wire ImmFromIDEX, CinFromIDEX, LoadFromIDEX, StoreFromIDEX, BranchFromIDEX, CBFromIDEX, CbzFromIDEX, IMFromIDEX, FLAGSFromIDEX;
    wire [3:0] SFromIDEX;
    wire [2:0] BFromIDEX;
    wire [5:0] shamtFromIDEX, MOVshiftFromIDEX;
    wire [63:0] signExtFromIDEX;
    
    // large D flip flop
    IDEX idex(
        .clk(clk),
        .regFileOutputAFromIFID(regFileOutputAFromIFID),
        .regFileOutputBFromIFID(regFileOutputBFromIFID),
        .DselFromIFID(DselFromIFID),
        .ImmFromIFID(ImmFromIFID), 
        .SFromIFID(SFromIFID), 
        .CinFromIFID(CinFromIFID), 
        .LoadFromIFID(LoadFromIFID), 
        .StoreFromIFID(StoreFromIFID), 
        .BranchFromIFID(BranchFromIFID), 
        .CBFromIFID(CBFromIFID), 
        .BFromIFID(BFromIFID), 
        .CbzFromIFID(CbzFromIFID), 
        .IMFromIFID(IMFromIFID), 
        .FLAGSFromIFID(FLAGSFromIFID), 
        .shamtFromIFID(shamtFromIFID), 
        .signExtFromIFID(signExtFromIFID),
        .MOVshiftFromIFID(MOVshiftFromIFID),
        .regFileOutputAFromIDEX(regFileOutputAFromIDEX),
        .regFileOutputBFromIDEX(regFileOutputBFromIDEX),
        .DselFromIDEX(DselFromIDEX),
        .ImmFromIDEX(ImmFromIDEX), 
        .SFromIDEX(SFromIDEX), 
        .CinFromIDEX(CinFromIDEX), 
        .LoadFromIDEX(LoadFromIDEX), 
        .StoreFromIDEX(StoreFromIDEX), 
        .BranchFromIDEX(BranchFromIDEX), 
        .CBFromIDEX(CBFromIDEX), 
        .BFromIDEX(BFromIDEX), 
        .CbzFromIDEX(CbzFromIDEX), 
        .IMFromIDEX(IMFromIDEX), 
        .FLAGSFromIDEX(FLAGSFromIDEX), 
        .shamtFromIDEX(shamtFromIDEX), 
        .signExtFromIDEX(signExtFromIDEX),
        .MOVshiftFromIDEX(MOVshiftFromIDEX)
    );
    
    wire [63:0] abus, bbus;
    
    // mux for abus depending on IM
    mux64 ALUAinput(
        .D0(regFileOutputAFromIDEX),
        .D1(signExtFromIDEX),
        .S(IMFromIDEX),
        .Y(abus)
    );
    
    wire ALUBinputSel;
    assign ALUBinputSel = ImmFromIDEX | LoadFromIDEX | StoreFromIDEX;
    // mux for bbus depending on Imm, Load, or Store
    mux64 ALUBinput(
        .D0(regFileOutputBFromIDEX),
        .D1(signExtFromIDEX),
        .S(ALUBinputSel),
        .Y(bbus)
    );
       
    wire [63:0] ALUoutputD;
    wire Cout, V, Z, N;
    
    wire [5:0] shift;
    
    // ALU instantiation
    alu64 alu(
        .d(ALUoutputD),
        .Cout(Cout),
        .V(V),
        .a(abus),
        .b(bbus),
        .Cin(CinFromIDEX),
        .S(SFromIDEX),
        .Z(Z),
        .N(N),
        .FLAGS(FLAGSFromIDEX)
    );
    
    // determines the shift amount based on IM instruction
    shiftMux shiftmux(
        .D0(shamtFromIDEX),
        .D1(MOVshiftFromIDEX),
        .S(IMFromIDEX),
        .Y(shift)
    );
    
    // calculates the shifted value
    reg [63:0] shiftedValue;
    always @ (abus, SFromIDEX, shift) begin
        if (SFromIDEX == 4'b1000)
            shiftedValue = abus << shift;
        else if (SFromIDEX == 4'b1001)
            shiftedValue = abus >> shift;
    end
    
    // checks if it is a shift operation
    wire isShift;
    assign isShift =  ( (SFromIDEX == 4'b1000) || (SFromIDEX == 4'b1001) );
    
    // selects daddrbus value based on if it is a shift instruction
    wire [63:0] daddrbusFromIDEX;
    mux64 shiftValMux(
        .D0(ALUoutputD),
        .D1(shiftedValue),
        .S(isShift),
        .Y(daddrbusFromIDEX)
    );
    
    wire [63:0] add2;
    
    adder64 a2(
        .a(signExtFromIFID),
        .b(iaddrbusFromIFID),
        .d(add2)
    );
    
    wire isZero;
    assign isZero = (regFileOutputBFromIFID == 32'h00000000);
    
    wire XnorOut;
    assign XnorOut = ~(isZero ^ CbzFromIFID);
    
    reg AndOut = 0;
    always @ (CBFromIFID, XnorOut) begin 
        AndOut = CBFromIFID & XnorOut;
    end
    
    wire branchDecoderOut;
    branchDecoder BD(
        .N(N),
        .V(V),
        .Z(Z),
        .B(BFromIFID),
        .bdOut(branchDecoderOut)
    );
    
    reg branchMuxSel = 0;
    always @ (AndOut, branchDecoderOut) begin 
        branchMuxSel = AndOut | branchDecoderOut;
    end

    // chooses iaddrbusIn based on branch
    mux64 branchMux(
        .D0(add1),
        .D1(add2),
        .S(branchMuxSel),
        .Y(iaddrbusIn)
    );
    
    wire [31:0] DselFromEXMEM;
    wire [63:0] regFileOutputBFromEXMEM;
    wire LoadFromEXMEM, StoreFromEXMEM, BranchFromEXMEM;
    
    // large D flip flop for EX/MEM stage
    EXMEM exmem(
        .clk(clk),
        .ALUoutputD(daddrbusFromIDEX),
        .DselFromIDEX(DselFromIDEX),
        .regFileOutputBFromIDEX(regFileOutputBFromIDEX),
        .LoadFromIDEX(LoadFromIDEX),
        .StoreFromIDEX(StoreFromIDEX),
        .BranchFromIDEX(BranchFromIDEX),
        .daddrbus(daddrbus),
        .DselFromEXMEM(DselFromEXMEM),
        .regFileOutputBFromEXMEM(regFileOutputBFromEXMEM),
        .LoadFromEXMEM(LoadFromEXMEM),
        .StoreFromEXMEM(StoreFromEXMEM),
        .BranchFromEXMEM(BranchFromEXMEM)
    );
    
    wire [31:0] DselFromStoreMux, zeroReg;
    assign zeroReg = 32'h00000001;
    
    wire StoreOrBranch;
    assign StoreOrBranch = StoreFromEXMEM | BranchFromEXMEM;
    
    // for store, set value to R0 so nothing is written to a register
    mux32 muxStoreOrBranch(
        .D0(DselFromEXMEM),
        .D1(zeroReg),
        .S(StoreOrBranch),
        .Y(DselFromStoreMux)
    );
    
    wire [63:0] databusFromEXMEM;
    assign databusFromEXMEM = { { 32{regFileOutputBFromEXMEM[31]}}, regFileOutputBFromEXMEM };
    
    tristatebuf64 tsbStore(
        .sel(StoreFromEXMEM),
        .Q(databusFromEXMEM),
        .bus(databus)
    );
    
    wire [31:0] DselInputForMEMWB;
    wire [63:0] daddrbusInputForMEMWB, databusInputForMEMWB;
    wire LoadInputForMEMWB;
    
    // used to buffer the EX/MEM pipeline register outputs before using them as inputs to the MEM/WB pipeline register
    assign daddrbusInputForMEMWB = daddrbus;
    assign DselInputForMEMWB = DselFromStoreMux;
    assign databusInputForMEMWB = databus;
    assign LoadInputForMEMWB = LoadFromEXMEM;
    
    wire [63:0] daddrbusFromMEMWB, databusFromMEMWB;
    wire LoadFromMEMWB;
    
    // large D flip flop for MEM/WB stage
    MEMWB memwb(
        .clk(clk),
        .daddrbusInputForMEMWB(daddrbusInputForMEMWB),
        .DselInputForMEMWB(DselInputForMEMWB),
        .databusInputForMEMWB(databusInputForMEMWB),
        .LoadInputForMEMWB(LoadInputForMEMWB),
        .daddrbusFromMEMWB(daddrbusFromMEMWB),
        .Dselect(Dselect),
        .databusFromMEMWB(databusFromMEMWB),
        .LoadFromMEMWB(LoadFromMEMWB)
    );
    
    // chooses dbus
    mux64 muxLoad(
        .D0(daddrbusFromMEMWB),
        .D1(databusFromMEMWB),
        .S(LoadFromMEMWB),
        .Y(dbus)
    );
    
endmodule
