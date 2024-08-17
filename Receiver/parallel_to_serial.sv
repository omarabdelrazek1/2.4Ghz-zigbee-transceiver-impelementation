//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description :transformng the I-Q parallel streams to 1 serial stream 
/******************************************************************/
module parallel_to_serial 
(
input logic  i_clk,
input logic  i_rst_n,
input logic  i_I_stream,
input logic  i_Q_stream,
input logic  i_I_stream_valid,
input logic  i_Q_stream_valid,
output logic o_serial_stream,
output logic o_serial_stream_valid,
output logic o_read
);

logic s_Q , s_Q_bar;

assign o_read = s_Q; //read signalto the fifo holding input samples

//creating complement signals to help passing the correct serial stream to output odd>>even>>odd>>even ... 1>2>3>4>...
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

always_comb
begin
	o_serial_stream = (i_I_stream_valid && i_I_stream) || (i_Q_stream_valid && i_Q_stream);  //serial stream assigning
    o_serial_stream_valid = i_I_stream_valid || i_Q_stream_valid; //serial stream valid will be valid when any of Q or I streams valid
end

endmodule