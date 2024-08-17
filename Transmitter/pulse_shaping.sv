//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description : half sine wave pulse shaper , the most bit is the sign bit , 9 bits for the decimal point
/******************************************************************/
module pulse_shaping
(
input logic			i_clk,
input logic			i_rst_n,
input logic			i_stream,
input logic 		i_stream_valid,
output logic [9:0] 	o_pulse_shaped,
output logic 		o_pulse_valid,
output logic 		o_read
);


logic s_shaping_flag;
logic [3:0] r_counter;
logic r_stream;
logic r_stream_valid;

//memory to hold the values
logic [9:0] mem_1 [9:0]; 
logic [9:0] mem_0 [9:0]; 

initial 
begin

mem_1[0]	= 10'b0000000000 ;
mem_1[1]	= 10'b0001001111 ;
mem_1[2]	= 10'b0010010110 ;
mem_1[3]	= 10'b0011001111 ;
mem_1[4]	= 10'b0011110011 ;
mem_1[5]	= 10'b0100000000 ;
mem_1[6]	= 10'b0011110011 ;
mem_1[7]	= 10'b0011001111 ;
mem_1[8]	= 10'b0010010110 ;
mem_1[9]	= 10'b0001001111 ;

mem_0[0]	= 10'b0000000000 ;
mem_0[1]	= 10'b1001001111 ;
mem_0[2]	= 10'b1010010110 ;
mem_0[3]	= 10'b1011001111 ;
mem_0[4]	= 10'b1011110011 ;
mem_0[5]	= 10'b1100000000 ;
mem_0[6]	= 10'b1011110011 ;
mem_0[7]	= 10'b1011001111 ;
mem_0[8]	= 10'b1010010110 ;
mem_0[9]	= 10'b1001001111 ;
end


always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		o_pulse_shaped	<= 'd0;
		o_pulse_valid	<= 1'b0;	
	end
	else if(s_shaping_flag && r_stream)
	begin
		o_pulse_shaped	<= mem_1[r_counter];
		o_pulse_valid	<= 1'b1;
	end
	else if(s_shaping_flag  && ~r_stream) 
	begin
		o_pulse_shaped	<= mem_0[r_counter];
		o_pulse_valid	<= 1'b1;	
	end
	else
	begin
		o_pulse_shaped	<= 'd0;
		o_pulse_valid	<= 1'b0;	
	end
end

always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		r_stream <= 'd0;
	end
	else if (r_counter == 0 && i_stream_valid)
	begin
		r_stream <= i_stream;
	end
end	


always_comb
begin
	if(i_stream_valid || r_counter != 0)
	begin
		s_shaping_flag = 1'b1;
	end
	else
	begin
		s_shaping_flag = 1'b0;
	end
end

always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		r_counter <= 'd0;
	end
	else if (r_counter==9)
	begin
		r_counter <= 'd0;
	end
	else if (s_shaping_flag)
	begin
		r_counter<=r_counter+ 1'b1;
	end
end



assign o_read = (r_counter==0);
endmodule