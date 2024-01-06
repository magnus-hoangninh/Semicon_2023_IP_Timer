module timer (
    // Inputs
    input               timer_clk, timer_reset_n, timer_sel, timer_write, timer_enable,
    input       [7:0]   timer_address, timer_wdata,

    // Outputs
    output              timer_ready, timer_slverr,
    output  reg [7:0]   timer_rdata
);

/***********************************|
|I.        INTERNAL  SIGNALS        |
|***********************************/
wire            selected_internal_clock, ovf_flag, udf_flag, tcr_load, tcr_up_down, tcr_enable;
wire    [7:0]   timer_tdr_rdata, timer_tcr_rdata, timer_tsr_rdata, counter_last_value, counter_value;
wire    [1:0]   clear_flag, tcr_cks;

/***********************************|
|II.       INITIATING MODULES       |
|***********************************/
select_clock sc_ins(
    // Inputs
    .sc_clk(timer_clk),
    .sc_reset_n(timer_reset_n),
    .sc_cks(tcr_cks),

    //Outputs
    .selected_internal_clock(selected_internal_clock)
);
register_control rc_ins(
    // Inputs
    .rc_clk(timer_clk),
    .rc_reset_n(timer_reset_n),
    .rc_sel(timer_sel),
    .rc_write(timer_write),
    .rc_enable(timer_enable),
    .rc_address(timer_address),
    .rc_wdata(timer_wdata),
    .rc_ovf_flag(ovf_flag),
    .rc_udf_flag(udf_flag),

    //Outputs
    .rc_tdr_rdata(timer_tdr_rdata),
    .rc_tcr_rdata(timer_tcr_rdata),
    .rc_tsr_rdata(timer_tsr_rdata),
    .rc_tcr_load(tcr_load),
    .rc_tcr_up_down(tcr_up_down),
    .rc_tcr_enable(tcr_enable),
    .rc_tcr_cks(tcr_cks),
    .rc_ready(timer_ready),
    .rc_slverr(timer_slverr),
    .rc_clear_flag(clear_flag)
);
counter counter_ins(
    //Inputs
    .counter_clk(timer_clk),
    .counter_reset_n(timer_reset_n),
    .counter_internal_clk(selected_internal_clock),
    .counter_enable(timer_enable),
    .counter_tdr(timer_tdr_rdata),
    .counter_tcr_load(tcr_load),
    .counter_tcr_up_down(tcr_up_down),
    .counter_tcr_enable(tcr_enable),

    //Outputs
    .counter_value(counter_value),
    .counter_last_value(counter_last_value)
);
check_flow cf_ins(
    //Inputs
    .checkflow_clk(timer_clk),
    .checkflow_reset_n(timer_reset_n),
    .checkflow_counter_last_value(counter_last_value),
    .checkflow_counter_value(counter_value),
    .checkflow_clear_flag(clear_flag),
    .checkflow_tcr_load(tcr_load),
    .checkflow_tcr_up_down(tcr_up_down),

    //Outputs
    .checkflow_ovf_flag(ovf_flag),
    .checkflow_udf_flag(udf_flag)
);

/***********************************|
|III.           BEHAVIOUR           |
|***********************************/
/*************************|
|1.   Choose read data    |
|*************************/
always @(*) begin
    case (timer_address)
        8'h00: assign timer_rdata = timer_tdr_rdata;
        8'h01: assign timer_rdata = timer_tcr_rdata;
        8'h02: assign timer_rdata = timer_tsr_rdata;
    endcase
end


endmodule