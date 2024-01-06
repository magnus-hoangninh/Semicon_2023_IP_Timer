`define HIGH                            1'b1
`define LOW                             1'b0
`define INCORRECT_ADDRESS_VALUE         8'hxx
`define WAIT_CYCLES                     8'd2
`define COUNT_INITIAL_AND_RESET_VALUE   6'b000000

module register_control (
    //Inputs
    input           rc_clk,
    input           rc_reset_n,
    input           rc_sel,
    input           rc_write,
    input           rc_enable,
    input [7:0]     rc_address,
    input [7:0]     rc_wdata,
    input           rc_ovf_flag,
    input           rc_udf_flag,

    //Outputs
    output      [7:0]   rc_tdr_rdata,
    output      [7:0]   rc_tcr_rdata,
    output      [7:0]   rc_tsr_rdata,
    output              rc_tcr_load,
    output              rc_tcr_up_down,
    output              rc_tcr_enable,
    output      [1:0]   rc_tcr_cks,
    output  reg         rc_ready,
    output  reg         rc_slverr,
    output      [1:0]   rc_clear_flag
);

/***********************************|
|I.        INTERNAL  SIGNALS        |
|***********************************/
reg     [2:0]   selected_reg;
// wire    [2:0]   read_data   [0:7];
reg     [5:0]   count = `COUNT_INITIAL_AND_RESET_VALUE;

/***********************************|
|II.       INITIATING MODULES       |
|***********************************/
tdr tdr_ins(    
    //Inputs
    .tdr_clk(rc_clk),
    .tdr_reset_n(rc_reset_n),
    .tdr_sel(rc_sel),
    .tdr_write(rc_write),
    .tdr_enable(rc_enable),
    .tdr_selected_reg(selected_reg),
    .tdr_wdata(rc_wdata),
    .tdr_ready(rc_ready),

    //Outputs
    .tdr_rdata(rc_tdr_rdata)
);
tcr tcr_ins(
    //Inputs
    .tcr_clk(rc_clk),
    .tcr_reset_n(rc_reset_n),
    .tcr_sel(rc_sel),
    .tcr_write(rc_write),
    .tcr_enable(rc_enable),
    .tcr_selected_reg(selected_reg),
    .tcr_wdata(rc_wdata),
    .tcr_ready(rc_ready),

    //Outputs
    .tcr_rdata(rc_tcr_rdata),
    .tcr_load(rc_tcr_load),
    .tcr_up_down(rc_tcr_up_down),
    .tcr_en(rc_tcr_enable),
    .tcr_cks(rc_tcr_cks)
);
tsr tsr_ins(
    //Inputs
    .tsr_clk(rc_clk),
    .tsr_reset_n(rc_reset_n),
    .tsr_sel(rc_sel),
    .tsr_write(rc_write),
    .tsr_enable(rc_enable),
    .tsr_selected_reg(selected_reg),
    .tsr_wdata(rc_wdata),
    .tsr_ready(rc_ready),
    .tsr_ovf_flag(rc_ovf_flag),
    .tsr_udf_flag(rc_udf_flag),

    //Outputs
    .tsr_rdata(rc_tsr_rdata),
    .tsr_clear_flag(rc_clear_flag)
);

/***********************************|
|III.           BEHAVIOUR           |
|***********************************/
/*************************|
|1.    Decode address     |
|*************************/
always @(rc_address) begin
    case (rc_address)
        8'h00: selected_reg = 3'b001;
        8'h01: selected_reg = 3'b010;
        8'h02: selected_reg = 3'b100; 
        default: selected_reg = 3'b000;
    endcase
end
/*************************|
|3.        Slverr         |
|*************************/
always @(posedge rc_clk or rc_reset_n) begin
    if(~rc_reset_n) begin
        rc_slverr <= `LOW;
    end
    else if(selected_reg == 3'b000) begin
        rc_slverr <= `HIGH;        
    end
    else begin
        rc_slverr <= `LOW;
    end
end
/*************************|
|4.        Pready         |
|*************************/
always @(posedge rc_clk or negedge rc_reset_n) begin
    if (~rc_reset_n) begin
        rc_ready <= `LOW;
        count <= `COUNT_INITIAL_AND_RESET_VALUE;
    end
    else if (rc_sel && rc_enable && (count == `COUNT_INITIAL_AND_RESET_VALUE)) begin
        rc_ready <= `LOW;
    end
    else if (rc_sel) begin
        if (count == `WAIT_CYCLES) begin
            count <= `COUNT_INITIAL_AND_RESET_VALUE;     // Ready for new transfer
            #2
            rc_ready <= `HIGH;
        end
        else begin
            count <= count + 6'b00_00_01;
        end
    end
    else begin
        rc_ready <= `LOW;
    end
end

endmodule