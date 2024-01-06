`define TCR_INDEX                       8'd1
`define HIGH                            1'b1
`define LOW                             1'b0
`define REGISTER_INITIAL_VALUE          8'h00
`define DATA_ON_RESET                   8'h00
`define INCORRECT_ADDRESS_VALUE         8'hxx
`define READ_VALUE_ON_INCORRECT_ADDR    8'hxx
`define READ_VALUE_ON_DEFAULT           8'h00


module tcr (
    // Inputs
    input               tcr_clk,
    input               tcr_reset_n,
    input               tcr_sel,
    input               tcr_write,
    input               tcr_enable,
    input       [2:0]   tcr_selected_reg,
    input       [7:0]   tcr_wdata,
    input               tcr_ready,

    // Outputs
    output  reg [7:0]   tcr_rdata,
    output              tcr_load,
    output              tcr_up_down,
    output              tcr_en,
    output      [1:0]   tcr_cks
);


/***********************************|
|I.        INTERNAL  SIGNALS        |
|***********************************/
reg     [7:0]   tcr_data = `REGISTER_INITIAL_VALUE;

/***********************************|
|II.          BEHAVIOUR             |
|***********************************/
assign tcr_load = tcr_data[7];
assign tcr_up_down = tcr_data[5];
assign tcr_en = tcr_data[4];
assign tcr_cks = tcr_data[1:0];

/*************************|
|1.     Writing data      |
|*************************/
always @(posedge tcr_clk or tcr_reset_n) begin
    if(~tcr_reset_n) begin
        tcr_data <= `DATA_ON_RESET;
    end
    else if(tcr_sel && tcr_write && tcr_enable && tcr_selected_reg[`TCR_INDEX ] && tcr_ready) begin
        tcr_data <= tcr_wdata;
    end
    else begin
        tcr_data <= tcr_data;
    end
end

/*************************|
|2.     Reading data      |
|*************************/
always @(*) begin
    if(tcr_sel && !tcr_write && tcr_enable && tcr_selected_reg[`TCR_INDEX ] && tcr_ready) begin
        tcr_rdata = tcr_data;
    end
    else if(tcr_selected_reg == `INCORRECT_ADDRESS_VALUE) begin
        tcr_rdata = `READ_VALUE_ON_INCORRECT_ADDR;
    end
    else begin
        tcr_rdata = `READ_VALUE_ON_DEFAULT;
    end
end

endmodule