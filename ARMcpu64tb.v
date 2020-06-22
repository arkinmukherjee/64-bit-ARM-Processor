`timescale 1ns/10ps

module ARMcpu64tb();

parameter num = 99;
reg  [31:0] instrbus;
reg  [31:0] instrbusin[0:num];
wire [63:0] iaddrbus, daddrbus;
reg  [63:0] iaddrbusout[0:num], daddrbusout[0:num];
wire [63:0] databus;
reg  [63:0] databusk, databusin[0:num], databusout[0:num];
reg         clk, reset;
reg         clkd;

reg [63:0] dontcare;
reg [24*8:1] iname[0:num];
integer error, k, ntests;

	parameter BRANCH	= 6'b000101;
	parameter BEQ		= 8'b01010101;
	parameter BNE		= 8'b01010110;
	parameter BLT		= 8'b01010111;
	parameter BGE		= 8'b01011000;
	parameter CBZ		= 8'b10110100;
	parameter CBNZ		= 8'b10110101;
	parameter ADD		= 11'b10001011000;
	parameter ADDS		= 11'b10101011000;
	parameter SUB		= 11'b11001011000;
	parameter SUBS		= 11'b11101011000;
	parameter AND		= 11'b10001010000;
	parameter ANDS		= 11'b11101010000;
	parameter EOR		= 11'b11001010000;
	parameter ORR		= 11'b10101010000;
	parameter LSL		= 11'b11010011011;
	parameter LSR		= 11'b11010011010;
	parameter ADDI  	= 10'b1001000100;
	parameter ADDIS		= 10'b1011000100;
	parameter SUBI		= 10'b1101000100;
	parameter SUBIS		= 10'b1111000100;
	parameter ANDI		= 10'b1001001000;
	parameter ANDIS		= 10'b1111001000;
	parameter EORI		= 10'b1101001000;
	parameter ORRI		= 10'b1011001000;
	parameter MOVZ		= 9'b110100101;
	parameter STUR		= 11'b11111000000;
	parameter LDUR		= 11'b11111000010;
	
	
ARMcpu64 dut(.reset(reset),.clk(clk),.iaddrbus(iaddrbus),.ibus(instrbus),.daddrbus(daddrbus),.databus(databus));

initial begin
// This test file runs the following program.

iname[0]  = "ADDI R30, R31, #1";
iname[1]  = "SUBI R29, R31, #5";
iname[2]  = "EORI R28, R31, #10";
iname[3]  = "LDUR R27, [R30,0]";
iname[4]  = "LDUR R26, [R29,0]";
iname[5]  = "STUR R30, [R28,50]";
iname[6]  = "STUR R29, [R28,5]";
iname[7]  = "ADD  R25, R27, R28";
iname[8]  = "SUBIS R24, R29, 1010";
iname[9]  = "ORR  R23, R30, R29";
iname[10] = "ADDIS R22, R29, #2";     
iname[11] = "EOR  R28, R24, R31";     
iname[12] = "ADDIS R21, R24, 6510";
iname[13] = "STUR R29, [R24, 76]";
iname[14] = "ORRI R20, R24, 2222";
iname[15] = "EORI  R19, R26, 45";
iname[16] = "STUR R26, [R26,0]";
iname[17] = "STUR R27, [R29,0]";
iname[18] = "STUR R24, [R21,150]"; 
iname[19] = "STUR R19, [R29,15]";
iname[20] = "STUR R30, [R22,6]";
iname[21] = "ANDI R18,  R23, #1";
iname[22] = "SUBI R17,  R31, #1";
iname[23] = "SUBIS R16, R31, #1";
iname[24] = "BNE  #20";             // Branching to  //(32'h00000060 + (decimal 20 *4) ) since, R0 != R1.
iname[25] = "ADDI R31, R31, #100";    // Delay Slot   //Branched Location
iname[26] = "ADDI R15,  R31, #14";   
iname[27] = "ANDI  R14, R23, #13";
iname[28] = "SUBIS  R13, R22, #23";
iname[29] = "STUR R17, [R25,14]";   
iname[30] = "LDUR R12, [R20,0]";   
iname[31] = "AND R11, R23, R22";
iname[32] = "ANDS  R10,  R30, R30"; // Storing R30 into R10  
iname[33] = "ADDS  R9,  R15, R16";
iname[34] = "STUR R31, [R20,24]";
iname[35] = "MOVZ R31, (<< 2*16), #h1234 "; // Shifting left 32
iname[36] = "ADDI  R28,  R30, #5";
iname[37] = "ADDIS  R19,  R21, #3";
iname[38] = "EOR  R27, R29, R31";
iname[39] = "EORI R12, R16, #hBFFF";
iname[40] = "LSR  R26, R22, 6'd10";
iname[41] = "LSL  R30, R18, 6'd12";
iname[42] = "STUR R15, [R25,13]";
iname[43] = "MOVZ R25, (<< 1*16), #hABCD ";
iname[44] = "MOVZ R27, (<< 3*16), #h2345 ";
iname[45] = "CBZ  R21, #d12";       // not branching
iname[46] = "SUBI R25,  R31, #1";
iname[47] = "CBNZ R21, #d12";       // branching 
iname[48] = "ADDI R8, R29, #135";
iname[49] = "EORI R7, R15, #277";
iname[50] = "LDUR R25, [R26,0]";
iname[51] = "STUR R20, [R23,100]";
iname[52] = "LDUR R24, [R18,0]";
iname[53] = "ADD  R6, R10, R11";
iname[54] = "STUR R19, [R20,30]";
iname[55] = "SUBIS R17, R31, #0";
iname[56] = "BEQ  #24";             // branching
iname[57] = "ANDIS R5, R14, #753";     
iname[58] = "ORR  R28, R24, R31";  
iname[59] = "STUR R25, [R24,3]";   
iname[60] = "SUBIS R4, R17, 52";
iname[61] = "EOR R29, R24, R25";
iname[62] = "ORRI R3, R5, 1111";
iname[63] = "ORR  R2, R24, R25";
iname[64] = "LSR  R5, R22, 6'd6";
iname[65] = "LSL  R6, R13, 6'd15"; 
iname[66] = "STUR R23, [R13,0]";
iname[67] = "STUR R24, [R12,0]";
iname[68] = "ADDI R1,  R31, #1";    
iname[69] = "ADDI R0,  R31, #1";
iname[70] = "SUBIS R0, R31, #0";
iname[71] = "CBZ  #16";             // branching 
iname[72] = "SUBI R12, R10, #70";
iname[73] = "ADDI R11,  R11, #11";
iname[74] = "ANDI  R10, R9, #hBB";
iname[75] = "SUBS  R12, R22, R31";
iname[76] = "BNE  #8";              // branching  
iname[77] = "SUBS R9, R31, R1";
iname[78] = "BGE  #32";             // branching
iname[79] = "ANDS  R15,  R23, R23";    
iname[80] = "ADDS  R28,  R20, R31";
iname[81] = "SUBS R31,  R31, R1";
iname[82] = "BLT  #12";             // branching
iname[83] = "NOP  ADDI  R31,  R31, #0";
iname[84] = "NOP  ADDI  R31,  R31, #0";
iname[85] = "EOR  R5, R20, R21";
iname[86] = "EORI R6, R18, #hABC";
iname[87] = "LSR  R23, R20, 6'd16";
iname[88] = "LSL  R22, R21, 6'd18";
iname[89] = "B    #d64";
iname[90] = "MOVZ R23, (<< 0*16), #h3333 ";
iname[91] = "MOVZ R15, (<< 3*16), #h5555 ";
iname[92] = "CBZ  R31, #d16";       // branching
iname[93] = "ADDI R31,  R31, #0";
iname[94] = "CBNZ R31, #d16";       // not branching
iname[95] = "NOP  ADDI  R31,  R31, #0";
iname[96] = "NOP  ADDI  R31,  R31, #0";
iname[97] = "NOP  ADDI  R31,  R31, #0";
iname[98] = "NOP  ADDI  R31,  R31, #0";
iname[99] = "NOP  ADDI  R31,  R31, #0";

dontcare = 64'hx;

//* ADDI R30, R31, #1
iaddrbusout[0] = 64'h0000000000000000;
//            opcode 
instrbusin[0]={ADDI, 12'b000000000001, 5'b11111, 5'b11110};

daddrbusout[0] = 64'b0000000000000000000000000000000000000000000000000000000000000001; //dontcare;
databusin[0] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[0] = dontcare;

//* SUBI  R29, R31, #5
iaddrbusout[1] = 64'h0000000000000004;
//            opcode
instrbusin[1]={SUBI, 12'b000000000101, 5'b11111, 5'b11101};

daddrbusout[1] = 64'b1111111111111111111111111111111111111111111111111111111111111011; //dontcare;
databusin[1]   = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[1]  = dontcare;

//* EORI  R28, R31, #10
iaddrbusout[2] = 64'h0000000000000008;
//            opcode
instrbusin[2]={EORI, 12'b000000001010, 5'b11111, 5'b11100};

daddrbusout[2] = 64'b0000000000000000000000000000000000000000000000000000000000001010; //dontcare; 
databusin[2]   = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[2]  = dontcare;

//* LDUR  R27, [R30,0]
iaddrbusout[3] = 64'h000000000000000C;
//            opcode
instrbusin[3]={LDUR, 9'b000000000, 2'b00, 5'b11110, 5'b11011};

daddrbusout[3] = 64'h0000000000000001;
databusin[3]   = 64'hCCCCCCCCCCCCCCCC;
databusout[3]  = dontcare;

//* LDUR  R26, [R29,0]
iaddrbusout[4] = 64'h0000000000000010;
//            opcode
instrbusin[4]={LDUR, 9'b000000000, 2'b00, 5'b11101, 5'b11010};

daddrbusout[4] = 64'b1111111111111111111111111111111111111111111111111111111111111011;
databusin[4] = 64'hAAAAAAAAAAAAAAAA;
databusout[4] = dontcare;

//* STUR   R30, [R28,100] 
iaddrbusout[5] = 64'h0000000000000014;
//            opcode 
instrbusin[5]={STUR, 9'b000110010, 2'b01, 5'b11100, 5'b11110};

daddrbusout[5] = 64'b0000000000000000000000000000000000000000000000000000000000111100;
databusin[5] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[5] = 64'b0000000000000000000000000000000000000000000000000000000000000001;

//* STUR    R29, [R28,5]
iaddrbusout[6] = 64'h0000000000000018;
//            opcode 
instrbusin[6]={STUR, 9'd5, 2'b01, 5'd28, 5'd29};

daddrbusout[6] = 64'b0000000000000000000000000000000000000000000000000000000000001111;
databusin[6] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[6] = 64'b1111111111111111111111111111111111111111111111111111111111111011;

//* ADD   R25, R27, R28
iaddrbusout[7] = 64'h000000000000001C;
//             opcode   
instrbusin[7]={ADD, 5'd27, 6'd1, 5'd28, 5'd25};

daddrbusout[7] = 64'b1100110011001100110011001100110011001100110011001100110011010110; //dontcare;
databusin[7] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[7] = dontcare;

//* SUBIS  R24, R29, 1010
iaddrbusout[8] = 64'h0000000000000020;
//            opcode
instrbusin[8]={SUBIS, 12'd1010, 5'd29, 5'd24};

daddrbusout[8] = 64'b1111111111111111111111111111111111111111111111111111110000001001;
databusin[8] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[8] = dontcare;

//* ORR  R23, R30, R29
iaddrbusout[9] = 64'h0000000000000024;
//             opcode
instrbusin[9]={ORR, 5'd29, 6'd0, 5'd30, 5'd23};

daddrbusout[9] = 64'b1111111111111111111111111111111111111111111111111111111111111011;
databusin[9] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[9] = dontcare;

//* ADDIS R22, R29, 2           
iaddrbusout[10] = 64'h0000000000000028;
//             opcode 
instrbusin[10]={ADDIS, 12'd2, 5'd29, 5'd22};

daddrbusout[10] = 64'b1111111111111111111111111111111111111111111111111111111111111101;
databusin[10] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[10] = dontcare;

//* EOR  R28, R24, R31            
iaddrbusout[11] = 64'h000000000000002C;
//            opcode
instrbusin[11]={EOR, 5'd31, 6'd10, 5'd24, 5'd28};

daddrbusout[11] = 64'b1111111111111111111111111111111111111111111111111111110000001001;
databusin[11] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[11] = dontcare;

//* ADDIS R21, R24, 6510           
iaddrbusout[12] = 64'h0000000000000030;
//             opcode 
instrbusin[12]={ADDIS, 12'd6510, 5'd24, 5'd21};

daddrbusout[12] = 64'b0000000000000000000000000000000000000000000000000000010101110111;
databusin[12] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[12] = dontcare;

//* STUR  R29, [R24, 76]
iaddrbusout[13] = 64'h0000000000000034;
//            opcode 
instrbusin[13]={STUR, 9'd76, 2'b01, 5'd24, 5'd29};

daddrbusout[13] = 64'b1111111111111111111111111111111111111111111111111111110001010101;
databusin[13] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[13] = 64'b1111111111111111111111111111111111111111111111111111111111111011;

//* ORRI    R20, R24, 2222
iaddrbusout[14] = 64'h0000000000000038;
//            opcode
instrbusin[14]={ORRI, 12'd2222, 5'd24, 5'd20};

daddrbusout[14] = 64'b1111111111111111111111111111111111111111111111111111110010101111;
databusin[14] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[14] = dontcare;

//* EORI  R19, R26, 45
iaddrbusout[15] = 64'h000000000000003C;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[15]={EORI, 12'd45, 5'd26, 5'd19};

daddrbusout[15] = 64'b1010101010101010101010101010101010101010101010101010101010000111;
databusin[15] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[15] =  dontcare;

//  STUR   R26, [R26,0]
iaddrbusout[16] = 64'h0000000000000040;
//            opcode 
instrbusin[16]={STUR, 9'd0, 2'b01, 5'd26, 5'd26};

daddrbusout[16] = 64'b1010101010101010101010101010101010101010101010101010101010101010;
databusin[16] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[16]  = 64'b1010101010101010101010101010101010101010101010101010101010101010;

//  STUR   R27, [R29,0]
iaddrbusout[17] = 64'h0000000000000044;
//            opcode 
instrbusin[17]={STUR, 9'd0, 2'b10, 5'd29, 5'd27};

daddrbusout[17] = 64'b1111111111111111111111111111111111111111111111111111111111111011;
databusin[17] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[17] = 64'b1100110011001100110011001100110011001100110011001100110011001100;

//  STUR   R24, [R21,150]       
iaddrbusout[18] = 64'h0000000000000048;
//            opcode 
instrbusin[18]={STUR, 9'd150, 2'b10, 5'd21, 5'd24};

daddrbusout[18] = 64'b0000000000000000000000000000000000000000000000000000011000001101;
databusin[18] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[18]  = 64'b1111111111111111111111111111111111111111111111111111110000001001;

//  STUR   R19, [R29,15]
iaddrbusout[19] = 64'h000000000000004C;
//            opcode 
instrbusin[19]={STUR, 9'd15, 2'b10, 5'd29, 5'd19};

daddrbusout[19] = 64'b0000000000000000000000000000000000000000000000000000000000001010;
databusin[19] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[19] = 64'b1010101010101010101010101010101010101010101010101010101010000111;

//  STUR   R30, [R22,6]
iaddrbusout[20] = 64'h0000000000000050;
//            opcode 
instrbusin[20]={STUR, 9'd6, 2'b10, 5'd22, 5'd30};

daddrbusout[20] = 64'b0000000000000000000000000000000000000000000000000000000000000011;
databusin[20] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[20]  = 64'b0000000000000000000000000000000000000000000000000000000000000001;


//  ANDI  R18,  R23,  #1
iaddrbusout[21] = 64'h0000000000000054;
//             opcode  
instrbusin[21]={ANDI, 12'd1, 5'd23, 5'd18};

daddrbusout[21] = 64'h01;
databusin[21]   = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[21]  = dontcare;

//* SUBI R17,  R31, #1
iaddrbusout[22] = 64'h0000000000000058;
//            opcode 
instrbusin[22]={SUBI, 12'd1, 5'd31, 5'd17};

daddrbusout[22] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[22] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[22] = dontcare;

//* SUBIS R16, R31, #1
iaddrbusout[23] = 64'h000000000000005C;
//            opcode 
instrbusin[23]={SUBIS, 12'd1, 5'd31, 5'd16};

daddrbusout[23] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[23] =   64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[23] =  dontcare;

//* BNE #20
iaddrbusout[24] = 64'h0000000000000060;
//            opcode 
instrbusin[24]={BNE, 19'd20, 5'd0};

daddrbusout[24] = dontcare;
databusin[24] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[24] = dontcare;

//* ADDI R31,  R31, #100
iaddrbusout[25] = 64'h0000000000000064;
//            opcode
instrbusin[25]={ADDI, 12'd1, 5'd31, 5'd31};

daddrbusout[25] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[25] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[25] = dontcare;

//* ADDI  R15,  R31, #14
iaddrbusout[26] = 64'h00000000000000B0;
//             opcode
instrbusin[26]={ADDI, 12'd14, 5'd31, 5'd15};

daddrbusout[26] = 64'b0000000000000000000000000000000000000000000000000000000000001110;
databusin[26] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[26] = dontcare;

//* NOP  ANDI  R14,  R23, #13
iaddrbusout[27] = 64'h00000000000000B4;
//             opcode         
instrbusin[27]={ANDI, 12'd13, 5'd23, 5'd14};

daddrbusout[27] = 64'b0000000000000000000000000000000000000000000000000000000000001001;
databusin[27] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[27] = dontcare;

//* NOP  SUBIS  R13, R22, 23
iaddrbusout[28] = 64'h00000000000000B8;
//             opcode
instrbusin[28] = {SUBIS, 12'd23, 5'd22, 5'd13};

daddrbusout[28] = 64'b1111111111111111111111111111111111111111111111111111111111100110;
databusin[28]  = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[28] = dontcare;

//* STUR R17, [R25,14]
iaddrbusout[29] = 64'h00000000000000BC;
//            opcode
instrbusin[29]={STUR, 9'd14, 2'b10, 5'd25, 5'd17};

daddrbusout[29] = 64'b0000000000000000000000000000000000000000000000000000000011111000;
databusin[29] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[29] = 64'b0011001100110011001100110011001100110011001100110111110000000000;

//* LDUR R12, [R20,0]
iaddrbusout[30] = 64'h00000000000000C0;
//                 
instrbusin[30]={LDUR, 9'b000000000, 2'b00, 5'd20, 5'd12};

daddrbusout[30] = 64'b1111111111111111111111111111111111111111111111111111110010101111;
databusin[30] = 64'hAAAAAAAAAAAAAAAA;
databusout[30] = dontcare;

//* AND R11, R23, R22
iaddrbusout[31] = 64'h00000000000000C4;
//            opcode
instrbusin[31]={AND, 5'd22, 6'd1, 5'd22, 5'd11};

daddrbusout[31] = dontcare;
databusin[31] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[31] = dontcare;

//* ANDS  R10,  R30, R30
iaddrbusout[32] = 64'h00000000000000C8;
//            opcode 
instrbusin[32]={ANDS, 5'd30, 6'd0, 5'd30, 5'd10};

daddrbusout[32] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[32] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[32] = dontcare;

//* ADDS  R9,  R15, R16
iaddrbusout[33] = 64'h00000000000000CC;
//            opcode 
instrbusin[33]={ADDS, 5'd16, 6'd0, 5'd15, 5'd9};

daddrbusout[33] = 64'b0000000000000000000000000000000000000000000000000000000000001101;
databusin[33] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[33] = dontcare;

//* STUR R31, [R20,24]
iaddrbusout[34] = 64'h00000000000000D0;
//                 
instrbusin[34] = {STUR, 9'd24, 2'b10, 5'd20, 5'd31};

daddrbusout[34] = 64'b1111111111111111111111111111111111111111111111111111110011000111;
databusin[34] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[34] = 64'b0000000000000000000000000000000000000000000000000000000000000000;

//* MOVZ R31, (<< 2*16), #h1234 
iaddrbusout[35] = 64'h00000000000000D4;
//            opcode
instrbusin[35]={MOVZ, 2'b10, 16'h1234, 5'd31};

daddrbusout[35] = dontcare;
databusin[35] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[35] = dontcare;

//* ADDI  R28,  R30, #5
iaddrbusout[36] = 64'h00000000000000D8;
//            opcode 
instrbusin[36]={ADDI, 12'd5, 5'd30, 5'd28};

daddrbusout[36] = 64'b0000000000000000000000000000000000000000000000000000000000000110;
databusin[36] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[36] = dontcare;

//* ADDIS  R19,  R21, #3
iaddrbusout[37] = 64'h00000000000000DC;
//            opcode 
instrbusin[37]={ADDIS, 12'd3, 5'd21, 5'd19};

daddrbusout[37] = 64'b0000000000000000000000000000000000000000000000000000010101111010;
databusin[37] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[37] = dontcare;

//* EOR   R27, R29, R31
iaddrbusout[38] = 64'h00000000000000E0;
//             opcode
instrbusin[38]={EOR, 5'd31, 6'd10, 5'd29, 5'd27};

daddrbusout[38] = 64'b1111111111111111111111111111111111111111111111111111111111111011;
databusin[38] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[38] = dontcare;

//* EORI   R12, R16, #hBFFF
iaddrbusout[39] = 64'h00000000000000E4;
//             opcode
instrbusin[39]={EORI, 12'hBFFF, 5'd16, 5'd12};

daddrbusout[39] = 64'b1111111111111111111111111111111111111111111111111111000000000000;
databusin[39] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[39] = dontcare;

//* LSR   R26, R22, 6'd10
iaddrbusout[40] = 64'h00000000000000E8;
//             opcode
instrbusin[40]={LSR, 5'd01, 6'd10, 5'd22, 5'd26};

daddrbusout[40] = 64'b0000000000111111111111111111111111111111111111111111111111111111;
databusin[40] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[40] = dontcare;

//* LSL   R30, R18, 6'd12
iaddrbusout[41] = 64'h00000000000000EC;
//             opcode
instrbusin[41]={LSL, 5'd01, 6'd12, 5'd18, 5'd30};

daddrbusout[41] = 64'b0000000000000000000000000000000000000000000000000001000000000000;
databusin[41] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[41] = dontcare;

//* STUR R15, [R25,13]
iaddrbusout[42] = 64'h00000000000000F0;
//             opcode
instrbusin[42]={STUR, 9'd13, 2'b10, 5'd25, 5'd15};

daddrbusout[42] = 64'b0011001100110011001100110011001100110011001100110111110000000000;
databusin[42] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[42] = 64'b0011001100110011001100110011001100110011001100110111110000000000;

//* MOVZ  R25, (<< 1*16), #hABCD 
iaddrbusout[43] = 64'h00000000000000F4;
//             opcode
instrbusin[43]={MOVZ, 2'b01, 16'hABCD, 5'd25};

daddrbusout[43] = 64'b0000000000000000000000000000000010101011110011010000000000000000;
databusin[43] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[43] = dontcare;

//* MOVZ  R27, (<< 3*16), #h2345
iaddrbusout[44] = 64'h00000000000000F8;
//             opcode
instrbusin[44]={MOVZ, 2'b11, 16'h2345, 5'd27};

daddrbusout[44] = 64'b0010001101000101000000000000000000000000000000000000000000000000;
databusin[44] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[44] = dontcare;

//* CBZ R21, #d12
iaddrbusout[45] = 64'h00000000000000FC;
//            opcode
instrbusin[45]={CBZ, 19'd12, 5'd21};

daddrbusout[45] = dontcare;
databusin[45] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[45] = dontcare;

//* SUBI  R25,  R31, #1
iaddrbusout[46] = 64'h0000000000000100;
//            opcode 
instrbusin[46]={SUBI, 12'd1, 5'd31, 5'd25};

daddrbusout[46] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[46] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[46] = dontcare;

//* CBNZ R21, #d12
iaddrbusout[47] = 64'h0000000000000104;
//            opcode
instrbusin[47]={CBNZ, 19'd12, 5'd21};

daddrbusout[47] = dontcare;
databusin[47] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[47] = dontcare;

//* ADDI R8, R29, #135
iaddrbusout[48] = 64'h0000000000000108;
//            opcode 
instrbusin[48]={ADDI, 12'd135, 5'd29, 5'd8};

daddrbusout[48] = 64'b0000000000000000000000000000000000000000000000000000000010000010;
databusin[48] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[48] = dontcare;

//* EORI R7, R15, #277
iaddrbusout[49] = 64'h0000000000000134;
//            opcode 
instrbusin[49]={EORI, 12'd277, 5'd15, 5'd7};

daddrbusout[49] = 64'b0000000000000000000000000000000000000000000000000000000100011011;
databusin[49] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[49] = dontcare;

//* LDUR R25, [R26,0]
iaddrbusout[50] = 64'h0000000000000138;
//                 
instrbusin[50]={LDUR, 9'b000000000, 2'b00, 5'd26, 5'd25};

daddrbusout[50] = 64'b0000000000111111111111111111111111111111111111111111111111111111;
databusin[50] = 64'hAAAAAAAAAAAAAAAA;
databusout[50] = dontcare;

//* STUR R20, [R23,100]
iaddrbusout[51] = 64'h000000000000013C;
//             opcode
instrbusin[51]={STUR, 9'd100, 2'b10, 5'd23, 5'd20};

daddrbusout[51] = 64'b0000000000000000000000000000000000000000000000000000000001011111;
databusin[51] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[51] = 64'b1111111111111111111111111111111111111111111111111111110010101111;

//* LDUR R24, [R18,0]
iaddrbusout[52] = 64'h0000000000000140;
//            opcode 
instrbusin[52]={LDUR, 9'b000000000, 2'b00, 5'd18, 5'd24};

daddrbusout[52] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[52] = 64'hAAAAAAAAAAAAAAAA;
databusout[52] = dontcare;

//* ADD  R6, R10, R11
iaddrbusout[53] = 64'h00000000000000144;
//            opcode
instrbusin[53]={ADD, 5'd27, 6'd1, 5'd28, 5'd25};

daddrbusout[53] = 64'b0010001101000101000000000000000000000000000000000000000000000110;
databusin[53] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[53] = dontcare;

//* STUR R19, [R20,30]
iaddrbusout[54] = 64'h0000000000000148;
//             opcode
instrbusin[54]={STUR, 9'd30, 2'b10, 5'd20, 5'd19};

daddrbusout[54] = 64'b1111111111111111111111111111111111111111111111111111110011001101;
databusin[54] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[54] = 64'b0000000000000000000000000000000000000000000000000000010101111010;

//* SUBIS R17, R31, #0
iaddrbusout[55] = 64'h000000000000014C;
//            opcode 
instrbusin[55]={SUBIS, 12'd0, 5'd31, 5'd17};

daddrbusout[55] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[55] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[55] = dontcare;

//* BEQ  #24
iaddrbusout[56] = 64'h0000000000000150;
//            opcode 
instrbusin[56]={BEQ, 19'd24, 5'd0};

daddrbusout[56] = 64'b1010101010101010101010101010101010101010101010101010101100001001;
databusin[56] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[56] = dontcare;

//* ANDIS R5, R14, #753
iaddrbusout[57] = 64'h0000000000000154;
//            opcode 
instrbusin[57]={ANDIS, 12'd753, 5'd14, 5'd5};

daddrbusout[57] = 64'b0000000000000000000000000000000000000000000000000000000000000001;
databusin[57] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[57] = dontcare;

//* ORR R28, R24, R31           
iaddrbusout[58] = 64'h00000000000001B0;
//             opcode 
instrbusin[58]={ORR, 5'd31, 6'd0, 5'd24, 5'd28};

daddrbusout[58] = 64'b1010101010101010101010101010101010101010101010101010101010101010;
databusin[58] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[58] = dontcare;

//* STUR R25, [R24,3]
iaddrbusout[59] = 64'h00000000000001B4;
//            opcode 
instrbusin[59]={STUR, 9'd3, 2'b10, 5'd24, 5'd25};

daddrbusout[59] = 64'b1010101010101010101010101010101010101010101010101010101010101101;
databusin[59] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[59] = 64'b0010001101000101000000000000000000000000000000000000000000000110;

//* SUBIS R4, R17, 52
iaddrbusout[60] = 64'h00000000000001B8;
//            opcode 
instrbusin[60]={SUBIS, 12'd52, 5'd17, 5'd4};

daddrbusout[60] = 64'b1111111111111111111111111111111111111111111111111111111111001100;
databusin[60] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[60] = dontcare;

//* EOR R29, R24, R25
iaddrbusout[61] = 64'h00000000000001BC;
//            opcode
instrbusin[61]={EOR, 5'd25, 6'd10, 5'd24, 5'd29};

daddrbusout[61] = 64'b1000100111101111101010101010101010101010101010101010101010101100;
databusin[61] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[61] = dontcare;

//* ORRI R3, R5, 1111
iaddrbusout[62] = 64'h00000000000001C0;
//             opcode   source1   source2   dest      shift     Function...
instrbusin[62]={ORRI, 12'd1111, 5'd5, 5'd3};

daddrbusout[62] = 64'b0000000000000000000000000000000000000000000000000000010001010111;
databusin[62] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[62] = dontcare;

//  ORR  R2, R24, R25
iaddrbusout[63] = 64'h00000000000001C4;
//            opcode 
instrbusin[63]={ORR, 5'd25, 6'd0, 5'd24, 5'd2};

daddrbusout[63] = 64'b1010101111101111101010101010101010101010101010101010101010101110;
databusin[63] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[63]  = dontcare;

//* LSR  R5, R22, 6'd6
iaddrbusout[64] = 64'h00000000000001C8;
//             opcode
instrbusin[64]={LSR, 5'd01, 6'd6, 5'd22, 5'd5};

daddrbusout[64] = 64'b0000001111111111111111111111111111111111111111111111111111111111;
databusin[64] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[64] = dontcare;

//* LSL  R6, R13, 6'd15
iaddrbusout[65] = 64'h00000000000001CC;
//             opcode
instrbusin[65]={LSL, 5'd01, 6'd15, 5'd13, 5'd6};

daddrbusout[65] = 64'b1111111111111111111111111111111111111111111100110000000000000000;
databusin[65] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[65] = dontcare;

//* STUR R23, [R13,0]
iaddrbusout[66] = 64'h00000000000001D0;
//            opcode 
instrbusin[66]={STUR, 9'd000, 2'b10, 5'd13, 5'd23};

daddrbusout[66] = 64'b1111111111111111111111111111111111111111111111111111111111100110;
databusin[66] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[66] = 64'b1111111111111111111111111111111111111111111111111111111111111011;

//* STUR R24, [R12,0]
iaddrbusout[67] = 64'h00000000000001D4;
//            opcode 
instrbusin[67]={STUR, 9'd000, 2'b10, 5'd12, 5'd24};

daddrbusout[67] = 64'b1111111111111111111111111111111111111111111111111111000000000000;
databusin[67] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[67]  = 64'b1010101010101010101010101010101010101010101010101010101010101010;


//  ADDI  R1,  R31,  #1
iaddrbusout[68] = 64'h00000000000001D8;
//             opcode  
instrbusin[68]={ADDI, 12'd1, 5'd31, 5'd1};
daddrbusout[68] = 64'h01;
databusin[68]   = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[68]  = dontcare;

//* ADDI R0,  R31, #1
iaddrbusout[69] = 64'h00000000000001DC;
//            opcode 
instrbusin[69]={ADDI, 12'd1, 5'd31, 5'd0};
daddrbusout[69] = 64'h01;
databusin[69] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[69] = dontcare;

//* SUBIS 0, R31, #0
iaddrbusout[70] = 64'h00000000000001E0;
//            opcode 
instrbusin[70]={SUBIS, 12'd0, 5'd31, 5'd0};
daddrbusout[70] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
databusin[70] =   64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[70] =  dontcare;

//* CBZ  #16
iaddrbusout[71] = 64'h00000000000001E4;
//            opcode 
instrbusin[71]={CBZ, 19'd12, 5'd21};

daddrbusout[71] = 64'b1111111111111111111111111111111111111111111111111111010101110111;
databusin[71] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[71] = dontcare;

//* SUBI R12, R10, #70
iaddrbusout[72] = 64'h00000000000001E8;
//            opcode
instrbusin[72]={SUBI, 12'd70, 5'd10, 5'd12};
daddrbusout[72] = 64'b1111111111111111111111111111111111111111111111111111111110111011;
databusin[72] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[72] = dontcare;

//* ADDI R11,  R11, #11
iaddrbusout[73] = 64'h00000000000001EC;
//             opcode
instrbusin[73]={ADDI, 12'd11, 5'd11, 5'd11};
daddrbusout[73] = 64'b0000000000000000000000000000000000000000000000000000000000001000;
databusin[73] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[73] = dontcare;

//* ANDI  R10, R9, #hBB
iaddrbusout[74] = 64'h00000000000001F0;
//                   
instrbusin[74] = {ANDI, 12'hBB, 5'd9, 5'd10};
daddrbusout[74] = 64'b0000000000000000000000000000000000000000000000000000000000001001;
databusin[74] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[74] = dontcare;

//* SUBS  R12, R22, R31
iaddrbusout[75] = 64'h00000000000001F4;
//                 
instrbusin[75] = {SUBS, 5'd31, 6'd0, 5'd22, 5'd12};
daddrbusout[75] = 64'b1111111111111111111111111111111111111111111111111111111111111101;
databusin[75]  = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[75] = dontcare;

//* BNE #8
iaddrbusout[76] = 64'h00000000000001F8;
//            opcode
instrbusin[76]={BNE, 19'd8, 5'd0};
daddrbusout[76] = 64'b1111111111111111111111111111111111111111111111111111010111111001;
databusin[76] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[76] = dontcare;

//* SUBS R9, R31, R1
iaddrbusout[77] = 64'h00000000000001FC;
//                 
instrbusin[77] = {SUBS, 5'd1, 6'd0, 5'd31, 5'd9};
daddrbusout[77] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[77] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[77] = dontcare;

//* BGE  #32
iaddrbusout[78] = 64'h0000000000000218;
//            opcode
instrbusin[78]={BGE, 19'd32, 5'd0};
daddrbusout[78] = 64'b1111111111111111111111111111111111111111111111111110101011101110;
databusin[78] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[78] = dontcare;

//* ANDS  R15,  R23, R23
iaddrbusout[79] = 64'h000000000000021C;
//            opcode 
instrbusin[79]={ANDS, 5'd23, 6'd0, 5'd23, 5'd15};
daddrbusout[79] = 64'b1111111111111111111111111111111111111111111111111111111111111011;
databusin[79] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[79] = dontcare;

//* ADDS  R28,  R20, R31
iaddrbusout[80] = 64'h0000000000000298;
//            opcode 
instrbusin[80]={ADDS, 5'd31, 6'd0, 5'd20, 5'd28};
daddrbusout[80] = 64'b1111111111111111111111111111111111111111111111111111110010101111;
databusin[80] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[80] = dontcare;

//* SUBS R31,  R31, R1
iaddrbusout[81] = 64'h000000000000029C;
//                 
instrbusin[81] = {SUBS, 5'd1, 6'd0, 5'd31, 5'd31};
daddrbusout[81] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[81] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[81] = dontcare;

//* BLT  #12
iaddrbusout[82] = 64'h00000000000002A0;
//            opcode
instrbusin[82]={BLT, 19'd12, 5'd0};
daddrbusout[82] = 64'b1111111111111111111111111111111111111111111111111110101011101011;
databusin[82] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[82] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[83] = 64'h00000000000002A4;
//            opcode 
instrbusin[83]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[83] = 64'd0;
databusin[83] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[83] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[84] = 64'h00000000000002D0;
//            opcode 
instrbusin[84]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[84] = 64'd0;
databusin[84] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[84] = dontcare;

//* EOR   R5, R20, R21
iaddrbusout[85] = 64'h00000000000002D4;
//             opcode
instrbusin[85]={EOR, 5'd21, 6'd10, 5'd20, 5'd5};

daddrbusout[85] = 64'b1111111111111111111111111111111111111111111111111111100111011000;
databusin[85] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[85] = dontcare;

//* EORI   R6, R18, #hABC
iaddrbusout[86] = 64'h00000000000002D8;
//             opcode
instrbusin[86]={EORI, 12'hABC, 5'd18, 5'd6};

daddrbusout[86] = 64'b0000000000000000000000000000000000000000000000000000101010111101;
databusin[86] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[86] = dontcare;

//* LSR   R23, R20, 6'd16
iaddrbusout[87] = 64'h00000000000002DC;
//             opcode
instrbusin[87]={LSR, 5'd01, 6'd16, 5'd20, 5'd23};

daddrbusout[87] = 64'b0000000000000000111111111111111111111111111111111111111111111111;
databusin[87] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[87] = dontcare;

//* LSL   R22, R21, 6'd18
iaddrbusout[88] = 64'h00000000000002E0;
//             opcode
instrbusin[88]={LSL, 5'd01, 6'd18, 5'd21, 5'd22};

daddrbusout[88] = 64'b0000000000000000000000000000000000010101110111000000000000000000;
databusin[88] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[88] = dontcare;

//* B     #d64
iaddrbusout[89] = 64'h00000000000002E4;
//             opcode
instrbusin[89]={BRANCH, 26'd64};

daddrbusout[89] = 64'b1010101111101111101010101010101010101010101010101001010110011001;
databusin[89] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[89] = dontcare;

//* MOVZ  R23, (<< 0*16), #h3333
iaddrbusout[90] = 64'h00000000000002E8;
//             opcode
instrbusin[90]={MOVZ, 2'b00, 16'h3333, 5'd23};

daddrbusout[90] = 64'b0000000000000000000000000000000000000000000000000011001100110011;
databusin[90] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[90] = dontcare;

//* MOVZ  R15, (<< 3*16), #h5555
iaddrbusout[91] = 64'h00000000000003E4;
//             opcode
instrbusin[91]={MOVZ, 2'b11, 16'h5555, 5'd15};

daddrbusout[91] = 64'b0101010101010101000000000000000000000000000000000000000000000000;
databusin[91] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[91] = dontcare;

//* CBZ R31, #d16
iaddrbusout[92] = 64'h00000000000003E8;
//            opcode
instrbusin[92]={CBZ, 19'd16, 5'd31};
daddrbusout[92] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[92] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[92] = dontcare;

//* ADDI  R31,  R31, #0
iaddrbusout[93] = 64'h00000000000003EC;
//            opcode 
instrbusin[93]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[93] = 64'd0;
databusin[93] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[93] = dontcare;

//* CBNZ R31, #d16
iaddrbusout[94] = 64'h0000000000000428;
//            opcode
instrbusin[94]={CBNZ, 19'd16, 5'd31};
daddrbusout[94] = 64'b1111111111111111111111111111111111111111111111111111111111111111;
databusin[94] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[94] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[95] = 64'h000000000000042C;
//            opcode 
instrbusin[95]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[95] = 64'd0;
databusin[95] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[95] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[96] = 64'h0000000000000430;
//            opcode 
instrbusin[96]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[96] = 64'd0;
databusin[96] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[96] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[97] = 64'h0000000000000434;
//            opcode 
instrbusin[97]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[97] = 64'd0;
databusin[97] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[97] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[98] = 64'h0000000000000438;
//            opcode 
instrbusin[98]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[98] = 64'd0;
databusin[98] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[98] = dontcare;

//* NOP  ADDI  R31,  R31, #0
iaddrbusout[99] = 64'h000000000000043C;
//            opcode 
instrbusin[99]={ADDI, 12'd0, 5'd31, 5'd31};
daddrbusout[99] = 64'd0;
databusin[99] = 64'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
databusout[99] = dontcare;

// (no. instructions) + (no. loads) + 2*(no. stores) = 
ntests = 204;

$timeformat(-9,1,"ns",12);

end


//assumes positive edge FF.
//testbench reads databus when clk high, writes databus when clk low.
assign databus = clkd ? 64'bz : databusk;

//Change inputs in middle of period (falling edge).
initial begin
  error = 0;
  clkd =1;
  clk=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  databusk = 32'bz;

  //extended reset to set up PC MUX
  reset = 1;
  $display ("reset=%b", reset);
  #5
  clk=0;
  clkd=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5

  clk=1;
  clkd=1;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5
  clk=0;
  clkd=0;
  $display ("Time=%t\n  clk=%b", $realtime, clk);
  #5
  $display ("Time=%t\n  clk=%b", $realtime, clk);

for (k=0; k<= num; k=k+1) begin
    clk=1;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd=1;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    reset = 0;
    $display ("reset=%b", reset);


    //set load data for 3rd previous instruction
    if (k >=3)
      databusk = databusin[k-3];

    //check PC for this instruction
    if (k >= 0) begin
      $display ("  Testing PC for instruction %d", k);
      $display ("    Your iaddrbus =    %b", iaddrbus);
      $display ("    Correct iaddrbus = %b", iaddrbusout[k]);
      if (iaddrbusout[k] !== iaddrbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    //put next instruction on ibus
    instrbus=instrbusin[k];
    $display ("  instrbus=%b %b %b %b %b for instruction %d: %s", instrbus[31:26], instrbus[25:21], instrbus[20:16], instrbus[15:11], instrbus[10:0], k, iname[k]);

    //check data address from 3rd previous instruction
    if ( (k >= 3) && 
	     ((k-3) != 24)  && ((k-3) != 29) && ((k-3) != 31) && ((k-3) != 35) && 
	     ((k-3) != 42) && ((k-3) != 45) && ((k-3) != 47)                        ) begin
	
	//if ( (k >= 3) && (daddrbusout[k-3] !== dontcare) ) begin
      $display ("  Testing data address for instruction %d:", k-3);
      $display ("  %s", iname[k-3]);
      $display ("    Your daddrbus =    %b", daddrbus);
      $display ("    Correct daddrbus = %b", daddrbusout[k-3]);
      if (daddrbusout[k-3] !== daddrbus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end
    

    //check store data from 3rd previous instruction
    if ( (k >= 3) && (databusout[k-3] !== dontcare) && 
	     ((k-3) != 24) && ((k-3) != 29) && ((k-3) != 31) && ((k-3) != 35) && 
		 ((k-3) != 42) && ((k-3) != 45 ) && ((k-3) != 47)                      ) begin
      $display ("  Testing store data for instruction %d:", k-3);
      $display ("  %s", iname[k-3]);
      $display ("    Your databus =    %b", databus);
      $display ("    Correct databus = %b", databusout[k-3]);
      if (databusout[k-3] !== databus) begin
        $display ("    -------------ERROR. A Mismatch Has Occured-----------");
        error = error + 1;
      end
    end

    clk = 0;
    $display ("Time=%t\n  clk=%b", $realtime, clk);
    #2
    clkd = 0;
    #3
    $display ("Time=%t\n  clk=%b", $realtime, clk);
  end

  if ( error !== 0) begin
    $display("--------- SIMULATION UNSUCCESFUL - MISMATCHES HAVE OCCURED ----------");
  end

  if ( error == 0)
    $display("---------YOU DID IT!! SIMULATION SUCCESFULLY FINISHED----------");

   $display(" Number Of Errors = %d", error);
   $display(" Total Test numbers = %d", ntests);
   $display(" Total number of correct operations = %d", (ntests-error));
   $display(" ");

end

endmodule
