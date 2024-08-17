//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description : transforming symbol to its mapped bits
/******************************************************************/
module symbol_to_bits 
(
input logic i_clk,
input logic i_rst_n,
input logic i_symbol_valid,
input logic [3:0] i_symbol,
output logic o_bit_stream,
output logic o_stream_valid,
output logic o_read
);


logic [3:0] r_symbol_carrier;

logic [2:0] r_counter;

logic s_count_flag;

always_ff@(posedge i_clk , negedge i_rst_n)
begin
    if(!i_rst_n)
    begin
        r_symbol_carrier<='d0;
    end
    else if (i_symbol_valid)
    begin
        r_symbol_carrier<= i_symbol;
    end
    else
    begin
        r_symbol_carrier <= {r_symbol_carrier[2:0],1'b0};
    end        
end

always_ff@(posedge i_clk , negedge i_rst_n)
begin
    if(!i_rst_n)
    begin
        r_counter <= 'd0;
        o_stream_valid <= 1'b0;
    end
    else if (r_counter == 'd4)
    begin
        r_counter <= 'd0;
        o_stream_valid <= 1'b0;
    end    
    else if (s_count_flag)
    begin
        r_counter <= r_counter + 'd1;
        o_stream_valid <= 1'b1;
    end    
end

assign o_bit_stream = r_symbol_carrier[3];

always_comb
begin
    if(r_counter != 'd0 || i_symbol_valid )
    begin
        s_count_flag = 1'b1;
    end    
    else
    begin
        s_count_flag = 1'b0;
    end
end

assign o_read = (r_counter ==0);

endmodule