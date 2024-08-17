//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description :transforming the eceived chips to the nearest mapped symbol
/******************************************************************/
module chip_to_symbol 
(
input logic         i_clk,
input logic         i_rst_n,
input logic         i_stream,
input logic         i_stream_valid,
output logic [3:0]  o_symbol,
output logic        o_symbol_valid       
);

logic [4:0] r_bit_counter;

logic [31:0] r_received_chip;

logic [5:0] s_ones_counter[15:0];


logic	[31:0]	chip_values [15:0]; //memory to hold chip values

//loading memory with chip_values
initial 
begin
	//$readmemb("C:\Users\omar\Desktop\chip_values",chip_values);
	chip_values[0] 		=  32'b11011001110000110101001000101110;
	chip_values[8] 		=  32'b11101101100111000011010100100010;
	chip_values[4] 		=  32'b00101110110110011100001101010010;
	chip_values[12] 	=  32'b00100010111011011001110000110101;
	chip_values[2] 		=  32'b01010010001011101101100111000011;
	chip_values[10] 	=  32'b00110101001000101110110110011100;
	chip_values[6] 		=  32'b11000011010100100010111011011001;
	chip_values[14] 	=  32'b10011100001101010010001011101101;
	chip_values[1] 		=  32'b10001100100101100000011101111011;
	chip_values[9] 		=  32'b10111000110010010110000001110111;
	chip_values[5] 		=  32'b01111011100011001001011000000111;
	chip_values[13] 	=  32'b01110111101110001100100101100000;
	chip_values[3]		=  32'b00000111011110111000110010010110;
	chip_values[11]		=  32'b01100000011101111011100011001001;
	chip_values[7] 		=  32'b10010110000001110111101110001100;
	chip_values[15] 	=  32'b11001001011000000111011110111000;
end

