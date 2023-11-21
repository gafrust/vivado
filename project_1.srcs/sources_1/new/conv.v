
module CONV(
 input  res, 
 input  clk, 
 input wire signed [7: 0] CONV_iData0,
 input wire signed [7: 0] CONV_iData1,
 output reg signed [15: 0] CONV_oData 
 );
parameter LengthOfConv = 8; 
parameter InState = 4'b0001,ConvState = 4'b0010,OutState = 4'b0100,ClrState = 4'b1000;
 

reg [7:0] CONV_iData0reg[LengthOfConv - 1:0];
reg [7:0] CONV_iData1reg[LengthOfConv - 1:0];
reg [15:0] CONV_oDatareg[2*LengthOfConv - 2:0];

reg [7:0] CONV_i0[LengthOfConv - 1:0];
reg [7:0] CONV_i1[LengthOfConv - 1:0];



reg change;
reg [7: 0] index0;
reg [7: 0] index1; 
 
reg [7: 0] index_input; 
reg [7: 0] index_conv;
reg [7: 0] index_output;
//reg [7: 0] index_conv2; 
//reg [7:0]  index_convs; 
reg [7: 0] index_clr; 
 
reg [3:0] state,nextstate;
 
initial
	 begin
        
		index0 <= 0;
		index1 <= 0;
		index_input <= 8'b0;
		index_conv	<= 8'b0;		
		//index_conv2 <= 8'b0;
		index_output<= 8'b0;
		index_clr <= 8'b0;  
		state <= InState;
		nextstate <= ConvState;
	end
 always @ (posedge clk)
begin
	if(res == 0)
	begin
		CONV_iData0reg[index0] <= 8'b0;
		CONV_iData1reg[index0] <= 8'b0;
		CONV_oDatareg[index1] <= 16'b0;
		CONV_i0[index0] <=8'b0;
		CONV_i1[index0] <=8'b0;
		if(index0  == LengthOfConv - 1) 
			index0 = 8'b0;  
		else
			index0 <= index0 + 8'b1;
		if(index1  == LengthOfConv * 2 - 2) 
			index1 = 8'b0;  
		else
			index1 <= index1 + 8'b1;
	end
	else
	begin
		 if (state == InState) 
		begin
			begin
				CONV_iData0reg[index_input] <= CONV_iData0;
				CONV_iData1reg[index_input] <= CONV_iData1;
				index_input <= index_input + 8'b1;
				 CONV_oData <= 0; 
			end
			if(index_input >= LengthOfConv - 1)
			begin
				index_input <= 8'b0;
				state <= nextstate;
				nextstate  <= OutState;
			end
		end
		 if (state == ConvState) // ������������ �������
		begin
			  CONV_oData <= 0; // ����� �������������� �� ��������, �� ������ ����� 0
			 if(index_conv  <= LengthOfConv-1 )
			 begin
				CONV_oDatareg[index_conv] = (CONV_iData0reg[index_conv]*1)+(CONV_iData1reg[index_conv]*(-1));
				CONV_i0[index_conv] = CONV_iData0reg[index_conv]*(1);
				CONV_i1[index_conv] = CONV_iData1reg[index_conv]*(-1);
				index_conv <= index_conv + 8'b1;
			 end
					
			if(index_conv  == LengthOfConv )
			begin
				index_conv <= 8'b0; 
				
				state <= nextstate;
				nextstate  <= ClrState;
			end
		end	 
		 if (state == OutState) // ��������� ������
		begin
			CONV_oData <= CONV_oDatareg[index_output];
			index_output <= index_output + 8'b1;
			 if (index_output == LengthOfConv * 2-2) // ��� ���� ������ �������� �����, �� ����� ������� ������ �� �������, ������� ����� 0 (������ ��� �� ��� ��������)
			begin
				 index_output <= 8'b0; // ��-�� ������������� �������������� ������������ ����� ������ ���� �� 0 �� LengthOfConv * 2
				state <= nextstate;
				nextstate  <= InState;
			end			
		end 
		 if (state == ClrState) // �������� ���������
		begin
			 CONV_oData <= 0; // ����� �������������� �� ��������, �� ������ ����� 0
			CONV_oDatareg[index_clr] = 0;
			index_clr<= index_clr + 8'b1;
			if(index_clr  == LengthOfConv * 2 - 1 )
			begin
				index_clr <= 8'b0;  
				state <= nextstate;
				nextstate  <= ConvState;
			end			
		end 
	end
end
endmodule