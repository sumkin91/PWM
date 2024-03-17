module PWM(
	input Clock,
	input Reset,
	input [7:0]period_low,
	input [7:0]period_high,
	input WE_period_low,
	input WE_period_high,
	input [7:0]impuls_low,
	input [7:0]impuls_high,
	input WE_impuls_low,
	input WE_impuls_high,
	input WE_enable_pwm,
	input WE_disable_pwm,
	output out_pwm
);

reg enable_pwm;
reg [15:0] reg_period;
reg [15:0] reg_impuls;
reg [15:0] reg_current_period;
reg out;

wire [15:0] w_period; 
wire [15:0] w_impuls;

always@(negedge WE_period_low or negedge Reset)
begin
	if(!Reset) reg_period[7:0] = 0;
	else reg_period[7:0] <= period_low;
end

always@(negedge WE_period_high or negedge Reset)
begin
	if(!Reset) reg_period[15:8] = 0;
	else reg_period[15:8] <= period_high;
end

assign w_period = reg_period;

always@(negedge WE_impuls_low or negedge Reset)
begin
	if(!Reset) reg_impuls[7:0] = 0;
	else reg_impuls[7:0] <= impuls_low;
end

always@(negedge WE_impuls_high or negedge Reset)
begin
	if(!Reset) reg_impuls[15:8] = 0;
	else reg_impuls[15:8] <= impuls_high;
end

assign w_impuls = reg_impuls;

always@(*)
begin
	if(WE_disable_pwm) enable_pwm = 0;
	else if(WE_enable_pwm) enable_pwm = 1;
end

always@(posedge Clock or negedge Reset)
begin
	if(!Reset) reg_current_period = 0;
	else if(enable_pwm) begin
		if (reg_current_period <= w_impuls) out <= 1;
		else if (reg_current_period >= w_period) reg_current_period = 0;
		else out = 0;
		reg_current_period = reg_current_period + 1;
	end
end

assign out_pwm = enable_pwm ? out : 0;

endmodule