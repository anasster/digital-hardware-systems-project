module datapath #(
    parameter INITIAL_PC = 32'h00400000   
)
(
    input wire clk, rst, wire[31:0] instr, wire PCSrc, ALUSrc, RegWrite, MemToReg, MemWrite, wire[3:0] ALUCtrl, wire loadPC, wire[31:0] WriteBackData,
    output reg[31:0] PC, wire Zero, wire[31:0] dAddress, wire[31:0] dWriteData, dReadData
);

// PC 
wire[31:0] branch_offset;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        PC <= INITIAL_PC; // Reset at default value
    end
    else if(loadPC) begin
        PC <= PCSrc ? PC + branch_offset : PC + 4;
    end
end

// Register File
wire[31:0] rd1;
regfile registers(.clk(clk), .readReg1(instr[19:15]), .readReg2(instr[24:20]), .writeReg(instr[11:7]), .writeData(WriteBackData), .write(RegWrite), .readData1(rd1), .readData2(dWriteData));

// Immediate Generation
reg[31:0] imm;
always @(instr) begin
    case (instr[6:0]) // Case statement for different instruction types (According to opcode value)
    7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // BEQ which has to be shifted left 
    7'b0000011: imm = {{20{instr[31]}}, instr[31:20]}; // LW
    7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // SW
    7'b0010011: imm = {{20{instr[31]}}, instr[31:20]}; // I-type
    default: imm = 32'hxxxxxxxx; 
    endcase
end

// ALU
wire[31:0] op2;
assign op2 = ALUSrc ? imm : dWriteData; // Choose operator 2 according to ALUCtrl signal
alu ALU(.op1(rd1), .op2(op2), .alu_op(ALUCtrl), .zero(Zero), .result(dAddress));

// Branch Target
assign branch_offset = (instr[6:0] == 7'b1100011 && instr[14:12] == 3'b000) ? imm << 1: 32'b0;

// Write Back
assign WriteBackData = MemToReg ? dReadData : dAddress;

endmodule