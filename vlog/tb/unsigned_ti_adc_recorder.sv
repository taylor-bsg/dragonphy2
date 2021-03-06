`default_nettype none

module unsigned_ti_adc_recorder import const_pack::*; #(
	parameter integer num_channels = Nti,
	parameter filename = "ti_adc.txt"
) (
	input wire logic [Nadc-1:0] in [num_channels-1:0],
	input wire logic clk,
	input wire logic en
);

	integer fid;
	initial begin
		fid = $fopen(filename, "w");
	end

	always @(posedge clk) begin
		if (en == 'b1) begin
			for (int i=0; i<num_channels; i=i+1) begin
				if (i != 0) begin
					$fwrite(fid, ", "); 
				end
				$fwrite(fid, "%0d", in[i]); 
			end

			$fwrite(fid, "\n");
		end
	end

endmodule

`default_nettype wire
