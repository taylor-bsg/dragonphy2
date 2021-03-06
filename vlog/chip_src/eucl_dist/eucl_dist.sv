module eucl_dist #(
	parameter integer inWidth 	  = 8,
	parameter integer outWidth    = 8,
	parameter integer seqLength   = 5
) (
	input wire logic signed [inWidth-1:0] est_seq [seqLength-1:0],
	input wire logic signed [inWidth-1:0] code_seq [seqLength-1:0],
	
	input wire logic clk,
	input wire logic rstb,

	output reg  [outWidth-1:0] energ
);

	logic signed [$clog2(seqLength) + inWidth-1:0] next_energ;

	always_comb begin
		integer ii;
		next_energ = 0;
		for(ii=0; ii<seqLength; ii=ii+1) begin
			next_energ = next_energ + (code_seq[ii]-est_seq[ii])*(code_seq[ii]-est_seq[ii]);
		end
	end


	always_ff @(posedge clk or negedge rstb) begin
		if(~rstb) begin
			energ <= 0;
		end else begin
			energ <= (next_energ)>>>seqLength;
		end
	end



endmodule : eucl_dist