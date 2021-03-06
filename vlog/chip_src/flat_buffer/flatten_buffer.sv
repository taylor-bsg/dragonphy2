module flatten_buffer #(
	parameter integer numChannels = 16,
	parameter integer bitwidth 	  = 8,
	parameter integer depth    	  = 5	
) (
	input wire logic [bitwidth-1:0] buffer [numChannels-1:0][depth-1:0],

	output logic [bitwidth-1:0] flat_buffer [numChannels*depth-1:0]
);

genvar gi, gj;
generate 
	for(gj=0; gj<numChannels; gj=gj+1) begin
		for(gi=0; gi<depth; gi=gi+1) begin
			assign flat_buffer[(depth - gi - 1)*numChannels + gj] = buffer[gj][gi];
		end
	end
endgenerate

endmodule : flatten_buffer