module timer_tb;
wire            pclk, preset_n, pslverr, pready, psel, pwrite, penable;
wire    [7:0]   paddress, pwdata, prdata;

// initial begin
//     $display("At %0t, (TOP) is being initiated", $time);
// end

/***********************************|
|I.      INSTANTIATING MODULES      |
|***********************************/

system_signals ss_ins(
    // Outputs
    .sys_clk(pclk),
    .sys_resetn(preset_n)
);

cpu_model cpu(
    // Inputs
    .cpu_clk(pclk),
    .cpu_reset_n(preset_n),
    .cpu_slverr(pslverr),
    .cpu_ready(pready),
    .cpu_rdata(prdata),

    // Outputs
    .cpu_sel(psel),
    .cpu_write(pwrite),
    .cpu_enable(penable),
    .cpu_address(paddress),
    .cpu_wdata(pwdata)
);

timer timer_ins(
    // Inputs
    .timer_clk(pclk),
    .timer_reset_n(preset_n),
    .timer_sel(psel),
    .timer_enable(penable),
    .timer_write(pwrite),
    .timer_address(paddress),
    .timer_wdata(pwdata),

    // Outputs
    .timer_ready(pready),
    .timer_slverr(pslverr),
    .timer_rdata(prdata)
);

/***********************************|
|II.          BEHAVIOUR             |
|***********************************/
task get_result(input reg flag);
    begin
        if (flag) begin
            $display("-------------------------------------");
            $display("            -CASE FAILED             ");
            $display("-------------------------------------");
        end
        else begin
            $display("-------------------------------------");
            $display("            -CASE-PASSED-            ");
            $display("-------------------------------------");
        end
    end
endtask

endmodule