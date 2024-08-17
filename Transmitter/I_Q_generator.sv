//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description : I-Q streams generation
/******************************************************************/
module I_Q_generator#(parameter CHIP_WIDTH = 32 )  
(
input logic 		i_clk,
input logic 		i_rst_n,
input logic 		i_stream,
input logic 		i_stream_valid,
output logic 		o_Q_stream,
output logic 		o_Q_stream_valid,
output logic 		o_I_stream,
output logic 		o_I_stream_valid
);

logic s_Q , s_Q_bar;

//generating complementing signals to help selecting I-Q bits each one at its turn
always_ff@(posedge i_clk , negedge i_rst_n)
begin
	if(!i_rst_n)
	begin
		s_Q <= 'd0;
		s_Q_bar<= 'd1;
	end
	else
	begin
		s_Q <= s_Q_bar;
		s_Q_bar <= s_Q;
	end
end

//generating the streams and their valid flags
always_comb
begin
	o_I_stream_valid = i_stream_valid && s_Q;
	o_Q_stream_valid = i_stream_valid && s_Q_bar;
	o_I_stream= i_stream && s_Q;
	o_Q_stream = i_stream && s_Q_bar;
end


endmodule