//counter to move around the bits
always_ff@(posedge i_clk , negedge i_rst_n)
begin
    if(!i_rst_n)
    begin
        r_bit_counter <= 'd0;
    end
    else if(r_bit_counter=='d31) 
    begin
        r_bit_counter <= 'd0;
    end
    else if(i_stream_valid)
    begin
        r_bit_counter <= r_bit_counter + 'd1;
    end
end

//collecting the chip and then deciding which closest symbol to be on the output
always_ff@(posedge i_clk , negedge i_rst_n)
begin
    if(!i_rst_n)
    begin
        r_received_chip <= 'd0;
		for(int i = 0 ; i<16 ; i++)
        begin
			s_ones_counter[i] <= 'd0;
		end
    end
	else if (r_bit_counter==31)
	begin
		for(int i = 0 ; i<16 ; i++)
        begin
			s_ones_counter[i] <= 'd0;
		end
	end
    else if(i_stream_valid)
    begin
        r_received_chip[r_bit_counter]<= i_stream;
        for(int i = 0 ; i<16 ; i++)
        begin
            s_ones_counter[i] <= s_ones_counter[i] + (i_stream ~^ chip_values[i][r_bit_counter]);
        end
    end    
end

////////////////////comb always compares the number of ones at each result and mapping the biggest match ( higher number of ones) to its o_symbol //////////////////////////////
	always@(*)
		begin
			if((s_ones_counter[0]>=s_ones_counter[1]) && (s_ones_counter[0]>=s_ones_counter[2]) && (s_ones_counter[0]>=s_ones_counter[3]) && (s_ones_counter[0]>=s_ones_counter[4]) && (s_ones_counter[0]>=s_ones_counter[5]) && (s_ones_counter[0]>=s_ones_counter[6]) && (s_ones_counter[0]>=s_ones_counter[7]) && (s_ones_counter[0]>=s_ones_counter[8]) && (s_ones_counter[0]>=s_ones_counter[9]) && (s_ones_counter[0]>=s_ones_counter[10]) && (s_ones_counter[0]>=s_ones_counter[11]) && (s_ones_counter[0]>=s_ones_counter[12]) && (s_ones_counter[0]>=s_ones_counter[13]) && (s_ones_counter[0]>=s_ones_counter[14]) && (s_ones_counter[0]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd0;
			end
			else if((s_ones_counter[1]>=s_ones_counter[0]) && (s_ones_counter[1]>=s_ones_counter[2]) && (s_ones_counter[1]>=s_ones_counter[3]) && (s_ones_counter[1]>=s_ones_counter[4]) && (s_ones_counter[1]>=s_ones_counter[5]) && (s_ones_counter[1]>=s_ones_counter[6]) && (s_ones_counter[1]>=s_ones_counter[7]) && (s_ones_counter[1]>=s_ones_counter[8]) && (s_ones_counter[1]>=s_ones_counter[9]) && (s_ones_counter[1]>=s_ones_counter[10]) && (s_ones_counter[1]>=s_ones_counter[11]) && (s_ones_counter[1]>=s_ones_counter[12]) && (s_ones_counter[1]>=s_ones_counter[13]) && (s_ones_counter[1]>=s_ones_counter[14]) && (s_ones_counter[1]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd1;
			end
			else if((s_ones_counter[2]>=s_ones_counter[0]) && (s_ones_counter[2]>=s_ones_counter[1]) && (s_ones_counter[2]>=s_ones_counter[3]) && (s_ones_counter[2]>=s_ones_counter[4]) && (s_ones_counter[2]>=s_ones_counter[5]) && (s_ones_counter[2]>=s_ones_counter[6]) && (s_ones_counter[2]>=s_ones_counter[7]) && (s_ones_counter[2]>=s_ones_counter[8]) && (s_ones_counter[2]>=s_ones_counter[9]) && (s_ones_counter[2]>=s_ones_counter[10]) && (s_ones_counter[2]>=s_ones_counter[11]) && (s_ones_counter[2]>=s_ones_counter[12]) && (s_ones_counter[2]>=s_ones_counter[13]) && (s_ones_counter[2]>=s_ones_counter[14]) && (s_ones_counter[2]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd2;
			end
			else if((s_ones_counter[3]>=s_ones_counter[0]) && (s_ones_counter[3]>=s_ones_counter[1]) && (s_ones_counter[3]>=s_ones_counter[2]) && (s_ones_counter[3]>=s_ones_counter[4]) && (s_ones_counter[3]>=s_ones_counter[5]) && (s_ones_counter[3]>=s_ones_counter[6]) && (s_ones_counter[3]>=s_ones_counter[7]) && (s_ones_counter[3]>=s_ones_counter[8]) && (s_ones_counter[3]>=s_ones_counter[9]) && (s_ones_counter[3]>=s_ones_counter[10]) && (s_ones_counter[3]>=s_ones_counter[11]) && (s_ones_counter[3]>=s_ones_counter[12]) && (s_ones_counter[3]>=s_ones_counter[13]) && (s_ones_counter[3]>=s_ones_counter[14]) && (s_ones_counter[3]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd3;
			end
			else if((s_ones_counter[4]>=s_ones_counter[0]) && (s_ones_counter[4]>=s_ones_counter[1]) && (s_ones_counter[4]>=s_ones_counter[2]) && (s_ones_counter[4]>=s_ones_counter[3]) && (s_ones_counter[4]>=s_ones_counter[5]) && (s_ones_counter[4]>=s_ones_counter[6]) && (s_ones_counter[4]>=s_ones_counter[7]) && (s_ones_counter[4]>=s_ones_counter[8]) && (s_ones_counter[4]>=s_ones_counter[9]) && (s_ones_counter[4]>=s_ones_counter[10]) && (s_ones_counter[4]>=s_ones_counter[11]) && (s_ones_counter[4]>=s_ones_counter[12]) && (s_ones_counter[4]>=s_ones_counter[13]) && (s_ones_counter[4]>=s_ones_counter[14]) && (s_ones_counter[4]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd4;
			end
			else if((s_ones_counter[5]>=s_ones_counter[0]) && (s_ones_counter[5]>=s_ones_counter[1]) && (s_ones_counter[5]>=s_ones_counter[2]) && (s_ones_counter[5]>=s_ones_counter[3]) && (s_ones_counter[5]>=s_ones_counter[4]) && (s_ones_counter[5]>=s_ones_counter[6]) && (s_ones_counter[5]>=s_ones_counter[7]) && (s_ones_counter[5]>=s_ones_counter[8]) && (s_ones_counter[5]>=s_ones_counter[9]) && (s_ones_counter[5]>=s_ones_counter[10]) && (s_ones_counter[5]>=s_ones_counter[11]) && (s_ones_counter[5]>=s_ones_counter[12]) && (s_ones_counter[5]>=s_ones_counter[13]) && (s_ones_counter[5]>=s_ones_counter[14]) && (s_ones_counter[5]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd5;
			end
			else if((s_ones_counter[6]>=s_ones_counter[0]) && (s_ones_counter[6]>=s_ones_counter[1]) && (s_ones_counter[6]>=s_ones_counter[2]) && (s_ones_counter[6]>=s_ones_counter[3]) && (s_ones_counter[6]>=s_ones_counter[4]) && (s_ones_counter[6]>=s_ones_counter[5]) && (s_ones_counter[6]>=s_ones_counter[7]) && (s_ones_counter[6]>=s_ones_counter[8]) && (s_ones_counter[6]>=s_ones_counter[9]) && (s_ones_counter[6]>=s_ones_counter[10]) && (s_ones_counter[6]>=s_ones_counter[11]) && (s_ones_counter[6]>=s_ones_counter[12]) && (s_ones_counter[6]>=s_ones_counter[13]) && (s_ones_counter[6]>=s_ones_counter[14]) && (s_ones_counter[6]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd6;
			end
			else if((s_ones_counter[7]>=s_ones_counter[0]) && (s_ones_counter[7]>=s_ones_counter[1]) && (s_ones_counter[7]>=s_ones_counter[2]) && (s_ones_counter[7]>=s_ones_counter[3]) && (s_ones_counter[7]>=s_ones_counter[4]) && (s_ones_counter[7]>=s_ones_counter[5]) && (s_ones_counter[7]>=s_ones_counter[6]) && (s_ones_counter[7]>=s_ones_counter[8]) && (s_ones_counter[7]>=s_ones_counter[9]) && (s_ones_counter[7]>=s_ones_counter[10]) && (s_ones_counter[7]>=s_ones_counter[11]) && (s_ones_counter[7]>=s_ones_counter[12]) && (s_ones_counter[7]>=s_ones_counter[13]) && (s_ones_counter[7]>=s_ones_counter[14]) && (s_ones_counter[7]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd7;
			end
			else if((s_ones_counter[8]>=s_ones_counter[0]) && (s_ones_counter[8]>=s_ones_counter[1]) && (s_ones_counter[8]>=s_ones_counter[2]) && (s_ones_counter[8]>=s_ones_counter[3]) && (s_ones_counter[8]>=s_ones_counter[4]) && (s_ones_counter[8]>=s_ones_counter[5]) && (s_ones_counter[8]>=s_ones_counter[6]) && (s_ones_counter[8]>=s_ones_counter[7]) && (s_ones_counter[8]>=s_ones_counter[9]) && (s_ones_counter[8]>=s_ones_counter[10]) && (s_ones_counter[8]>=s_ones_counter[11]) && (s_ones_counter[8]>=s_ones_counter[12]) && (s_ones_counter[8]>=s_ones_counter[13]) && (s_ones_counter[8]>=s_ones_counter[14]) && (s_ones_counter[8]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd8;
			end
			else if((s_ones_counter[9]>=s_ones_counter[0]) && (s_ones_counter[9]>=s_ones_counter[1]) && (s_ones_counter[9]>=s_ones_counter[2]) && (s_ones_counter[9]>=s_ones_counter[3]) && (s_ones_counter[9]>=s_ones_counter[4]) && (s_ones_counter[9]>=s_ones_counter[5]) && (s_ones_counter[9]>=s_ones_counter[6]) && (s_ones_counter[9]>=s_ones_counter[7]) && (s_ones_counter[9]>=s_ones_counter[8]) && (s_ones_counter[9]>=s_ones_counter[10]) && (s_ones_counter[9]>=s_ones_counter[11]) && (s_ones_counter[9]>=s_ones_counter[12]) && (s_ones_counter[9]>=s_ones_counter[13]) && (s_ones_counter[9]>=s_ones_counter[14]) && (s_ones_counter[9]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd9;
			end
			else if((s_ones_counter[10]>=s_ones_counter[0]) && (s_ones_counter[10]>=s_ones_counter[1]) && (s_ones_counter[10]>=s_ones_counter[2]) && (s_ones_counter[10]>=s_ones_counter[3]) && (s_ones_counter[10]>=s_ones_counter[4]) && (s_ones_counter[10]>=s_ones_counter[5]) && (s_ones_counter[10]>=s_ones_counter[6]) && (s_ones_counter[10]>=s_ones_counter[7]) && (s_ones_counter[10]>=s_ones_counter[8]) && (s_ones_counter[10]>=s_ones_counter[9]) && (s_ones_counter[10]>=s_ones_counter[11]) && (s_ones_counter[10]>=s_ones_counter[12]) && (s_ones_counter[10]>=s_ones_counter[13]) && (s_ones_counter[10]>=s_ones_counter[14]) && (s_ones_counter[10]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd10;
			end
			else if((s_ones_counter[11]>=s_ones_counter[0]) && (s_ones_counter[11]>=s_ones_counter[1]) && (s_ones_counter[11]>=s_ones_counter[2]) && (s_ones_counter[11]>=s_ones_counter[3]) && (s_ones_counter[11]>=s_ones_counter[4]) && (s_ones_counter[11]>=s_ones_counter[5]) && (s_ones_counter[11]>=s_ones_counter[6]) && (s_ones_counter[11]>=s_ones_counter[7]) && (s_ones_counter[11]>=s_ones_counter[8]) && (s_ones_counter[11]>=s_ones_counter[9]) && (s_ones_counter[11]>=s_ones_counter[10]) && (s_ones_counter[11]>=s_ones_counter[12]) && (s_ones_counter[11]>=s_ones_counter[13]) && (s_ones_counter[11]>=s_ones_counter[14]) && (s_ones_counter[11]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd11;
			end
			else if((s_ones_counter[12]>=s_ones_counter[0]) && (s_ones_counter[12]>=s_ones_counter[1]) && (s_ones_counter[12]>=s_ones_counter[2]) && (s_ones_counter[12]>=s_ones_counter[3]) && (s_ones_counter[12]>=s_ones_counter[4]) && (s_ones_counter[12]>=s_ones_counter[5]) && (s_ones_counter[12]>=s_ones_counter[6]) && (s_ones_counter[12]>=s_ones_counter[7]) && (s_ones_counter[12]>=s_ones_counter[8]) && (s_ones_counter[12]>=s_ones_counter[9]) && (s_ones_counter[12]>=s_ones_counter[10]) && (s_ones_counter[12]>=s_ones_counter[11]) && (s_ones_counter[12]>=s_ones_counter[13]) && (s_ones_counter[12]>=s_ones_counter[14]) && (s_ones_counter[12]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd12;
			end
			else if((s_ones_counter[13]>=s_ones_counter[0]) && (s_ones_counter[13]>=s_ones_counter[1]) && (s_ones_counter[13]>=s_ones_counter[2]) && (s_ones_counter[13]>=s_ones_counter[3]) && (s_ones_counter[13]>=s_ones_counter[4]) && (s_ones_counter[13]>=s_ones_counter[5]) && (s_ones_counter[13]>=s_ones_counter[6]) && (s_ones_counter[13]>=s_ones_counter[7]) && (s_ones_counter[13]>=s_ones_counter[8]) && (s_ones_counter[13]>=s_ones_counter[9]) && (s_ones_counter[13]>=s_ones_counter[10]) && (s_ones_counter[13]>=s_ones_counter[11]) && (s_ones_counter[13]>=s_ones_counter[12]) && (s_ones_counter[13]>=s_ones_counter[15]) && (s_ones_counter[13]>=s_ones_counter[14]) ) 
			begin
				o_symbol = 'd13;
			end
			else if((s_ones_counter[14]>=s_ones_counter[0]) && (s_ones_counter[14]>=s_ones_counter[1]) && (s_ones_counter[14]>=s_ones_counter[2]) && (s_ones_counter[14]>=s_ones_counter[3]) && (s_ones_counter[14]>=s_ones_counter[4]) && (s_ones_counter[14]>=s_ones_counter[5]) && (s_ones_counter[14]>=s_ones_counter[6]) && (s_ones_counter[14]>=s_ones_counter[7]) && (s_ones_counter[14]>=s_ones_counter[8]) && (s_ones_counter[14]>=s_ones_counter[9]) && (s_ones_counter[14]>=s_ones_counter[10]) && (s_ones_counter[14]>=s_ones_counter[11]) && (s_ones_counter[14]>=s_ones_counter[12]) && (s_ones_counter[14]>=s_ones_counter[13]) && (s_ones_counter[14]>=s_ones_counter[15]) ) 
			begin
				o_symbol = 'd14;
			end
			else
				begin
				o_symbol = 'd15;
				end
			end

assign o_symbol_valid = (r_bit_counter==31); //symbol validation


endmodule