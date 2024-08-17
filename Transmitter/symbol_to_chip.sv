//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description : transforming the symbol 4-bits to chip 32-bits 
/******************************************************************/
module symbol_to_chip#(parameter SYMBOL_WIDTH = 4 , CHIP_WIDTH = 32 , NUM_OF_CHIPS = 16)  
(
input logic								i_clk,
input logic								i_rst_n,
input logic 	[SYMBOL_WIDTH-1:0]		i_symbol,
input logic								i_symbol_valid,

output logic							o_chip,
output logic							o_chip_valid,
output logic 							o_read
);

/***********************************************/
/****************internal signals***************/
/**********************************************/


logic	[CHIP_WIDTH-1:0]	chip_values [NUM_OF_CHIPS-1:0]; //memory to hold chip values

logic	[$clog2(CHIP_WIDTH)-1:0] 	r_bit_counter; //counter to serializing chip to output

logic 	[SYMBOL_WIDTH-1:0]			r_symbol;	   //register to hold the o_symbol 

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

//registering the o_symbol to be used at generation
always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		r_symbol <= 'd0;
	end
	else if (i_symbol_valid)
	begin
		r_symbol <= i_symbol;
	end
end	

//the counter start to s_ones_counter when input o_symbol is valid and continue to s_ones_counter till it reach the chip width then reset
always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		r_bit_counter <= 'd0;
	end
	else if (i_symbol_valid || ((r_bit_counter!=CHIP_WIDTH-1)&& |r_bit_counter))
	begin
		r_bit_counter <= r_bit_counter + 'd1;
	end
	else if(r_bit_counter == CHIP_WIDTH-'d1)
	begin
		r_bit_counter <= 'd0;	
	end	
end
	
//once the i_symbol_valid flag asserted the first bit of chip will be at output (at same cycle) then the rest of chip bits will follow it
always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		o_chip <= 'd0;
		o_chip_valid <= 1'b0;
	end	
	else if ((r_bit_counter!=CHIP_WIDTH)&& |r_bit_counter)
	begin
		o_chip <= chip_values[r_symbol][r_bit_counter];
		o_chip_valid <= 1'b1;
	end
	else if (i_symbol_valid)
	begin
		o_chip <= chip_values[i_symbol][0];
		o_chip_valid <= 1'b1;
	end
	else
	begin
		o_chip <= 'd0;
		o_chip_valid <= 1'b0;
	end
end

assign o_read = (r_bit_counter==31);

endmodule	