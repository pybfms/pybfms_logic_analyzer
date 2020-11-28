/****************************************************************************
 * la_initiator_bfm.v
 * 
 ****************************************************************************/
 
`undef EN_DEBUG_LA_INITIATOR_BFM

module la_initiator_bfm #(
		parameter WIDTH = 128
		) (
		input							clock,
		input							reset,

		input[WIDTH-1:0]				data_in,
		output reg[WIDTH-1:0]			data_out,
		output reg[WIDTH-1:0]			oen
		);
	reg[WIDTH-1:0]			data_out_v = 0;
	reg[WIDTH-1:0]			oen_v = 0;
	reg[WIDTH-1:0]			data_in_last = 0;
	
	reg						in_reset = 0;
	reg						propagate_v = 0;
	reg						propagate = 0;
	
	always @(posedge clock) begin
		if (reset) begin
			data_out <= {WIDTH{1'b0}};
			oen <= {WIDTH{1'b0}};
			propagate <= 0;
			in_reset <= 1;
		end else begin
			if (in_reset) begin
				_reset();
				in_reset <= 0;
			end
			data_out <= data_out_v;
			oen <= oen_v;
			propagate <= propagate_v;
			
			if (propagate && propagate_v) begin
`ifdef EN_DEBUG_LA_INITIATOR_BFM
				$display("%t propagate_ack", $time);
`endif
				_propagate_ack();
				propagate_v = 0;
			end
		
			data_in_last <= data_in;
			if (data_in_last != data_in) begin
				// TODO: should genericize this
				if (data_in_last[127:64] != data_in[127:64]) begin
					_update_data_in(64, 64, data_in[127:64]);
				end
				if (data_in_last[63:0] != data_in[63:0]) begin
					_update_data_in(0, 64, data_in[63:0]);
				end
			end
		end
	end
	
	task _set_bits(
		input reg[31:0]			start,
		input reg[63:0]			val,
		input reg[63:0]			mask);
	integer i;
	begin
`ifdef EN_DEBUG_LA_INITIATOR_BFM
		$display("_set_bits %0d val=%08h mask=%08h", start, val, mask);
`endif
		for (i=start; i<start+64 && i<WIDTH; i++) begin
			if (mask[i-start]) begin
`ifdef EN_DEBUG_LA_INITIATOR_BFM
				$display("%t set bit %0d=%0d", $time, i, val[i-start]);
`endif
				data_out_v[i] = val[i-start];
			end
		end
	end
	endtask
	
	task _set_oen(
		input reg[31:0]			start,
		input reg[63:0]			val,
		input reg[63:0]			mask);
	integer i;
	begin
`ifdef EN_DEBUG_LA_INITIATOR_BFM
		$display("_set_oen %0d val=%08h mask=%08h", start, val, mask);
`endif
		for (i=start; i<start+64 && i<WIDTH; i++) begin
			if (mask[i-start]) begin
`ifdef EN_DEBUG_LA_INITIATOR_BFM
				$display("%t set oen %0d=%0d", $time, i, val[i-start]);
`endif
				oen_v[i] = val[i-start];
			end
		end
	end
	endtask
	
	task _propagate_req;
	begin
`ifdef EN_DEBUG_LA_INITIATOR_BFM
		$display("%t propagate_req", $time);
`endif
		propagate_v = 1;
	end
	endtask
		
	task init;
	begin
		_set_parameters(WIDTH);
	end
	endtask

	// Auto-generated code to implement the BFM API
${pybfms_api_impl}
endmodule
 