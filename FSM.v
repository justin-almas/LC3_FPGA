module FSM (
	input [2:0]   NZP,
	input [15:0]  IR,
	input         clk,
	input         rst,
	
	output HALT,	
	output LD_MAR,
	output LD_MDR,
	output LD_IR,
	output LD_REG,
	output LD_CC,
	output LD_PC,
	output GatePC,
	output GateMDR,
	output GateALU,
	output GateMARMUX,
	output [1:0] PCMUX,
	output [2:0] DR,
	output [2:0] SR1,
	output ADDR1MUX,
	output [1:0] ADDR2MUX,
	output MARMUX,
	output [1:0] ALUK,
	output MEM_EN,
	output R_W,
	output SR2MUX,
	output [2:0] SR2
	

);


wire SR1MUX;
wire DRMUX;
wire opcode;
reg [6:0] state, next_state;
reg [27:0] rom [0:63];
reg [27:0] signals;


initial begin //rom fill in
rom[0] = 28'h000003F;
rom[1] = 28'h188403F;
rom[2] = 28'h8041412;
rom[3] = 28'h8041413;
rom[4] = 28'h0000014;
rom[5] = 28'h188413F;
rom[6] = 28'h8046C16;
rom[7] = 28'h8046C17;
rom[8] = 28'h1084033;
rom[9] = 28'h188423F;
rom[10] = 28'h804141A;
rom[11] = 28'h804141B;
rom[12] = 28'h04A433F;
rom[13] = 28'h808002F;
rom[14] = 28'h104143F;
rom[15] = 28'h000000F;
rom[16] = 28'h041103F;
rom[17] = 28'h0;
rom[18] = 28'h40000A2;
rom[19] = 28'h4080323;
rom[20] = 28'h161983F;
rom[21] = 28'h0;
rom[22] = 28'h40000A6;
rom[23] = 28'h4080327;
rom[24] = 28'h40000A8;
rom[25] = 28'h0;
rom[26] = 28'h40000AA;
rom[27] = 28'h40000AB;
rom[28] = 28'h0;
rom[29] = 28'h190003F;
rom[30] = 28'h0;
rom[31] = 28'h0;
rom[32] = 28'h0;
rom[33] = 28'h0;
rom[34] = 28'h190003F;
rom[35] = 28'h00000FF;
rom[36] = 28'h161E03F;
rom[37] = 28'h0;
rom[38] = 28'h190003F;
rom[39] = 28'h00000FF;
rom[40] = 28'h2100038;
rom[41] = 28'h0;
rom[42] = 28'h810003A;
rom[43] = 28'h810003B;
rom[44] = 28'h0;
rom[45] = 28'h00000FF;
rom[46] = 28'h0;
rom[47] = 28'h40000B0;
rom[48] = 28'h8100031;
rom[49] = 28'h4080332;
rom[50] = 28'h00000FF;
rom[51] = 28'h1084034;
rom[52] = 28'h04A403F;
rom[53] = 28'h0;
rom[54] = 28'h0;
rom[55] = 28'h0;
rom[56] = 28'h0000020;
rom[57] = 28'h0;
rom[58] = 28'h400009D;
rom[59] = 28'h408032D;
rom[60] = 28'h0;
rom[61] = 28'h0;
rom[62] = 28'h0;
rom[63] = 28'h8600018;
state = 'd18;
end

always @(*) begin
	signals = rom[state];
end

always @(*) begin //next state logic
	case (state) 
		'd18: next_state = 'd28;
		'd28: next_state = 'd30;
		'd30: next_state = 'd32;
		'd32: begin  //decode
			case (opcode)
				'b0001: next_state = 'd1;
				'b0101: next_state = 'd5;
				'b1001: next_state = 'd9;
				'b1110: next_state = 'd14;
				'b0010: next_state = 'd2;
				'b0110: next_state = 'd6;
				'b1010: next_state = 'd10;
				'b1011: next_state = 'd11;
				'b0111: next_state = 'd7;
				'b0011: next_state = 'd3;
				'b0100: next_state = 'd4;
				'b1100: next_state = 'd12;
				'b0000: next_state = 'd0; 
			endcase	
		end
		//ADD
		'd1: next_state = 'd18;
		//AND
		'd5: next_state = 'd18;
		//NOT
		'd9: next_state = 'd18;
		//LEA
		'd14: next_state = 'd18;
		//LD
		'd2: next_state = 'd25;
		//LDR
		'd6: next_state = 'd25;
		//LDI
		'd10: next_state = 'd24;
		'd24: next_state = 'd26;
		'd26: next_state = 'd25;
		//shared LDR LDI LD
		'd25: next_state = 'd27;
		'd27: next_state = 'd18;
		//STI
		'd11: next_state = 'd29;
		'd31: next_state = 'd23;
		//STR
		'd7: next_state = 'd23;
		//ST
		'd3: next_state = 'd23;
		//shared STI STR ST
		'd23: next_state = 'd16;
		'd16: next_state = 'd18;
		//JSR(R)
		'd4: begin
			case (IR[11])
				'b1: next_state = 'd21;
				'b0: next_state = 'd20;
			endcase
		end
		'd21: next_state = 'd18;
		'd20: next_state = 'd18;
		//JMP
		'd12: next_state = 'd18;
		//BR
		'd0: begin
			next_state = (NZP[2] && IR[11]) ? 'd22 :
						 (NZP[1] && IR[10]) ? 'd22 :
						 (NZP[0] && IR[9]) ? 'd22 :
						 'd18;	
		end
		'd22: next_state = 'd18;
	endcase
end




always @(posedge clk or posedge rst) begin
	if(rst) begin
		state = 'd18; 
	end
	else begin
		state <= next_state;
	end
end


assign LD_MAR = signals[27];
assign LD_MDR = signals[26];
assign LD_IR = signals[25];
assign LD_REG = signals[24];
assign LD_CC = signals[23];
assign LD_PC = signals[22];
assign GatePC = signals[21];
assign GateMDR = signals[20];
assign GateALU = signals[19];
assign GateMARMUX = signals[18];
assign PCMUX = signals[17:16];
assign DRMUX = signals[15];
assign SR1MUX = signals[14];
assign ADDR1MUX = signals[13];
assign ADDR2MUX = signals[12:11];
assign MARMUX = signals[10];
assign ALUK = signals[9:8];
assign MEM_EN = signals[7];
assign R_W = signals[6];


assign SR2 = IR[2:0];
assign SR1 = SR1MUX ? IR[8:6] : IR[11:9];
assign DR = DRMUX ? 3'b111 : IR[11:9];
assign SR2MUX = IR[5];
assign opcode = IR[15:12];
assign HALT = (IR[7:0] == 'h25) ? 'b1 : 'b0;


endmodule