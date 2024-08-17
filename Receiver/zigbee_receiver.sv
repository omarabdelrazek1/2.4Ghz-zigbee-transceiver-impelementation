//author : Omar Abdelrazek Sobh
/******************************************************************/
//Description : zigbee receiver holding all receiver main blocks
/******************************************************************/
module zigbee_receiver
(
input logic			i_clk_symbol_to_bit,
input logic			i_clk_chip_to_symbol,
input logic			i_clk_parallel_to_series,
input logic			i_clk_pulse_shabing,
input logic         i_rst_n,
input logic         i_Q_pulse_valid,
input logic [9:0]   i_Q_pulse_shaped,
input logic         i_I_pulse_valid,
input logic [9:0]   i_I_pulse_shaped,
output logic        o_bit_stream,
output logic        o_stream_valid  
);

//output from Q pulse shping receiver to parallel to serial block
logic        s_stream_Q_pulse_shaping_out;
logic        s_stream_Q_valid_pulse_shaping_out;
//output from I pulse shping receiver to parallel to serial block
logic        s_stream_I_pulse_shaping_out;
logic        s_stream_I_valid_pulse_shaping_out;

//output from parallel_to_serial >> chip_to_symbol
logic s_serial_stream;
logic s_serial_stream_valid;

//output from chip_to_sympol >> symbol_to_bit
logic [3:0] s_symbol;
logic       s_symbol_valid;

//output from Q & I fifos to serializer
logic [1:0] s_data_Q_to_serializer,s_data_I_to_serializer;
logic s_I_rec_pulse_empty,s_Q_rec_pulse_empty;

//output from serializser to Q&I fifos to read data
logic s_p2s_read_from_fifo;

//output from symbols_Fifo to sym_to_bit block
logic [4:0] s_sym_to_bit_from_fifo;
//output from symbols_Fifo to sym_to_bit block
logic s_empty_symbols_fifo;

//output from symbol_to_bit block to read from fifo
logic s_read_from_fifo;





/*********************************************************************/
/****************** Modules Instantiation ***************************/
/********************************************************************/

pulse_shape_receiver  u_Q_shaping_receiver 
(
.i_clk              (i_clk_pulse_shabing)                     ,      
.i_rst_n            (i_rst_n)                                 ,                
.i_pulse_valid      (i_Q_pulse_valid)                         ,                                  
.i_pulse_shaped     (i_Q_pulse_shaped)                        ,               
.o_stream           (s_stream_Q_pulse_shaping_out)            ,                               
.o_stream_valid     (s_stream_Q_valid_pulse_shaping_out)                                         
);

pulse_shape_receiver  u_I_shaping_receiver 
(
.i_clk              (i_clk_pulse_shabing)                    ,           
.i_rst_n            (i_rst_n)                                ,        
.i_pulse_valid      (i_I_pulse_valid)                        ,                      
.i_pulse_shaped     (i_I_pulse_shaped)                       ,                     
.o_stream           (s_stream_I_pulse_shaping_out)           ,                         
.o_stream_valid     ( s_stream_I_valid_pulse_shaping_out)                                   
);

Sync_fifo #
(
.D_SIZE        (2)  ,                      
.F_DEPTH       (2)  ,                        
.ADDRESS_SIZE  (1)         
)    
    u_fifo_Q_rec
(
.i_w_clk      (i_clk_pulse_shabing)                             ,
.i_w_rstn     (i_rst_n)                                         ,    
.i_w_inc      (s_stream_Q_valid_pulse_shaping_out)              ,
.i_r_clk      (i_clk_parallel_to_series)                        ,                      
.i_r_rstn     (i_rst_n)                                         ,    
.i_r_inc      (!s_p2s_read_from_fifo)                           , 
.i_w_data     ({s_stream_Q_valid_pulse_shaping_out,s_stream_Q_pulse_shaping_out}) ,                  
.o_r_data     (s_data_Q_to_serializer)                          ,              
.o_full       ()                                                ,
.o_empty      (s_Q_rec_pulse_empty)                         
);


Sync_fifo #
(
.D_SIZE        (2)  ,                      
.F_DEPTH       (2)  ,                        
.ADDRESS_SIZE  (1)         
)    
    u_fifo_I_rec
(
.i_w_clk      (i_clk_pulse_shabing)                             ,
.i_w_rstn     (i_rst_n)                                         ,    
.i_w_inc      (s_stream_I_valid_pulse_shaping_out)              ,
.i_r_clk      (i_clk_parallel_to_series)                        ,                      
.i_r_rstn     (i_rst_n)                                         ,    
.i_r_inc      (s_p2s_read_from_fifo)                            , 
.i_w_data     ({s_stream_I_valid_pulse_shaping_out,s_stream_I_pulse_shaping_out}) ,                  
.o_r_data     (s_data_I_to_serializer)                          ,              
.o_full       ()                                                ,
.o_empty      (s_I_rec_pulse_empty)                         
);


parallel_to_serial u_parallel_to_serial
(
.i_clk                       (i_clk_parallel_to_series)         ,                 
.i_rst_n                     (i_rst_n)                          ,                      
.i_I_stream                  (s_data_I_to_serializer[0])        ,                                      
.i_Q_stream                  (s_data_Q_to_serializer[0])        ,                           
.i_I_stream_valid            (s_data_I_to_serializer[1] && !s_I_rec_pulse_empty)  ,                                                   
.i_Q_stream_valid            (s_data_Q_to_serializer[1] && !s_Q_rec_pulse_empty)  ,                                                           
.o_serial_stream             (s_serial_stream)                  ,               
.o_serial_stream_valid       (s_serial_stream_valid)            ,
.o_read                      (s_p2s_read_from_fifo)         
);


chip_to_symbol u_chip_to_symbol
(
.i_clk               (i_clk_chip_to_symbol)   ,           
.i_rst_n             (i_rst_n)                ,          
.i_stream            (s_serial_stream)        ,             
.i_stream_valid      (s_serial_stream_valid)  ,                       
.o_symbol            (s_symbol)               ,                
.o_symbol_valid      (s_symbol_valid)                  
);

Sync_fifo #
(
.D_SIZE        (5)  ,                      
.F_DEPTH       (2)  ,                        
.ADDRESS_SIZE  (1)         
)    
    u_fifo_sym_to_bit
(
.i_w_clk      (i_clk_chip_to_symbol)       ,
.i_w_rstn     (i_rst_n)                    ,    
.i_w_inc      (s_symbol_valid)             ,
.i_r_clk      (i_clk_symbol_to_bit)        ,                      
.i_r_rstn     (i_rst_n)                    ,    
.i_r_inc      (s_read_from_fifo)           , 
.i_w_data     ({s_symbol_valid,s_symbol})  ,                  
.o_r_data     (s_sym_to_bit_from_fifo)     ,              
.o_full       ()                           ,
.o_empty      (s_empty_symbols_fifo)                         
);


symbol_to_bits u_symbol_to_bits 
(
.i_clk              (i_clk_symbol_to_bit),                    
.i_rst_n            (i_rst_n),            
.i_symbol_valid     (s_sym_to_bit_from_fifo[4]&& !s_empty_symbols_fifo),                        
.i_symbol           (s_sym_to_bit_from_fifo[3:0]),                
.o_bit_stream       (o_bit_stream),            
.o_stream_valid     (o_stream_valid),
.o_read             (s_read_from_fifo)                      
);


endmodule