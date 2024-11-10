module ALU (
    input [15:0] a,
    input [15:0] b,
    input [1:0] aluk,

    output [15:0] c
);

assign c = (aluk == 'b00) ? $signed(a) + $signed(b) :
           (aluk == 'b01) ? a & b :
           (aluk == 'b10) ? ~a :
           a;





endmodule