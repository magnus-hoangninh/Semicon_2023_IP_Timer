`define TSR_INDEX                       8'd2
`define HIGH                            1'b1
`define LOW                             1'b0
`define REGISTER_INITIAL_VALUE          8'h00
`define DATA_ON_RESET                   8'h00
`define INCORRECT_ADDRESS_VALUE         8'hxx
`define READ_VALUE_ON_INCORRECT_ADDR    8'hxx
`define READ_VALUE_ON_DEFAULT           8'h00

module tsr (
    //Inputs
    input               tsr_clk,
    input               tsr_reset_n,
    input               tsr_sel,
    input               tsr_write,
    input               tsr_enable,
    input       [2:0]   tsr_selected_reg,
    input       [7:0]   tsr_wdata,
    input               tsr_ready,
    input               tsr_ovf_flag,
    input               tsr_udf_flag,

    //Outputs
    output  reg [7:0]   tsr_rdata,
    output  reg [1:0]   tsr_clear_flag
);

/***********************************|
|I.        INTERNAL  SIGNALS        |
|***********************************/
reg [7:0] tsr_data = `REGISTER_INITIAL_VALUE;


/***********************************|
|II.          BEHAVIOUR             |
|***********************************/
/*************************|
|1.  Writing to OVF bit   |
|*************************/
always @(posedge tsr_clk or negedge tsr_reset_n) begin
    if(~tsr_reset_n) begin
        tsr_data <= `DATA_ON_RESET;
        tsr_clear_flag[0] <= 1'b0;
    end
    // CLEAR by software - write 0
    // Different statuses to write 0 to OVF bit:
    // 1. Counter is overflowed (OVF == 1 / UDF == 0)
    // 2. Counter is underflowed / not overflowed (OVF == 0 / UDF == 1)
    //    -> in this case, wdata[0] MUST NOT be 0
    // *To avoid looping, we use UDF to compare instead of OVF
    else if((tsr_sel && tsr_write && tsr_enable && tsr_selected_reg[`TSR_INDEX ] && tsr_ready)
        && tsr_wdata[1:0] != 2'b11
        && (!tsr_data[1] || tsr_data[1] && !tsr_wdata[0])) begin
        tsr_data[0] <= tsr_wdata[0];
        tsr_clear_flag[0] <= 1'b0;
    end
    else if(tsr_ovf_flag) begin
        tsr_data[0] <= 1'b1;
        tsr_clear_flag[0] <= 1'b1;
    end
    else begin
        tsr_data[0] <= tsr_data[0];
        tsr_clear_flag[0] <= tsr_clear_flag[0];
    end
end

/*************************|
|2.  Writing to UDF bit   |
|*************************/
always @(posedge tsr_clk or negedge tsr_reset_n) begin
    if(~tsr_reset_n) begin
        tsr_data <= `DATA_ON_RESET;
        tsr_clear_flag[1] <= 1'b0;
    end
    // CLEAR by software - write 0
    // Different statuses to write 0 to UDF bit:
    // 1. Counter is underflowed (OVF == 0 / UDF == 1)
    // 2. Counter is overflowed / not underflowed (OVF == 1 / UDF == 0)
    //    -> in this case, wdata[1] MUST NOT be 0
    // *To avoid looping, we use OVF to compare instead of UDF
    else if((tsr_sel && tsr_write && tsr_enable && tsr_selected_reg[`TSR_INDEX ] && tsr_ready)
        && tsr_wdata[1:0] != 2'b11
        && (!tsr_data[0] || tsr_data[0] && !tsr_wdata[1])) begin
        tsr_data[1] <= tsr_wdata[1];
        tsr_clear_flag[1] <= 1'b0;
    end
    else if(tsr_udf_flag) begin
        tsr_data[1] <= 1'b1;
        tsr_clear_flag[1] <= 1'b1;
    end
    else begin
        tsr_data[1] <= tsr_data[1];
        tsr_clear_flag[1] <= tsr_clear_flag[1];
    end
end

/*************************|
|3.     Reading data      |
|*************************/
always @(*) begin
    if(tsr_sel && !tsr_write && tsr_enable && tsr_selected_reg[`TSR_INDEX] && tsr_ready) begin
        tsr_rdata = tsr_data;
    end
    else if(tsr_selected_reg == `INCORRECT_ADDRESS_VALUE) begin
        tsr_rdata = `READ_VALUE_ON_INCORRECT_ADDR;
    end
    else begin
        tsr_rdata = `READ_VALUE_ON_DEFAULT;
    end
end

endmodule