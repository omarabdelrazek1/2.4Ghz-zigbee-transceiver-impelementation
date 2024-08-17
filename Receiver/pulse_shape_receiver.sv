//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description : pulse shape receiver which transform each 10 Consecutive
//              bits to 1 or 0 
/******************************************************************/
module pulse_shape_receiver 
(
input logic         i_clk,
input logic         i_rst_n,
input logic         i_pulse_valid,
input logic [9:0]   i_pulse_shaped,
output logic        o_stream,
output logic        o_stream_valid           
);

logic [3:0] r_counter;
logic [9:0] r_pulse_received [9:0];
//memory to hold the values
logic [9:0] mem_1 [9:0]; 
logic [9:0] mem_0 [9:0]; 

logic [9:0] flag_1; 
logic [9:0] flag_0; 

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

//counter to count received pulses to decide if result bit 1 or 0
always_ff@(posedge i_clk , negedge i_rst_n)
begin
    if(!i_rst_n)
    begin
        r_counter <= 'd0;
    end
    else if (r_counter == 'd9)
    begin
        r_counter <= 'd0;
    end   
    else if (i_pulse_valid)
    begin
        r_counter<= r_counter +'d1;
    end
     

end

//generating the 10 receive pulses too decide which bit will be on the output
always_ff@(posedge i_clk , negedge i_rst_n)
begin
    if(!i_rst_n)
    begin
        for(int i =0 ; i<10 ; i++)
        begin
            r_pulse_received[i] <='d0;    
        end
    end
    else if (r_counter=='d0)
    begin
        for(int i =0 ; i<10 ; i++)
        begin
            r_pulse_received[i] <='d0;    
        end
    end
    else if (i_pulse_valid)
    begin
        r_pulse_received[r_counter] <= i_pulse_shaped;
    end
end

//generatin 10 flags for each 0 and one to decide 
always_comb
begin
    for(int i = 0; i<10 ; i++)
    begin
        flag_0[i] = (r_pulse_received[i]==mem_0[i]);
        flag_1[i] = (r_pulse_received[i]==mem_1[i]);
    end
end

//deciding the output 
always_comb
begin
    if(&flag_1 && r_counter==0)
    begin
        o_stream = 1'b1;
        o_stream_valid = 1'b1;
    end
    else if (&flag_0 && r_counter==0 )
    begin
        o_stream = 1'b0;
        o_stream_valid = 1'b1;
    end
    else
    begin
        o_stream = 1'b0;
        o_stream_valid = 1'b0;
    end   
end     


endmodule