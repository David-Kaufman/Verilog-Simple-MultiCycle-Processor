module regn(R, Rin, Clock, Q);

parameter n = 9;		//num of bits
input wire [n-1:0] R;	// Input
input wire 	Rin, 		// Enable Register
			Clock; 
output reg [n-1:0] Q;	//Output

always @(posedge Clock)
	if (Rin)		// if enable
		Q <= R;		// copy input to output
endmodule
