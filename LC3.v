module LC3(

	input clock,  //clock from the board
	input rst  //reset
	//output [15:0] reg_value, //only to show what is happening
	//output [15:0] PC_DEBUG
);

//assign PC_DEBUG = PC;

//registers and memory
reg [15:0] mem_contents [0:1023]; //only supporting 2^10 instructions due to memory limitations
reg [15:0] IR;
reg [15:0] MDR;
reg [15:0] MAR;
reg [2:0] NZP;
reg [15:0] PC;
wire [15:0] BUS;

//FSM signals
wire HALT;	
wire LD_MAR;
wire LD_MDR;
wire LD_IR;
wire LD_REG;
wire LD_CC;
wire LD_PC;
wire GatePC;
wire GateMDR;
wire GateALU;
wire GateMARMUX;
wire [1:0] PCMUX;
wire [2:0] DR;
wire [2:0] SR1;
wire ADDR1MUX;
wire [1:0] ADDR2MUX;
wire MARMUX;
wire [1:0] ALUK;
wire MEM_EN;
wire R_W;
wire SR2MUX;
wire [2:0] SR2;


//intermediate signals
wire [15:0] SR1_OUT, SR2_OUT;
wire [15:0] SR2MUX_OUT;
wire [15:0] ALU_OUT;
wire[15:0] MARMUX_OUT;
wire [15:0] ADDR2MUX_OUT, ADDR1MUX_OUT, ADDRESS_ADDER;
wire [2:0] CC_LOGIC_OUT;
wire [15:0] PCMUX_OUT;


assign clk = clock && ~HALT;


FSM fsm(
	.NZP(NZP),
	.IR(IR),
	.clk(clk),
	.rst(rst),
	
	.HALT(HALT),
	.LD_MAR(LD_MAR),
	.LD_MDR(LD_MDR),
	.LD_IR(LD_IR),
	.LD_REG(LD_REG),
    .LD_CC(LD_CC),
	.LD_PC(LD_PC),
	.GatePC(GatePC),
	.GateMDR(GateMDR),
	.GateALU(GateALU),
	.GateMARMUX(GateMARMUX),
	.PCMUX(PCMUX),
	.DR(DR),
	.SR1(SR1),
	.ADDR1MUX(ADDR1MUX),
	.ADDR2MUX(ADDR2MUX),
	.MARMUX(MARMUX),
	.ALUK(ALUK),
	.MEM_EN(MEM_EN),
	.R_W(R_W),
	.SR2MUX(SR2MUX),
	.SR2(SR2)

);

//bus logic
assign BUS = GateALU ? ALU_OUT :
			 GateMDR ? MDR :
			 GatePC ? PC :
			 GateMARMUX ? MARMUX_OUT :
			 16'bZ;

//memory logic
//initial begin
	//PC <= 16'b0;
    //$readmemh("my_code.mem", mem_contents);
//end

always @(posedge clk) begin
	if(LD_MAR) begin
		MAR <= BUS;
	end
	//MDR mux
	if(LD_MDR && MEM_EN && !R_W) begin //reading from memory
		MDR <= mem_contents[MAR[9:0]];
	end else if(LD_MDR && !MEM_EN) begin //getting value from bus
		MDR <= BUS;
	end
end

always @(*) begin //memory isn't clocked with LC-3
	if (MEM_EN && R_W) begin
		mem_contents[MAR[9:0]] = MDR;
	end 
end
//end of memory logic

//register file
REGFILE regfile(
	.clk(clk),
	.BUS(BUS),
	.DR(DR),
	.LD_REG(LD_REG),
	.SR1(SR1),
	.SR2(SR2),
	.SR1_OUT(SR1_OUT),
	.SR2_OUT(SR2_OUT)
	//.DEBUG(reg_value)
);
//end register file logic

//alu logic
assign SR2MUX_OUT = SR2MUX ?  $signed(IR[4:0]) : SR2_OUT;
ALU alu(

	.a(SR1_OUT),
	.b(SR2MUX_OUT),
	.aluk(ALUK),
	.c(ALU_OUT)

);

//addr muxes
assign ADDR1MUX_OUT = ADDR1MUX ? SR1_OUT : PC;

assign ADDR2MUX_OUT = (ADDR2MUX == 'b00) ? 16'b0 :
					  (ADDR2MUX == 'b01) ? $signed(IR[5:0]) : 
					  (ADDR2MUX == 'b10) ? $signed(IR[8:0]) :
					  $signed(IR[10:0]); 

assign ADDRESS_ADDER = $signed(ADDR1MUX_OUT) + $signed(ADDR2MUX_OUT);


//MARMUX

assign MARMUX_OUT = MARMUX ? ADDRESS_ADDER : {8'b0, IR[7:0]};

//CC logic
assign CC_LOGIC_OUT = (BUS == 16'b0) ? 'b010 :
					  (BUS[15] == 'b1) ? 'b100:
					  'b001;

//PC logic

assign PCMUX_OUT = (PCMUX == 'b00) ? PC + 'b1 :
				   (PCMUX == 'b01) ? ADDRESS_ADDER :
				   BUS;


//remaining registers
always @(posedge clk) begin
	if(rst) begin
		PC = 16'b0;
	end
	else if(LD_PC) begin
		PC = PCMUX_OUT;
	end
	if(LD_CC) begin
		NZP = CC_LOGIC_OUT;
	end
	if(LD_IR) begin
		IR = BUS;
	end
end



endmodule
