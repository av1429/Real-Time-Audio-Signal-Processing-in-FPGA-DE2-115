/*
module LowPassFilter(
input clk,
input rst,
input AUD_BCLK,
input AUD_DACLRCK,
input AUD_ADCLRCK,
input [31:0]audioIn,

output reg [31:0]audioOut
);

reg [31:0]lastAudioIn;
reg [31:0]lastOutput;
initial lastOutput = 32'd0;

//use 32 bits so we can do math and not have to worry about overflows.
wire signed [31:0]leftAudio = { {16{audioIn[31]}}, audioIn[31:16]};
wire signed [31:0]leftLastOutput = { {16{lastOutput[31]}}, lastOutput[31:16]};
reg signed [31:0]leftResult;

wire signed [31:0]rightAudio = { {16{audioIn[15]}}, audioIn[15:0]};
wire signed [31:0]rightLastOutput = {  {16{lastOutput[15]}}, lastOutput[15:0]};
reg signed [31:0]rightResult;
reg signed [15:0]left;
reg signed [15:0]right;

always @ (*)
begin
	

	
	leftResult = ( $signed(leftAudio) / $signed(32'd10)) + ( ((  $signed(leftLastOutput) ) / $signed(32'd10) ) * $signed(32'd9) );
	rightResult = (  $signed(rightAudio) / $signed(32'd10)) + ( (  $signed(rightLastOutput) / $signed(32'd10)) * $signed(32'd9) );
	
	audioOut[31:16] = leftResult[15:0];
	audioOut[15:0] =  rightResult[15:0];
	
	
end

always @ (posedge AUD_BCLK or negedge rst)
begin
	
	if(rst == 0)
		begin
			lastOutput <= 0;
		end
	else 
		begin
		
			if(AUD_DACLRCK == 1)
			begin

				lastOutput <= audioOut;
				//audioOut[31:16] <= $signed(audioIn[31:16])/$signed(16'd2);
				//audioOut[15:0] <=  $signed(audioIn[15:0])/$signed(16'd2);
			end
			
		end
	
end

endmodule
*/

//tried a fir lpf... instead of iir lpf
module LowPassFilter (
    input clk,
    input rst,
    input AUD_BCLK,
    input AUD_DACLRCK,
    input AUD_ADCLRCK,
    input [31:0] audioIn,

    output reg [31:0] audioOut
);

    // Coefficients (5-tap band-pass)
    parameter signed [15:0] h0 = -16'sd512;
    parameter signed [15:0] h1 = -16'sd1024;
    parameter signed [15:0] h2 =  16'sd8192;
    parameter signed [15:0] h3 = -16'sd1024;
    parameter signed [15:0] h4 = -16'sd512;

    reg signed [15:0] x_left[0:4];  // delay line for left channel
    reg signed [15:0] x_right[0:4]; // delay line for right channel

    wire signed [15:0] in_left = audioIn[31:16];
    wire signed [15:0] in_right = audioIn[15:0];

    wire signed [31:0] y_left =
        h0 * x_left[0] +
        h1 * x_left[1] +
        h2 * x_left[2] +
        h3 * x_left[3] +
        h4 * x_left[4];

    wire signed [31:0] y_right =
        h0 * x_right[0] +
        h1 * x_right[1] +
        h2 * x_right[2] +
        h3 * x_right[3] +
        h4 * x_right[4];

    integer i;

    always @(posedge AUD_BCLK or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 5; i = i + 1) begin
                x_left[i] <= 16'sd0;
                x_right[i] <= 16'sd0;
            end
            audioOut <= 32'd0;
        end else if (AUD_DACLRCK) begin
            // Shift delay line
            for (i = 4; i > 0; i = i - 1) begin
                x_left[i] <= x_left[i - 1];
                x_right[i] <= x_right[i - 1];
            end
            x_left[0] <= in_left;
            x_right[0] <= in_right;

            // Output result
            audioOut[31:16] <= y_left[30:15];   // adjust bit shifts if needed
            audioOut[15:0]  <= y_right[30:15];
        end
    end

endmodule
