module zigbee_transmitter #(parameter SYMBOL_WIDTH= 4 , CHIP_WIDTH = 32 , NUM_OF_CHIPS= 16 )
(
input logic			i_clk_bit_to_symbol,
input logic			i_clk_symbol_to_chip,
input logic			i_clk_serial_to_parallel,
input logic			i_clk_pulse_shabing,
input logic			i_rst_n,
input logic			i_valid_in,
input logic			i_data,
output logic[9:0]	o_Q_pulse_shaped,
output logic		o_Q_pulse_valid,
output logic[9:0]	o_I_pulse_shaped,
output logic		o_I_pulse_valid,
output logic        o_hold_stream
);

/***********************************************/
/****************internal signals***************/
/**********************************************/
logic	[SYMBOL_WIDTH-1:0]		s_symbol;
logic							s_symbol_valid;
logic							s_chip;
logic							s_chip_valid;
logic							s_Q_stream;
logic							s_Q_stream_valid;
logic							s_I_stream;
logic							s_I_stream_valid;

logic [9:0]s_Q_pulse_shaped ;
logic s_Q_pulse_valid;

logic s_I_empty, s_Q_empty;


logic [4:0] s_r_fifo_data; 
logic s_read;
logic s_Q_pulse_read,s_I_pulse_read;
logic [1:0] s_data_to_I_shaper,s_data_to_Q_shaper;

logic s_symbols_fifo_full , s_I_fifo_full , s_Q_fifo_full;

assign o_hold_stream = s_symbols_fifo_full | s_I_fifo_full | s_Q_fifo_full;

bit_to_symbol
#(
.SYMBOL_WIDTH(SYMBOL_WIDTH)
)
u_bit_to_symbol
(
.i_clk		   (i_clk_bit_to_symbol) ,
.i_rst_n       (i_rst_n)             ,
.i_valid_in    (i_valid_in)          ,
.i_data        (i_data)              ,
.o_symbol      (s_symbol)            ,
.o_symbol_valid(s_symbol_valid)
);

Sync_fifo #
(
.D_SIZE        (5)  ,                      
.F_DEPTH       (2)  ,                        
.ADDRESS_SIZE  (1)         
)    
    u_fifo_sym_to_chip
(
.i_w_clk      (i_clk_bit_to_symbol)       ,
.i_w_rstn     (i_rst_n)                   ,    
.i_w_inc      (s_symbol_valid)            ,
.i_r_clk      (i_clk_symbol_to_chip)      ,                      
.i_r_rstn     (i_rst_n)                   ,    
.i_r_inc      (s_read)                    , 
.i_w_data     ({s_symbol_valid,s_symbol}) ,                  
.o_r_data     (s_r_fifo_data)             ,              
.o_full       (s_symbols_fifo_full)                      ,
.o_empty      ()                         
);

symbol_to_chip
#(
.SYMBOL_WIDTH(SYMBOL_WIDTH) ,
.CHIP_WIDTH  (CHIP_WIDTH  ) ,
.NUM_OF_CHIPS(NUM_OF_CHIPS) 
)
u_symbol_to_chip
(
.i_clk			(i_clk_symbol_to_chip)	,
.i_rst_n		(i_rst_n),
.i_symbol		(s_r_fifo_data[3:0]),
.i_symbol_valid	(s_r_fifo_data[4]),
.o_chip			(s_chip),
.o_chip_valid	(s_chip_valid)	,
.o_read         (s_read)
);


I_Q_generator
#(
.CHIP_WIDTH(CHIP_WIDTH)
)
u_I_Q_generator
(
.i_clk				(i_clk_serial_to_parallel) ,
.i_rst_n            (i_rst_n)                  ,
.i_stream           (s_chip)                   ,
.i_stream_valid     (s_chip_valid)             ,
.o_Q_stream         (s_Q_stream)               ,
.o_Q_stream_valid   (s_Q_stream_valid)         ,
.o_I_stream         (s_I_stream)               ,
.o_I_stream_valid   (s_I_stream_valid)
);

Sync_fifo #
(
.D_SIZE        (2)  ,                      
.F_DEPTH       ('d2)  ,                        
.ADDRESS_SIZE  (1)         
)    
    u_fifo_Q_gen
(
.i_w_clk      (i_clk_serial_to_parallel)       ,
.i_w_rstn     (i_rst_n)                   ,    
.i_w_inc      (1)            ,
.i_r_clk      (i_clk_pulse_shabing)      ,                      
.i_r_rstn     (i_rst_n)                   ,    
.i_r_inc      (s_Q_pulse_read)                    , 
.i_w_data     ({s_Q_stream_valid,s_Q_stream}) ,                  
.o_r_data     (s_data_to_Q_shaper)             ,              
.o_full       (s_Q_fifo_full)                      ,
.o_empty      (s_Q_empty)                         
);


Sync_fifo #
(
.D_SIZE        (2)  ,                      
.F_DEPTH       ('d2 ) ,                        
.ADDRESS_SIZE  (1)         
)    
    u_fifo_I_gen
(
.i_w_clk      (i_clk_serial_to_parallel)       ,
.i_w_rstn     (i_rst_n)                   ,    
.i_w_inc      (1)            ,
.i_r_clk      (i_clk_pulse_shabing)      ,                      
.i_r_rstn     (i_rst_n)                   ,    
.i_r_inc      (s_I_pulse_read)                    , 
.i_w_data     ({s_I_stream_valid,s_I_stream}) ,                  
.o_r_data     (s_data_to_I_shaper)             ,              
.o_full       (s_I_fifo_full)                      ,
.o_empty      (s_I_empty)                         
);

pulse_shaping u_Q_pulse_shaper
(
.i_clk          (i_clk_pulse_shabing)  ,
.i_rst_n        (i_rst_n)              ,
.i_stream       (s_data_to_Q_shaper[0])           ,
.i_stream_valid (s_data_to_Q_shaper[1]&& !s_Q_empty)     ,
.o_pulse_shaped (o_Q_pulse_shaped)     ,
.o_pulse_valid  (o_Q_pulse_valid),
.o_read         (s_Q_pulse_read)
);



pulse_shaping u_I_pulse_shaper
(
.i_clk          (i_clk_pulse_shabing),
.i_rst_n        (i_rst_n)            ,
.i_stream       (s_data_to_I_shaper[0])         ,
.i_stream_valid (s_data_to_I_shaper[1]&& !s_I_empty)   ,
.o_pulse_shaped (o_I_pulse_shaped)   ,
.o_pulse_valid  (o_I_pulse_valid),
.o_read         (s_I_pulse_read)
);


endmodule
