
      
	initial begin
      
                wait( initial_done == 1);
	        @(posedge clk);
		pe2pl_tx_en_m = 1;
		pe2pl_tx_type_m = 7'b01_00110;
		pe2pl_tx_info_m = 9'h1f6;
	        @(posedge clk);
		pe2pl_tx_en_m = 0;
		$display($stime, "-->Master Send data message <0100110> begin.");

                wait( pl2pe_tx_ack_m == 1);
                $display($stime, "-->Master Send data message done, the resutl is %h.", pl2pe_tx_result_m);
                //$display($stime, "-->Send message done");

	end
      
      
	initial begin
      
                wait( pl2pe_rx_en_s == 1);
                $display($stime, "-->Slave receive message , the resutl is %h, the sop type is %h, the message type is %b", pl2pe_rx_result_s, pl2pe_rx_sop_type_s, pl2pe_rx_type_s);

	end
      
      
      

