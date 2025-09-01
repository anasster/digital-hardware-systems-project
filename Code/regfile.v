module regfile(
    input wire clk, wire[4:0] readReg1, readReg2, writeReg, wire[31:0] writeData, wire write,
    output reg[31:0] readData1, readData2
);
// Register file module for exercise 3

// Parametrize the register file size
parameter REG_FILE_SIZE = 32;
parameter DATA_WIDTH = 32;

reg[DATA_WIDTH-1:0] registers[0:REG_FILE_SIZE-1]; // 32 x 32-bit registers
integer i;
// Initialize all registers to 0
initial begin
    for(i = 0; i < REG_FILE_SIZE; i = i + 1) begin
        registers[i] = 32'b0;
    end
end

always @(posedge clk) begin
    // Read the registers
    readData1 = registers[readReg1];
    readData2 = registers[readReg2];

    // Write to the registers
    if(write) begin
        // Write at next cycle if write and read addresses are the same
        if(writeReg == readReg1 || writeReg == readReg2) begin
            registers[writeReg] <= writeData;
        end
        else begin
            registers[writeReg] = writeData;
        end
    end
end
endmodule