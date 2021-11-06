module dec3to8(W, En, Y);
input wire [2:0] W;
input wire En; 
output reg [7:0] Y;

always @(W or En) 
	begin
		if (En == 1)
			case (W)
				3'b111: Y = 8'b10000000;	// Enable R7
				3'b110: Y = 8'b01000000;	// Enable R6
				3'b101: Y = 8'b00100000;   	// Enable R5
				3'b100: Y = 8'b00010000;	// Enable R4
				3'b011: Y = 8'b00001000;	// Enable R3
				3'b010: Y = 8'b00000100;	// Enable R2
				3'b001: Y = 8'b00000010; 	// Enable R1
				3'b000: Y = 8'b00000001;  	// Enable R0
			endcase 
		else
			Y = 8'b00000000;

	 end
endmodule
