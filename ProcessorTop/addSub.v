module addSub(A, B, selectOP, ALUout);
	input wire [8:0]A, B;  
	input wire selectOP;
	
	output wire [8:0]ALUout;
	
	parameter ADD = 1'b1,
			  SUB = 1'b0;
	
	assign ALUout = (selectOP == ADD)? A + B: A - B;

endmodule
