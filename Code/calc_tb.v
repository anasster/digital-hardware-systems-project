`timescale 1ns/1ps

module calc_tb();
// Testbench for alu calculator module
reg btnl_t, btnu_t, btnc_t, btnr_t, btnd_t, clk_t;
reg[15:0] sw_t = 16'hxxxx;
reg[15:0] prev = 16'hxxxx;
wire[15:0] led_t = 16'hxxxx;

// Initialize the clock and set a clock cycle of 20 ns
initial begin
    clk_t = 1'b0;
end
always begin
    #10 clk_t = ~clk_t;
end

// Initialize reset (btnu) and update at 0
initial begin
    btnu_t = 1'b1;
    btnd_t = 1'b0;
end


// Instantiate a test module for the calculator
calc calc_t(.clk(clk_t), .btnc(btnc_t), .btnu(btnu_t), .btnr(btnr_t), .btnd(btnd_t), .btnl(btnl_t), .sw(sw_t), .led(led_t));

// Always update led according to previous value
assign led_t = prev;

// Initialize the previous values for reset
initial begin
    // Reset
    #10;
    btnu_t = 1'b0;
    #10;
    btnd_t = 1'b0;
    

    // OR
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b0; btnc_t = 1'b1; btnr_t = 1'b1;
    sw_t = 16'h1234; prev = calc_t.led;
    $display("Time = %0t, Reset result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;

    // AND
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b0; btnc_t = 1'b1; btnr_t = 1'b0;
    sw_t = 16'h0ff0; prev = calc_t.led;
    $display("Time = %0t, OR result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;

    // ADD
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b0; btnc_t = 1'b0; btnr_t = 1'b0;
    sw_t = 16'h324f; prev = calc_t.led;
    $display("Time = %0t, AND result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;

    // SUB
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b0; btnc_t = 1'b0; btnr_t = 1'b1;
    sw_t = 16'h2d31; prev = calc_t.led;
    $display("Time = %0t, ADD result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;

    // XOR
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b1; btnc_t = 1'b0; btnr_t = 1'b0;
    sw_t = 16'hffff; prev = calc_t.led;
    $display("Time = %0t, SUB result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;

    // Less Than
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b1; btnc_t = 1'b0; btnr_t = 1'b1;
    sw_t = 16'h7346; prev = calc_t.led;
    $display("Time = %0t, XOR result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;

    // Shift Left Logical
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b1; btnc_t = 1'b1; btnr_t = 1'b0;
    sw_t = 16'h0004; prev = calc_t.led;
    $display("Time = %0t, LT result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;

    // Shift Right Arithmetic
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b1; btnc_t = 1'b1; btnr_t = 1'b1;
    sw_t = 16'h0004; prev = calc_t.led;
    $display("Time = %0t, SLL result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0; 

    // Less Than
    #10;
    btnd_t = 1'b1;
    btnl_t = 1'b1; btnc_t = 1'b0; btnr_t = 1'b1;
    sw_t = 16'hffff; prev = calc_t.led;
    $display("Time = %0t, SRA result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;

    #10;
    btnd_t = 1'b1;
    prev = calc_t.led;
    $display("Time = %0t, SL result: %b", $time, calc_t.led);
    #10;
    btnd_t = 1'b0;


end


endmodule