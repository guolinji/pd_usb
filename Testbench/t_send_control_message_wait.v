
      
	initial begin
      
                wait( initial_done == 1);
	        @(posedge clk);
		pe2pl_tx_en_m = 1;
		pe2pl_tx_type_m = 7'b00_01100;
	        @(posedge clk);
		pe2pl_tx_en_m = 0;
		$display($stime, "-->Mater Send control message <0001100> begin.");

                wait( pl2pe_tx_ack_m == 1);
                $display($stime, "-->Mater Send control message done, the resutl is %h.", pl2pe_tx_result_m);
                //$display($stime, "-->Send message done");

	end
      
      
	initial begin
      
                wait( pl2pe_rx_en_s == 1);
                $display($stime, "-->Slave receive message , the resutl is %h, the sop type is %h, the message type is %b", pl2pe_rx_result_s, pl2pe_rx_sop_type_s, pl2pe_rx_type_s);

	end
      
      
      

