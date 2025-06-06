/*
module HighPassFilter(
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
wire signed [31:0]leftLastInput = { {16{lastAudioIn[31]}}, lastAudioIn[31:16]};
reg signed [31:0]leftResult;

wire signed [31:0]rightAudio = { {16{audioIn[15]}}, audioIn[15:0]};
wire signed [31:0]rightLastOutput = {  {16{lastOutput[15]}}, lastOutput[15:0]};
wire signed [31:0]rightLastInput = {  {16{lastAudioIn[15]}}, lastAudioIn[15:0]};

reg signed [31:0]rightResult;
reg signed [15:0]left;
reg signed [15:0]right;

always @ (*)
begin
	

	
	leftResult = ( $signed(leftLastOutput) * $signed(32'd2) / $signed(32'd3)) + ( ($signed(leftAudio) - $signed(leftLastInput)) * $signed(32'd2) / $signed(32'd3) );
	rightResult = ( $signed(rightLastOutput) * $signed(32'd2) / $signed(32'd3)) + ( ($signed(rightAudio) - $signed(rightLastInput)) * $signed(32'd2) / $signed(32'd3) );
	
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
				lastAudioIn <= audioIn;
			end
			
		end
	
end

endmodule
*/

//tried fir hpf instead of iir hpf...
module HighPassFilter(
    input clk,
    input rst,
    input AUD_BCLK,
    input AUD_DACLRCK,
	 input AUD_ADCLRCK,
    input [31:0] audioIn,
    output reg [31:0] audioOut
);

parameter N = 5; // Number of taps

// High-pass filter coefficients (simple example — attenuates low frequencies)
reg signed [15:0] h [0:N-1];
initial begin
    h[0] = -16'sd4;
    h[1] = -16'sd4;
    h[2] =  16'sd16;
    h[3] = -16'sd4;
    h[4] = -16'sd4;
end

// Delay lines for left and right channels
reg signed [15:0] x_left [0:N-1];
reg signed [15:0] x_right[0:N-1];

integer i;

reg signed [31:0] acc_left, acc_right;
wire signed [15:0] left_in  = audioIn[31:16];
wire signed [15:0] right_in = audioIn[15:0];

always @(posedge AUD_BCLK or negedge rst) begin
    if (!rst) begin
        for (i = 0; i < N; i = i + 1) begin
            x_left[i] <= 0;
            x_right[i] <= 0;
        end
        audioOut <= 0;
    end else if (AUD_DACLRCK) begin
        // Shift previous samples
        for (i = N-1; i > 0; i = i - 1) begin
            x_left[i]  <= x_left[i-1];
            x_right[i] <= x_right[i-1];
        end
        x_left[0]  <= left_in;
        x_right[0] <= right_in;

        // Accumulate output using FIR equation
        acc_left = 0;
        acc_right = 0;
        for (i = 0; i < N; i = i + 1) begin
            acc_left  = acc_left + x_left[i]  * h[i];
            acc_right = acc_right + x_right[i] * h[i];
        end

        audioOut[31:16] <= acc_left[15:0];
        audioOut[15:0]  <= acc_right[15:0];
    end
end

endmodule
