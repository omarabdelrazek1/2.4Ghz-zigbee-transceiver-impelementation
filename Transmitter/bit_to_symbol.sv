//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description :take each 4-bits(consecutive) and generate 1 4-bit symbol
/******************************************************************/
module bit_to_symbol #(parameter SYMBOL_WIDTH = 15) 
(
input logic							i_clk,
input logic 						i_rst_n,
input logic 						i_valid_in,
input logic							i_data,
output logic[SYMBOL_WIDTH-1:0]		o_symbol,
output logic						o_symbol_valid
);

/***********************************************/
/****************internal signals***************/
/**********************************************/
logic [$clog2(SYMBOL_WIDTH)-1:0] r_counter;

//counting number of cycles equal to o_symbol width while i_valid_in asserted and then reset to repeat the s_ones_counter
always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
	r_counter <= 'd0;
	end
	else if (r_counter == SYMBOL_WIDTH-1)
	begin
	r_counter <= 'd0;
	end
	else if(i_valid_in)
	begin
	r_counter <= r_counter + 2'd1;
	end
	
end

//generating the o_symbol and asserting out valid when generation is done

always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		o_symbol_valid <= 1'b0;
	end
	if(r_counter == SYMBOL_WIDTH-1)
	begin
		o_symbol_valid <= 1'b1;
	end
	else
	begin
		o_symbol_valid <= 1'b0;
	end
end

always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		o_symbol <= 'd0;
	end
	else if(i_valid_in)
	begin
		o_symbol <= {o_symbol[SYMBOL_WIDTH-2:0],i_data};
	end
end
endmodule	