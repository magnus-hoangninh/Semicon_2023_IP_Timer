module counter (
    //Inputs
    input           counter_clk,
    input           counter_reset_n,
    input           counter_internal_clk,
    input           counter_enable,
    input   [7:0]   counter_tdr,
    input           counter_tcr_load,
    input           counter_tcr_up_down,
    input           counter_tcr_enable,

    //Outputs
    output  reg [7:0]   counter_value,
    output  reg [7:0]   counter_last_value
);

/***********************************|
|I.        INTERNAL  SIGNALS        |
|***********************************/
reg         last_internal_clk;
wire        counter_internal_enable;

/***********************************|
|II.           BEHAVIOUR            |
|***********************************/
/*************************|
|1.   Load/Manual Count   |
|*************************/
always @(posedge counter_internal_clk or negedge counter_reset_n) begin
    if(~counter_reset_n) begin
        counter_value <= 8'h00;
    end
    else if(counter_tcr_load) begin // MANUALLY LOAD
        counter_value <= counter_tdr;
    end
    else if(counter_tcr_enable) begin  // NORMAL OPERATION
        if(counter_tcr_up_down && counter_internal_enable) begin
            counter_value <= counter_value - 1'b1;
        end
        else if(~counter_tcr_up_down && counter_internal_enable) begin
            counter_value <= counter_value + 1'b1;
        end
        else begin
            counter_value <= counter_value;
        end
    end
    else begin
        counter_value <= counter_value;
    end
end

/*************************|
|2.     Edge Detector     |
|*************************/
always @(posedge counter_clk or negedge counter_reset_n) begin
    if (~counter_reset_n) begin
        last_internal_clk <= 1'b0;
    end
    else begin
        last_internal_clk <= counter_internal_clk;
    end
end
assign counter_internal_enable = ~(last_internal_clk) && counter_internal_clk;

/*************************|
|3.       Comparing       |        For later use in check_flow
|*************************/
always @(posedge counter_clk or counter_reset_n) begin
    if(~counter_reset_n) begin
        counter_last_value <= 8'h00;
    end
    else begin
        counter_last_value <= counter_value;
    end
end

endmodule