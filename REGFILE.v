module REGFILE (
    input clk,
    input [15:0] BUS,
    input [2:0] DR,
    input LD_REG,
    input [2:0] SR1,
    input [2:0] SR2,

    output [15:0] SR1_OUT,
    output [15:0] SR2_OUT
    //output [15:0] DEBUG
);

integer i;


reg [15:0] register [0:7];
//assign DEBUG = register[0];

always @(posedge clk) begin
    if(LD_REG) begin
        register[DR] <= BUS;
    end
end


assign SR1_OUT = register[SR1];
assign SR2_OUT = register[SR2];



endmodule