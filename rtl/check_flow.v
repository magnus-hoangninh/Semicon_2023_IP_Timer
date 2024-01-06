`define HIGH    1'b1
`define LOW     1'b0

module check_flow (
    //Inputs
    input           checkflow_clk,
    input           checkflow_reset_n,
    input   [7:0]   checkflow_counter_last_value,
    input   [7:0]   checkflow_counter_value,
    input   [1:0]   checkflow_clear_flag,
    input           checkflow_tcr_load,
    input           checkflow_tcr_up_down,


    //Outputs
    output  reg     checkflow_ovf_flag,
    output  reg     checkflow_udf_flag
);
/***********************************|
|I.        INTERNAL  SIGNALS        |
|***********************************/

/***********************************|
|II.          BEHAVIOUR             |
|***********************************/
/*************************|
|1.    Check Overflow     |
|*************************/
always @(posedge checkflow_clk or negedge checkflow_reset_n) begin
    if (~checkflow_reset_n) begin
        checkflow_ovf_flag <= `LOW;
    end
    else begin
        if(checkflow_clear_flag[0]) begin
            checkflow_ovf_flag <= `LOW;
        end
        if (checkflow_counter_last_value == 8'hFF 
            && checkflow_counter_value == 8'h00 
            && ~checkflow_tcr_load
            && ~checkflow_tcr_up_down) begin
                checkflow_ovf_flag <= `HIGH;
            end
        else begin
            checkflow_ovf_flag <= `LOW;
        end
        
    end
end

/*************************|
|2.    Check Underflow    |
|*************************/
always @(posedge checkflow_clk or negedge checkflow_reset_n) begin
    if (~checkflow_reset_n) begin
        checkflow_udf_flag <= `LOW;
    end
    else begin
        if(checkflow_clear_flag[1]) begin
            checkflow_udf_flag <= `LOW;
        end
        if (checkflow_counter_last_value == 8'h00
            && checkflow_counter_value == 8'hFF
            && ~checkflow_tcr_load
            && checkflow_tcr_up_down) begin
                checkflow_udf_flag <= `HIGH;
            end
        else begin
            checkflow_udf_flag <= `LOW;
        end
        
    end
end
    
endmodule