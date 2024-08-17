module zigbee_transmitter_receiver_tb ();

logic			i_clk_bit_to_symbol = 0;
logic			i_clk_symbol_to_chip = 0;
logic			i_clk_serial_to_parallel = 0;
logic			i_clk_pulse_shabing = 0;
logic			i_rst_n;
logic			i_valid_in;
logic			i_data;
logic[9:0]	    s_Q_pulse_shaped;
logic		    s_Q_pulse_valid;
logic[9:0]	    s_I_pulse_shaped;
logic		    s_I_pulse_valid;

logic           o_bit_stream;
logic           o_stream_valid;  
logic           o_hold_stream;

/****************** number of input stream bits and should be devised by 4 *********************/
localparam NUM_OF_TESTS = 4000 ;


/************* defining clocks ************************/
always #2000 i_clk_bit_to_symbol = ~i_clk_bit_to_symbol;
always #500 i_clk_symbol_to_chip = ~i_clk_symbol_to_chip;
always #500 i_clk_serial_to_parallel = ~i_clk_serial_to_parallel;
always #50 i_clk_pulse_shabing = ~i_clk_pulse_shabing;
  
/******************* stimulus and output snooping queues ***************/
bit stim[$];
bit output_q[$];

/****************************** Test bench ******************************/
initial
begin
    i_valid_in = 1'b0;        
    i_rst_n = 1'b1;
    #3
    i_rst_n = 1'b0;
    #3
    i_rst_n = 1'b1; 
/******************* stimuluis injection and output snooping at same time using fork-join ***********/
    fork 
    begin
       inject();
    end   
    begin
        observe(); 
    end   
    join 

/***************************************** comparing queues to obtain the result *********************/
if(stim==output_q)
begin
    foreach(output_q[i])
$display("tranmited bit is %0b and received bit is %0d",stim[i],output_q[i]);
$display("/*************************************************************************************************************/");
$display("/*****************stream transmitted and received with the back pressure succefully :) *********************/");
$display("/************************************************************************************************************/");
end

$stop;
end    


/***************** injection task with backpressure considering ***************/
task inject();
while(stim.size != NUM_OF_TESTS)
      begin
        if(!o_hold_stream)
        begin
            i_data = $random;
            i_valid_in = 1'b1;
            stim.push_back(i_data);
        end
        else
        begin  
            i_valid_in = 1'b0;  
            wait(zigbee_transmitter_receiver_tb.DUT_2.u_fifo_sym_to_chip.i_r_inc);
        end
        @(negedge i_clk_bit_to_symbol) ;
      end
i_valid_in = 1'b0; 
endtask 

/************************ observing task *********************************/ 
task observe ();
    while(output_q.size != NUM_OF_TESTS)
    begin
    @(negedge i_clk_bit_to_symbol);
		if(o_stream_valid)
            begin
                output_q.push_back(o_bit_stream);
                $display(o_bit_stream);
            end
    end        
endtask 



///////////////////////////// Devices undet tests /////////////////////////////

zigbee_transmitter DUT_2
(
.i_clk_bit_to_symbol        (i_clk_bit_to_symbol)   ,                                 
.i_clk_symbol_to_chip       (i_clk_symbol_to_chip)   ,                         
.i_clk_serial_to_parallel   (i_clk_serial_to_parallel) ,                       
.i_clk_pulse_shabing        (i_clk_pulse_shabing) ,                                   
.i_rst_n                    (i_rst_n),                    
.i_valid_in                 (i_valid_in ) ,                       
.i_data                     (i_data) ,                   
.o_Q_pulse_shaped           (s_Q_pulse_shaped)   ,                         
.o_Q_pulse_valid            (s_Q_pulse_valid) ,                               
.o_I_pulse_shaped           (s_I_pulse_shaped) ,                           
.o_I_pulse_valid            (s_I_pulse_valid)  ,
.o_hold_stream              (o_hold_stream)                                  
);

zigbee_receiver DUT_1 
(
.i_clk_symbol_to_bit           (i_clk_bit_to_symbol),                     
.i_clk_chip_to_symbol          (i_clk_symbol_to_chip),                 
.i_clk_parallel_to_series      (i_clk_serial_to_parallel), 
.i_clk_pulse_shabing           (i_clk_pulse_shabing) ,                         
.i_rst_n                       (i_rst_n),             
.i_Q_pulse_valid               (s_Q_pulse_valid),                     
.i_Q_pulse_shaped              (s_Q_pulse_shaped),             
.i_I_pulse_valid               (s_I_pulse_valid),                     
.i_I_pulse_shaped              (s_I_pulse_shaped),                     
.o_bit_stream                  (o_bit_stream),                     
.o_stream_valid                (o_stream_valid)                      
);


endmodule