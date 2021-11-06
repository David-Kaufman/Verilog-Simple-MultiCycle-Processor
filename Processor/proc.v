module proc (DIN, Resetn, Clock, Run, Done, BusWires, R0, R1, R2, R3, R4, R5, R6, R7, Aout, Gout, ALUout); 
	input wire [8:0] DIN;
	input wire Resetn, Clock, Run;
	output reg Done;
	output wire [8:0] BusWires;

	wire [2:0]I;
	wire [8:0]IR;
	output wire [8:0] R0, R1, R2, R3, R4, R5, R6, R7, Aout, Gout, ALUout;
	
	reg [7:0] Rin; // 8bit enable WRITE R0...R7
	reg [7:0] SRout;
	reg [1:0] Tstep_Q, Tstep_D;
	reg IRin, SGout, SDout;
	reg Ain, Gin, selectOP;

	wire [7:0] Xreg, Yreg;
	
	parameter 	T0 = 2'b00, //Time slots
				T1 = 2'b01,
				T2 = 2'b10,
				T3 = 2'b11;
				
	parameter 	MV  = 3'b000, //operations
				MVI = 3'b001,
				ADD = 3'b010,
				SUB = 3'b011,
				ADDI = 3'b100,
				MVIALL = 3'b101;

	
	//... declare variables


	//Instruction: movi R0, 5
	// 001	    000 000 00000101
	// opcode	 X	 Y	Immidiate
	// movi	     R0			5

	// DIN = III XXX YYY
	assign I = IR[8:6]; 				// take bits 6,7,8 - INSTRUCTION
	dec3to8 decX (IR[5:3], 1'b1, Xreg); // take bits 3,4,5 - XXX - convert to 9 bits "one-hot code"
	dec3to8 decY (IR[2:0], 1'b1, Yreg);	// take bits 0,1,2 - YYY - convert to 9 bits "one-hot code"

	// testQ - position in instruction
	// testQ == 1: T0
	// testQ == 2: T1
	// testQ == 3: T2
	// testQ == 4: T3

	// in which state of the operation are we?
	// Control FSM state table

	// Tstep_Q = current state
	// Tstep_D = next state

	always @(Tstep_Q, Run, Done) begin
		
		case (Tstep_Q)
			T0: begin	
					// data is loaded into IR in this time step 
					if (!Run)
						Tstep_D = T0;
					else
						Tstep_D = T1;
				end
				
			T1: begin
					if(Done)
						Tstep_D = T0;
					else
						Tstep_D = T2;
				end
				
			T2: begin
					 Tstep_D = T3;
				end
				
			T3: begin
					 Tstep_D = T0;
				end
		endcase
	end

	// Control FSM outputs
	always @(Tstep_Q or I or Xreg or Yreg) begin

		//... specify initial values
		IRin <= 1'b0; 
		Ain <= 1'b0;
		Gin <= 1'b0;
		Done <= 1'b0;
		Rin <= 8'b0;
		SDout <= 1'b0;
		SGout <= 1'b0;
		SRout <= 8'b0;

		
		case (Tstep_Q) 
			T0: begin  			// store DIN in IR in time step 0 begin
					IRin <= 1'b1;
				end
				
			T1:	begin			//define signals in time step 1
					case (I)
						MV: begin
							Rin  <= Xreg;     // enable write to register
							SRout <= Yreg;  	  // select register to read
							Done <= 1'b1;
							end
						
						MVI: begin
							SDout <= 1'b1;
							Rin  <= Xreg;     // enable write to register
							Done <= 1'b1;
							end
		
						ADD: begin
							SRout <= Xreg;	// read from register
							Ain <= 1'b1;	//enable write to register A
							end
								
						SUB: begin
							SRout <= Xreg;	// read from register
							Ain <= 1'b1;	//enable write to register A
							end
							
						ADDI: begin
							SRout <= Xreg;	// read from register
							Ain <= 1'b1;	//enable write to register A
							end
							
						MVIALL: begin
							SDout <= 1'b1;
							Rin  <= 8'hFF;     // enable write to all registers
							Done <= 1'b1;
							end
							
						default:
							Done <= 1'b1;
							
					endcase //case(I)
				end //T1
									
			T2: begin	//define signals in time step 2			
					Gin <= 1'b1;
					case(I)
						ADD:begin
							SRout <= Yreg;	// read from register
							selectOP <= 1'b1;
							end
							
						SUB:begin
							SRout <= Yreg;	// read from register
							selectOP <= 1'b0;
							end
							
						ADDI:begin
							SDout <= 1'b1;	// Read Immidate
							selectOP <= 1'b1;
							end
							
						default: 
							Gin <= 1'b0;
					endcase //case(I)
										
				end //T2
			
			T3: begin //define signals in time step 3
				case(I)
					ADD, SUB, ADDI: begin
					SGout <= 1'b1;	
					Rin <= Xreg;	// write to register	
					Done <= 1'b1;
					end
				endcase
				end //T3
				
		endcase //case(Tstep_Q)
	end //always


	// Control FSM flip-flops
	always @(posedge Clock, negedge Resetn) begin
		
		if (!Resetn) 			// restart. reset enable at 0
			Tstep_Q <= T0;
		else
			Tstep_Q <= Tstep_D; // cs = ns
	end
	
	//... instantiate other registers and the adder/subtractor unit
	//... define the bus
	regn reg_0 (BusWires, Rin[0], Clock, R0);
	regn reg_1 (BusWires, Rin[1], Clock, R1);
	regn reg_2 (BusWires, Rin[2], Clock, R2);
	regn reg_3 (BusWires, Rin[3], Clock, R3);
	regn reg_4 (BusWires, Rin[4], Clock, R4);
	regn reg_5 (BusWires, Rin[5], Clock, R5);
	regn reg_6 (BusWires, Rin[6], Clock, R6);
	regn reg_7 (BusWires, Rin[7], Clock, R7);
	
	regn reg_A (BusWires, Ain, Clock, Aout);
	regn reg_G (ALUout, Gin, Clock, Gout); 	
	regn reg_IR (DIN, IRin, Clock, IR);

	multiplexers multiplex(.R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7), .Gin(Gout), 
	                       .Din(DIN), .SRout(SRout), .SGout(SGout), .SDout(SDout), .MUXout(BusWires));
	
	addSub addSub(.A(Aout), .B(BusWires), .selectOP(selectOP), .ALUout(ALUout));
	
endmodule
