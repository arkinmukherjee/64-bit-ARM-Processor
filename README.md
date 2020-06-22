# 64-bit-ARM-Processor

This project contains a fully working 5-stage CPU pipeline using ARM LEGv8 instruction set. It can run at a 20 MHz clock rate, making each clock cycle 50 nanoseconds. 

The 32nd register is the zero register and will always contain the value of 0. The ALU performs operations in log(n) time by using the Look Ahead Carry (LAC) technique. The processor handles 32-bit instructions in all 6 formats (R, I, D, B, CB, and IM). 

The following instructions are supported:
  - ADD
  - ADDI
  - ADDIS
  - ADDS
  - AND
  - ANDI
  - ANDIS
  - ANDS
  - CBNZ
  - CBZ
  - EOR
  - EORI
  - LDUR
  - LSL
  - LSR
  - MOVZ
  - ORR
  - ORRI
  - STUR
  - SUB
  - SUBI
  - SUBIS
  - SUBS
  - B
  - B.EQ
  - B.NE
  - B.LT (signed)
  - B.GE (signed)
  
The LEGv8 instruction reference card can be found here: https://booksite.elsevier.com/9780128017333/content/Green%20Card.pdf
