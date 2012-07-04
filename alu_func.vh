//
// ALU function definitions
//

`ifndef _alu_func_vh_
`define _alu_func_vh_

//R-TYPE Instructions

`define ADD  6'b100000
`define ADDU 6'b100001
`define SUB  6'b100010
`define SUBU 6'b100011
`define SLT  6'b101010
`define SLTU 6'b101011
`define SLL  6'b000000
`define SRL  6'b000010
`define SRA  6'b000011
`define AND  6'b100100
`define OR   6'b100101
`define XOR  6'b100110
`define NOR  6'b100111

//I-TYPE instructions
`define ADDIU 6'b001001
`define SLTI  6'b001010
`define LW    6'b100011
`define SW    6'b101011
`define LUI   6'b001111
`define ORI   6'b001101

//J-TYPE instructions
`define J      6'b000010
`define BEQ    6'b000100
`define BNE    6'b000101
`define BGTZ   6'b000111
`define BLEZ   6'b000110
`define REGIMM 6'b000001

`define BLTZ 5'b00000
`define BGEZ 5'b00001 

`endif //  `ifndef _alu_func_vh_

