module alu(
    input wire[31:0] op1, wire[31:0] op2, reg[3:0] alu_op,
    output reg zero, reg[31:0] result
);

// ALU module for Exercise 1
parameter[3:0] ALUOP_AND = 4'b0000; //Logical AND
parameter[3:0] ALUOP_OR = 4'b0001; // Logical OR 
parameter[3:0] ALUOP_ADD = 4'b0010; // Addition
parameter[3:0] ALUOP_SUB = 4'b0110; // Subtraction
parameter[3:0] ALUOP_SLT = 4'b0111; // Less than
parameter[3:0] ALUOP_SRL = 4'b1000; // Logical shift right
parameter[3:0] ALUOP_SLL = 4'b1001; // Logical shift left
parameter[3:0] ALUOP_SRA = 4'b1010; // Arithmetic shift right
parameter[3:0] ALUOP_XOR = 4'b1101; // Logical XOR

// Choose an operation according to the parameter
always @* begin
    case(alu_op)
    ALUOP_AND: result = op1 & op2;
    ALUOP_OR: result = op1 | op2;
    ALUOP_ADD: result = op1 + op2;
    ALUOP_SUB: result = op1 - op2;
    ALUOP_SLT: result = (-op1 < -op2) ? 32'b1 : 32'b0;
    ALUOP_SRL: result = op1 >> op2[4:0];
    ALUOP_SLL: result = op1 << op2[4:0];
    ALUOP_SRA: result = -(-op1 >>> op2[4:0]);
    ALUOP_XOR: result = op1 ^ op2;
    default: result = 32'b0;
    endcase
    zero = (result == 32'b0) ? 1'b1 : 1'b0;
end 
endmodule