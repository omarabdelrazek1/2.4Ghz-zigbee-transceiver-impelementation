module zigbee_transceiver#(parameter SYMBOL_WIDTH= 4 , CHIP_WIDTH = 32 , NUM_OF_CHIPS= 16 )
(
input logic			i_clk_bit_to_symbol,
input logic			i_clk_symbol_to_chip,
input logic			i_clk_serial_to_parallel,
input logic			i_clk_pulse_shabing,
input logic         i_rst_n,
input logic         i_Q_pulse_valid,
input logic [9:0]   i_Q_pulse_shaped,
input logic         i_I_pulse_valid,
input logic [9:0]   i_I_pulse_shaped,
input logic			i_valid_in,
input logic			i_data,

output logic[9:0]	o_Q_pulse_shaped,
output logic		o_Q_pulse_valid,
output logic[9:0]	o_I_pulse_shaped,
output logic		o_I_pulse_valid
output logic        o_bit_stream,
output logic        o_stream_valid ,
output logic        o_hold_stream 
);


zigbee_transmitter #
(
.SYMBOL_WIDTH (SYMBOL_WIDTH) ,     
.CHIP_WIDTH   (CHIP_WIDTH) , 
.NUM_OF_CHIPS (NUM_OF_CHIPS)      
)
u_transmitter
(
.i_clk_bit_to_symbol        (i_clk_bit_to_symbol     ),             
.i_clk_symbol_to_chip       (i_clk_symbol_to_chip    ),                     
.i_clk_serial_to_parallel   (i_clk_serial_to_parallel),                                 
.i_clk_pulse_shabing        (i_clk_pulse_shabing     ),                                 
.i_rst_n                    (i_rst_n                 ),                                                       
.i_valid_in                 (i_valid_in              ),                         
.i_data                     (i_data                  ),                     
.o_Q_pulse_shaped           (o_Q_pulse_shaped        ),                         
.o_Q_pulse_valid            (o_Q_pulse_valid         ),                                                    
.o_I_pulse_shaped           (o_I_pulse_shaped        ),                                                                
.o_I_pulse_valid            (o_I_pulse_valid         ),                                 
.o_hold_stream              (o_hold_stream           )                
);

zigbee_receiver u_I_shaping_receiver
(
.i_clk_symbol_to_bit      (i_clk_symbol_to_bit     )      
.i_clk_chip_to_symbol     (i_clk_chip_to_symbol    )              
.i_clk_parallel_to_series (i_clk_parallel_to_series)                  
.i_clk_pulse_shabing      (i_clk_pulse_shabing     )                  
.i_rst_n                  (i_rst_n                 )              
.i_Q_pulse_valid          (i_Q_pulse_valid         )                      
.i_Q_pulse_shaped         (i_Q_pulse_shaped        )              
.i_I_pulse_valid          (i_I_pulse_valid         )                      
.i_I_pulse_shaped         (i_I_pulse_shaped        )                      
.o_bit_stream             (o_bit_stream            )                          
.o_stream_valid           (o_stream_valid          )                    
);
endmodule