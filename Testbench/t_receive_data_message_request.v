
      
	initial begin
      
                wait( initial_done == 1);
      
                force prl_top_m.prl_tx_if_source_cap_table_select = 4'h6; 
	        @(posedge clk);
	        @(posedge clk);
	        @(posedge clk);
	        @(posedge clk);
		pe2pl_tx_en_s = 1;
		pe2pl_tx_type_s = 7'b01_00010;
	        @(posedge clk);
		pe2pl_tx_en_s = 0;
		$display($stime, "-->Slave Send data message <0100010> begin.");

                wait( pl2pe_tx_ack_s == 1);
                $display($stime, "-->Slave Send data message done, the resutl is %h.", pl2pe_tx_result_s);
                //$display($stime, "-->Send message done");

	end
      
      
	initial begin
      
                wait( pl2pe_rx_en_m == 1);
                $display($stime, "-->Master receive message , the resutl is %h, the sop type is %h, the message type is %b", pl2pe_rx_result_m, pl2pe_rx_sop_type_m, pl2pe_rx_type_m);

	end
      
      
      

