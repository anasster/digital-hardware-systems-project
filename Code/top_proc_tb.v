`timescale 1ns/1ps

module top_proc_tb();

// Create wires and regs
reg clk_t, rst_t;
wire[31:0] instr_t, dReadData_t;
wire[31:0] PC_t, dAddress_t, dWriteData_t, WriteBackData_t;
wire MemRead_t, MemWrite_t;
multicycle CPU(.clk(clk_t), .rst(rst_t), .instr(instr_t), .dReadData(dReadData_t), .PC(PC_t), .dAddress(dAddress_t), .dWriteData(dWriteData_t), .MemRead(MemRead_t), .MemWrite(MemWrite_t), .WriteBackData(WriteBackData_t));
INSTRUCTION_MEMORY ROM(.clk(clk_t), .addr(PC_t[8:0]), .dout(instr_t));
DATA_MEMORY RAM(.clk(clk_t), .we(MemWrite_t), .addr(dAddress_t[8:0]), .din(dWriteData_t), .dout(dReadData_t));
// Initialize clock and reset
initial begin
    clk_t = 1'b0;
    rst_t = 1'b1;
end

// Set clock
always begin
    #10 clk_t = ~clk_t;
end

// Set reset to low after 10 seconds
initial begin
    #10 rst_t = 1'b0;
end

always @* begin
    if(CPU.current_state == 3'b000) begin
        if(CPU.instr[6:0] == 7'b1100011) begin
            $display("Instruction: BEQ\n");
        end
        else if(CPU.instr[6:0] == 7'b0000011) begin
            $display("Instruction: LW\n");
        end
        else if(CPU.instr[6:0] == 7'b0100011) begin
            $display("Instruction: SW\n");
        end
        else if(CPU.instr[6:0] == 7'b0010011) begin
            if(CPU.instr[14:12] == 3'b000) $display("Instruction: ADDI\n");
            else if(CPU.instr[14:12] == 3'b010) $display("Instruction: SLTI\n");
            else if(CPU.instr[14:12] == 3'b100) $display("Instruction: XORI\n");
            else if(CPU.instr[14:12] == 3'b110) $display("Instruction: ORI\n");
            else if(CPU.instr[14:12] == 3'b111) $display("Instruction: ANDI\n");
            else if(CPU.instr[14:12] == 3'b001) $display("Instruction: SLLI\n");
            else if(CPU.instr[31:25] == 7'b0000000 && CPU.instr[14:12] == 3'b101) $display("Instruction: SRLI\n");
            else if(CPU.instr[31:25] == 7'b0100000 && CPU.instr[14:12] == 3'b101) $display("Instruction: SRAI\n");
        end
        else if(CPU.instr[6:0] == 7'b0110011) begin
            if(CPU.instr[31:25] == 7'b0000000 && CPU.instr[14:12] == 3'b000) $display("Instruction: ADD\n");
            else if(CPU.instr[31:25] == 7'b0100000 && CPU.instr[14:12] == 3'b000) $display("Instruction: SUB\n");
            else if(CPU.instr[14:12] == 3'b001) $display("Instruction: SLL\n");
            else if(CPU.instr[14:12] == 3'b010) $display("Instruction: SLT\n");
            else if(CPU.instr[14:12] == 3'b100) $display("Instruction: XOR\n");
            else if(CPU.instr[31:25] == 7'b0000000 && CPU.instr[14:12] == 3'b101) $display("Instruction: SRL\n");
            else if(CPU.instr[31:25] == 7'b0100000 && CPU.instr[14:12] == 3'b101) $display("Instruction: SRA\n");
            else if(CPU.instr[14:12] == 3'b110) $display("Instruction: OR\n");
            else if(CPU.instr[14:12] == 3'b111) $display("Instruction: AND\n");
        end
    end
end

endmodule