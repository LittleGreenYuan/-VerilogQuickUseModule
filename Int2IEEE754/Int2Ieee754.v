`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: GreenYuan
// 
// Create Date: 2023/02/16 16:56:56
// Module Name: Int2Ieee754
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Int2Ieee754
#
(
	parameter	inputDataLength	=	16
)
(
    input 	CLK,
    input 	RST,
    input	[inputDataLength-1:0] 		IntInput,
    input	inputCS,
	 
	 output	reg 	[31:0] 		Data754,
    output 	reg					outputCS
    );
//下降沿有效输出
reg	per_inputCS;
reg	[inputDataLength-1:0]	IntInput_reg;
reg	ChangeStart;
reg	per_outputCS;
always @(posedge CLK or negedge RST ) begin
	if (!RST ) begin
		per_inputCS	<=	0;
		ChangeStart	<=	0;
		per_outputCS<=	0;
	end
	else begin
		per_inputCS	<=	inputCS;
		per_outputCS	<=	outputCS;
		if((per_inputCS==0)&&(inputCS==1)&&(ChangeStart==0))begin
			ChangeStart		<=	1;
			IntInput_reg	<=	IntInput;
		end
		
        if((per_outputCS==0)&&(outputCS==1))begin
			ChangeStart		<=	0;
		end

	end
end

reg	[3:0]	State;
reg	[7:0]	FirstOne;
reg	[6:0]	Offset;
reg	[7:0]	FindFirstOne;
reg	[7:0]	i;
reg	FirstOneFlag;
reg	ParityJudgment;
reg	Parity;

reg	sign;
reg	[6:0]		Exponent;
reg	[23:0]	Mantissa;
reg [7:0]	PlacementPosition;

parameter	ChangeWaiting	=	4'd0;
parameter	FindFirstOneInData	=	4'd1;
parameter	CalculatedPosition	=	4'd3;
parameter	CalculatedWaiting	=	4'd2;
parameter	OutputResult	=	4'd4;
always @(posedge CLK or negedge RST ) begin
	if (!RST ) begin
		State		<=	0;
		FirstOne	<=	0;
		Offset	<=	0;
		FindFirstOne	<=	inputDataLength;
		i	<=	inputDataLength;
		FirstOneFlag	<=	1;
		ParityJudgment	<=	0;
		Parity			<=	0;
		PlacementPosition<=8'd23;
		
		Data754	<=	32'b0_0111111_100000000000000000000000;
		sign		<=	0;
		Exponent	<=	7'b0111111;
		Mantissa	<=	24'd0;
		
		outputCS	<=	0;
	end
	else begin
		case(State)
			ChangeWaiting:begin
				outputCS	<=	0;
				FirstOne	<=	0;
				Offset	<=	0;
				FirstOneFlag	<=	1;
				FindFirstOne	<=	inputDataLength;
				ParityJudgment	<=	0;
				Parity			<=	0;
				
				sign		<=	0;
				Exponent	<=	7'b0111111;
				Mantissa	<=	24'd0;
				PlacementPosition<=23;
				if(ChangeStart==1)begin
					State	<=	FindFirstOneInData;
					FindFirstOne<=inputDataLength;
					Data754	<=	32'b0_0111111_100000000000000000000000;
				end
			end
			
			FindFirstOneInData:begin
				if(FindFirstOne>=1)begin
					Parity	<=	Parity+1;
					if(FirstOneFlag==1)begin
						if(IntInput_reg[FindFirstOne-1]==1)begin

                            
							FirstOneFlag	<=	0;
							FirstOne	<=	FindFirstOne;
							Offset	<=	FindFirstOne>>1;
							State	<=	CalculatedWaiting;
							
							
							
						end
					end
					FindFirstOne<=FindFirstOne-1;
				end
				

			end

			CalculatedWaiting: begin
                ParityJudgment	<=	Parity;
                if(Parity==1)begin
					i<=FirstOne-1;
					PlacementPosition<=22;
				end
				else begin
					i<=FirstOne;
					PlacementPosition<=23;
				end
                State	<=	CalculatedPosition;
            end

			CalculatedPosition:begin
                outputCS    <=  1;
				if(IntInput_reg==1)begin
					sign		<=	0;
					Exponent	<=	7'b0111111;
					Mantissa	<=	24'b100000000000000000000000;
					Data754	<=	32'b0_0111111_100000000000000000000000;
					State	<=	OutputResult;
				end
				else if(IntInput_reg==0)begin
					sign		<=	0;
					Exponent	<=	7'b0000000;
					Mantissa	<=	24'b000000000000000000000000;
					Data754	<=	32'b0_0000000_000000000000000000000000;
					State	<=	OutputResult;
				end
				else if(Parity==1)begin
					sign		<=	0;
					Exponent	<=	7'b0111111+Offset;
					Mantissa[23]	<=	0;
					if(i>=1)begin
						Mantissa[PlacementPosition]	<=	IntInput_reg[i-1];
						i	<=	i-1;
						PlacementPosition<=PlacementPosition-1;
					end
					else begin
						State	<=	OutputResult;
					end
					
				end
				else if(Parity==0) begin
					sign		<=	0;
					Exponent	<=	7'b0111111+Offset;
					if(i>=1)begin
						Mantissa[PlacementPosition]	<=	IntInput_reg[i-1];
						i	<=	i-1;
						PlacementPosition<=PlacementPosition-1;
					end
					else begin
						State	<=	OutputResult;
					end
					
				end
                else begin
                    State	<=	0;
                end
				
			end
			
			OutputResult:begin
				outputCS	<=	1;
				Data754	<=	{sign,Exponent,Mantissa};
				State	<=	ChangeWaiting;
			end
			
			default:begin
				State	<=	ChangeWaiting;
			end
		endcase
	end
end 

endmodule

