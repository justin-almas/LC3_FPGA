`timescale 1ns/1ps
module tb_lc3;


reg clk;
reg rst;




LC3 lc3(
    .clock(clk),
    .rst(rst)

);

initial begin
    clk = 0;
    rst = 1;
	 #5 rst = 0;
    forever #5 clk = ~clk;
end

//initial begin
	//#10000 $stop;
//end



endmodule