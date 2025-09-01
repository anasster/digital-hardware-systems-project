module decoder(
    input wire btnc, btnl, btnr,
    output wire[3:0] alu_op
);
// Module for producing the bits of alu_op
wire op0, op1, op2, op3;

assign op0 = ((~btnr) & btnl) | ((btnc ^ btnl) & btnr); // 1st bit
assign op1 = (btnr & btnl) | ((~btnl) & (~btnc)); // 2nd bit
assign op2 = ((btnr & btnl) | (btnr ^ btnl)) & (~btnc); // 3rd bit
assign op3 = (((~btnr) & btnc) | (btnr ^~ btnc)) & btnl; // 4th bit
assign alu_op = {op3, op2, op1, op0};

endmodule