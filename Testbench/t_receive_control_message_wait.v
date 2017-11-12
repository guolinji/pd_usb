
      
	initial begin
      
                wait( initial_done == 1);
      
	        #2000;
                pe2pl_tx_ams_begin_s = 1;
                pe2pl_tx_ams_end_m   = 1;
		#500;
                pe2pl_tx_ams_begin_s = 0;
                pe2pl_tx_ams_end_m   = 0;
      
	        @(posedge clk);
	        @(posedge clk);
	        @(posedge clk);
	        @(posedge clk);
		pe2pl_tx_en_s = 1;
		pe2pl_tx_type_s = 7'b00_01100;
	        @(posedge clk);
		pe2pl_tx_en_s = 0;
		$display($stime, "-->Slave Send control message <0001100> begin.");

                wait( pl2pe_tx_ack_s == 1);
                $display($stime, "-->Slave Send control message done, the resutl is %h.", pl2pe_tx_result_s);
                //$display($stime, "-->Send message done");

	end
      
      
	initial begin
      
                wait( pl2pe_rx_en_m == 1);
                $display($stime, "-->Master receive message , the resutl is %h, the sop type is %h, the message type is %b", pl2pe_rx_result_m, pl2pe_rx_sop_type_m, pl2pe_rx_type_m);

	end
      
      
      

