module calc(
    input wire clk, btnc, btnl, btnu, btnr, btnd, wire[15:0] sw,
    output reg[15:0] led
);
// Calculator module for Exercise 2

// Sign extend switch
wire[31:0] sw_ext;
assign sw_ext = {{16{sw[15]}}, sw};

// LED sign extend
wire[31:0] led_ext;
assign led_ext = {{16{led[15]}}, led};

// Calculate ALU operation
wire[3:0] alu_op;
decoder dec(.btnr(btnr), .btnc(btnc), .btnl(btnl), .alu_op(alu_op));

// Perform the operation
wire[31:0] res;
wire zero;
alu alu_sub(.op1(led_ext), .op2(sw_ext), .alu_op(dec.alu_op), .zero(zero), .result(res));

// Extract the 16 LSB of the ALU
wire[15:0] acc_in;
assign acc_in = alu_sub.result[15:0]; 

// Accumulator register
always @(posedge clk or posedge btnu)
begin
    if(btnu) begin
        // Reset the register at 0 when btnu is pressed
        led = 16'b0;
    end

    else if(btnd) begin
        // Update the register when btnd is pressed
        led = acc_in;
    end
end

endmodule
