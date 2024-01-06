module t19_fake_check_flow;

reg [7:0] rdata, wdata, wdata2;
integer wait_cycle, wait_cycle_2;
reg flag_fail = 1'b0;
integer i;

/***********************************|
|       INSTANTIATING MODULES       |
|***********************************/
timer_tb top();

/***********************************|
|            TESTING CODE           |
|***********************************/
initial begin
    $display("\nAt %0t", $time);
    $display("-------------------------------------------");
    $display("--------------TEST-T19-BEGIN--------------");
    $display("-------------------------------------------\n");

    for (i = 1; i < 2; i = i + 1) begin
        $display("\n-------------------------------------");
        $display("             -CASE-%0d-              ", i);
        $display("-------------------------------------");
        top.ss_ins.system_reset();
        #50
        $display("-STEP-1-Reading-TDR-data-after-system-reset-");
        top.cpu.cpu_read_task(8'h00, rdata);
        $display("At %0t, (TEST) completed reading TDR's data = 'h%0h", $time, rdata);

        $display("----------------------------------");
        $display("-STEP-2-Faking-check-flow-counter-value-and-last-counter-value-\n");
        $display("-STEP-2-1-1-Loading-value-8h00-to-TDR-");
        top.cpu.cpu_write_task(8'h00, 8'h00);
        $display("At %0t, (TEST) completed writing data = 8'h00 to TDR", $time);

        $display("----------------------------------");

        $display("-STEP-2-1-2--Loading-TDR-to-Counter-");
        top.cpu.cpu_write_task(8'h01, 8'b1000_0000);
        $display("At %0t, (TEST) completed loading TDR to Counter", $time);

        $display("----------------------------------");

        $display("-STEP-2-2-Loading-new-value-8hFF-to-TDR-");
        top.cpu.cpu_write_task(8'h00, 8'hFF);
        $display("At %0t, (TEST) completed writing data = 8'hFF to TDR", $time);

        $display("----------------------------------");

        $display("-STEP-2-2-2-Loading-TDR-with-new-value-to-Counter-");
        $display("Because we haven't changed the configuration of TCR so loading mode is still being activated.\nTDR's new value will be automatically loaded to Counter.");
        $display("At %0t, (TEST) completed loading TDR's new value to Counter", $time);

        $display("----------------------------------");

        $display("-STEP-6-Reading-TSR-");
        top.cpu.cpu_write_task(8'h02, rdata);
        $display("At %0t, (TEST) completed reading TSR's data = 'b%8b", $time, rdata);

        $display("----------------------------------");

        $display("-STEP-7-Comparing-");
        if(rdata != 8'b0000_0000) begin
            flag_fail = 1'b0;
            $display("(TEST) One of the two flags is being raised. UNEXPECTED RESULT. TDR's data is 'b%b", rdata);
        end
        else begin
            $display("(TEST) None of the flag is being raised AS EXPECTED because TSR's data is 'b%b", rdata);
        end

        #100
        top.timer_tb.get_result(flag_fail);
    end

    $display("\nAt %0t", $time);
    $display("-------------------------------------------");
    $display("--------------TEST-T19-END----------------");
    $display("-------------------------------------------\n");
    $finish();
end

endmodule