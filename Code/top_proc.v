module multicycle(
    input wire clk, rst, wire[31:0] instr, dReadData, wire[31:0] dWriteData, 
    output wire[31:0] PC, wire[31:0] dAddress, reg MemRead, MemWrite, wire[31:0] WriteBackData 
);
parameter INITIAL_PC = 32'h00400000;
// Create parameters for each state
parameter IF = 3'b000, ID = 3'b001, EX = 3'b010, MEM = 3'b011, WB = 3'b100;

// Initialize the signals that will be created from the control unit
wire[31:0] branch_offset;
reg ALUSrc, MemToReg, RegWrite, loadPC, PCSrc;
reg[3:0] ALUCtrl;
wire Zero;

// Datapath initialization
datapath #(INITIAL_PC) dpath(.clk(clk), .rst(rst), .instr(instr), .PCSrc(PCSrc), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .MemToReg(MemToReg), .MemWrite(MemWrite), .ALUCtrl(ALUCtrl), .loadPC(loadPC),
                             .PC(PC), .Zero(Zero), .dAddress(dAddress), .dReadData(dReadData), .dWriteData(dWriteData), .WriteBackData(WriteBackData));


// FSM
reg[2:0] current_state, next_state;

// Create a state memory for the FSM
always @(posedge clk or posedge rst) begin: STATE_MEMORY
    if(rst) begin
        current_state <= IF;
    end
    else begin
        current_state <= next_state;
    end
end

// Create next state logic for the FSM
always @(current_state, rst, instr) begin: NEXT_STATE_LOGIC
    case(current_state) 
    IF: next_state = rst ? IF : ID;
    ID: next_state = rst ? IF : EX;
    EX: 
    if(rst) begin 
        next_state = IF;
    end
    else if((instr[6:2] != 5'b01000) && (instr[6:2] != 5'b00000)) begin // If we don't have load or store instrudctions, RAM is not accessed
        next_state = WB;
    end
    else begin
        next_state = MEM;
    end
    MEM: next_state = rst ? IF : WB;
    WB: next_state = IF;
    endcase
end

// Create current state logic for the FSM
always @(current_state or instr) begin: CURRENT_STATE_LOGIC
    case(current_state)
    IF: begin loadPC = 1'b0; MemWrite = 1'b0; MemRead = 1'b0; MemToReg = 1'b0; RegWrite = 1'b0; end
    ID: begin loadPC = 1'b0; MemWrite = 1'b0; MemRead = 1'b0; MemToReg = 1'b0; RegWrite = 1'b0; end
    EX: begin loadPC = 1'b0; MemWrite = 1'b0; MemRead = 1'b0; MemToReg = 1'b0; RegWrite = 1'b0; end
    MEM:begin loadPC = 1'b0; MemWrite = (instr[6:2] == 5'b01000) ? 1'b1 : 1'b0; MemRead = (instr[6:2] == 5'b00000) ? 1'b1 : 1'b0; MemToReg = 1'b0; RegWrite = 1'b0; end  
    WB: begin loadPC = 1'b1; MemWrite = 1'b0; MemRead = 1'b1; MemToReg = instr[6:2] == 5'b00000 ? 1'b1 : 1'b0; RegWrite = (instr[6:0] == 7'b1100011) || (instr[6:0] == 7'b0100011) ? 1'b0 : 1'b1; end 
    endcase
end

// Create control logic to find the signal ALUCtrl
always @(instr) begin: CONTROL_LOGIC_ALUCTRL
    // AND - ANDI
    if(((instr[14:12] == 3'b111) && (instr[6:0] == 7'b0110011)) || ((instr[14:12] == 3'b111) && (instr[6:0] == 7'b0010011))) begin
        ALUCtrl = 4'b0000;
    end
    // OR - ORI
    else if(((instr[14:12] == 3'b110) && (instr[6:0] == 7'b0110011)) || ((instr[14:12] == 3'b110) && (instr[6:0] == 7'b0010011))) begin
        ALUCtrl = 4'b0001;
    end
    // ADD - ADDI
    else if(((instr[31:25] == 7'b0000000) && (instr[14:12] == 3'b000) && instr[6:0] == 7'b0110011) || ((instr[14:12] == 3'b000) && (instr[6:0] == 7'b0010011))) begin
        ALUCtrl = 4'b0010;
    end
    // BEQ (SUB)
    else if(instr[6:0] == 7'b1100011 && instr[14:12] == 3'b000) begin
        ALUCtrl = 4'b0110;
    end
    // SUB 
    else if((instr[31:25] == 7'b0100000) && (instr[14:12] == 3'b000) && (instr[6:0] == 7'b0110011)) begin
        ALUCtrl = 4'b0110;
    end
    // SLT - SLTI
    else if(((instr[31:25] == 7'b0000000) && (instr[14:12] == 3'b010) && (instr[6:0] == 7'b0110011)) || (instr[14:12] == 3'b010) && (instr[6:0] == 7'b0010011)) begin
        ALUCtrl = 4'b0111;
    end
    // SRL - SRLI
    else if(((instr[31:25] == 7'b0000000) && (instr[14:12] == 3'b101) && (instr[6:0] == 7'b0110011)) || ((instr[14:12] == 3'b101) && (instr[6:0] == 7'b0010011))) begin
        ALUCtrl = 4'b1000;
    end
    // SLL - SLLI
    else if(((instr[31:25] == 7'b0000000) && (instr[14:12] == 3'b001) && (instr[6:0] == 7'b0110011)) || ((instr[14:12] == 3'b001) && (instr[6:0] == 7'b0010011))) begin
        ALUCtrl = 4'b1001;
    end
    // SRA - SRAI
    else if(((instr[31:25] == 7'b0100000) && (instr[14:12] == 3'b101) && (instr[6:0] == 7'b0110011)) || ((instr[14:12] == 3'b101) && (instr[6:0] == 7'b0010011))) begin
        ALUCtrl = 4'b1010;
    end
    // XOR - XORI
    else if(((instr[31:25] == 7'b0000000) && (instr[14:12] == 3'b100) && (instr[6:0] == 7'b0110011)) || ((instr[14:12] == 3'b100) && (instr[6:0] == 7'b0010011))) begin
        ALUCtrl = 4'b1101;
    end
    // LW - SW (ADD)
    else if(((instr[14:12] == 3'b010) && (instr[6:0] == 7'b0000011)) || ((instr[14:12] == 3'b010) && (instr[6:0] == 7'b0100011))) begin
        ALUCtrl = 4'b0010;
    end
end

// Create control logic for ALUSrc
always @(instr) begin: CONTROL_LOGIC_ALUSRC
    if(((instr[6:0] == 7'b1100011) && (instr[14:12] == 3'b000)) || ((instr[6:0] == 7'b0000011) && (instr[14:12] == 3'b010)) || ((instr[6:0] == 7'b0100011) && (instr[14:12] == 3'b010)) || ((instr[6:0] == 7'b0010011) && (instr[14:12] != 3'b011))) begin
        ALUSrc = 1'b1;
    end
    else begin
        ALUSrc = 1'b0;
    end
end

 // Create control logic for PCSrc
reg Branch;
always @(instr, Zero) begin:CONTROL_LOGIC_PCSRC
    if(instr[6:0] == 7'b1100011 && instr[14:12] == 3'b000) begin
        Branch = 1'b1;
    end
    else begin
        Branch = 1'b0;
    end
    PCSrc = Branch & Zero;
end

endmodule