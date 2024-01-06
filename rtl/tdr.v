`define TDR_INDEX                       8'd0
`define HIGH                            1'b1
`define LOW                             1'b0
`define REGISTER_INITIAL_VALUE          8'h00
`define DATA_ON_RESET                   8'h00
`define INCORRECT_ADDRESS_VALUE         8'hxx
`define READ_VALUE_ON_INCORRECT_ADDR    8'hxx
`define READ_VALUE_ON_DEFAULT           8'h00


module tdr (
    //Inputs
    input               tdr_clk,
    input               tdr_reset_n,
    input               tdr_sel,
    input               tdr_write,
    input               tdr_enable,
    input       [2:0]   tdr_selected_reg,
    input       [7:0]   tdr_wdata,
    input               tdr_ready,

    //Outputs
    output  reg [7:0]   tdr_rdata
);


/***********************************|
|I.        INTERNAL  SIGNALS        |
|***********************************/
reg [7:0] tdr_data = `REGISTER_INITIAL_VALUE;


/***********************************|
|II.          BEHAVIOUR             |
|***********************************/
/*************************|
|1.     Writing data      |
|*************************/
always @(posedge tdr_clk or tdr_reset_n) begin
    if(~tdr_reset_n) begin
        tdr_data <= `DATA_ON_RESET;
    end
    else if(tdr_sel && tdr_write && tdr_enable && tdr_selected_reg[`TDR_INDEX ] && tdr_ready) begin
        tdr_data <= tdr_wdata;
    end
    else begin
        tdr_data <= tdr_data;
    end
end

/*************************|
|2.     Reading data      |
|*************************/
always @(*) begin
    if(tdr_sel && !tdr_write && tdr_enable && tdr_selected_reg[`TDR_INDEX ] && tdr_ready) begin
        tdr_rdata = tdr_data;
    end
end

/*************************|
|3.   Auto update rdata   |
|*************************/
always @(tdr_data) begin
    tdr_rdata = tdr_data;
end

endmodule