module multiplexers(R0, R1, R2, R3, R4, R5, R6, R7, Gin, Din, SRout, SGout, SDout, MUXout);

	input wire 	[8:0]R0, R1, R2, R3, R4, R5, R6, R7;

	input wire	[8:0]Gin;
	input wire	[8:0]Din;  			// 9 bit
	input wire [7:0]SRout;          // 8 bit
	input wire SGout, SDout;        // 1 bit
			
	output wire [8:0] MUXout;
	
	parameter zero = 8'b0;
	assign MUXout = (SGout == 1)    ? Gin:
					(SDout == 1)    ? Din:
					(SRout == 8'h1) ? R0: 	//00000001
					(SRout == 8'h2) ? R1:	//00000010
					(SRout == 8'h4) ? R2:	//00000100
					(SRout == 8'h8) ? R3:	//00001000
					(SRout == 8'h10)? R4:	//00010000
					(SRout == 8'h20)? R5:	//00100000
					(SRout == 8'h40)? R6:	//01000000
					(SRout == 8'h80)? R7:	//10000000
					R0;
endmodule
