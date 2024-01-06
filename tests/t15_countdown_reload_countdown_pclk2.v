module t15_countdown_reload_countdown_pclk2;

reg [7:0] rdata, wdata, wdata2;
reg flag_1      = 1'b0;
reg flag_2      = 1'b0;
reg flag_fail   = 1'b0;
integer i, wait_cycle, wait_cycle_2;

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
    $display("--------------TEST-T15-BEGIN--------------");
    $display("-------------------------------------------\n");

    for (i = 1; i < 111; i = i + 1) begin
        $display("\n-------------------------------------");
        $display("             -CASE-%0d-              ", i);
        $display("-------------------------------------");
        flag_1 = 1'b0;
        flag_2 = 1'b0;
        top.ss_ins.system_reset();
        #50
        $display("-STEP-1-Reading-TDR-data-after-system-reset-");
        top.cpu.cpu_read_task(8'h00, rdata);
        $display("At %0t, (TEST) completed reading TDR's data = 'h%0h", $time, rdata);

        $display("----------------------------------");

        $display("-STEP-2-Writing-random-data-to-TDR-");
        // The minimum value for wdata should be 10 and should not be any other smaller number like 9, 8, 7, etc..
        // Because, the process of "Re-loading new value to Counter" includes 2 different steps:
        //                  Writing new value to TDR + Loading TDR to Counter
        // Total time required = at most 200 nano seconds / 10 pclk
        // If we set the random initial data to be less than 10, the counter would reach the UNDERFLOW state during the process of "Re-loading new value to Counter"
        // For example:
        // Case 1: wdata = 10   -> UDF flag is expected to raise after 21 pclk (line 76)
        //                      -> wait for half which is 21/2 = 10 pclk
        //                      -> config for re-loading: 10 + 10 = 20 pclk (At this point, the flag SURELY has not raised yet)
        //                      -> when we read TSR, the rdata would be 00 (PASSED)
        // Case 2: wdata = 9    -> UDF flag is expected to raise after 19 pclk (line 76)
        //                      -> wait for half which is 19/2 = 9 pclk
        //                      -> config for re-loading: 9 + 10 = 19 pclk (At this point, the flag has raised, but it takes 1 more pclk for TSR to receive the flag)
        //                      -> when we read TSR, the rdata would be 00 (PASSED), but I want to be precise (not dependent on the delay time), so I choose 10
        // Case 3: wdata = 8    -> UDF flag is expected to raise after 17 pclk (line 76)
        //                      -> wait for half which is 17/2 = 8 pclk
        //                      -> config for re-loading: 8 + 10 = 18 pclk (At this point, the flag has raised, and TSR has also received the flag)
        //                      -> when we read TSR, the rdata would be 'b01 (FAILED)
        wdata = $urandom_range(255, 10);
        top.cpu.cpu_write_task(8'h00, wdata);
        $display("At %0t, (TEST) completed writing data = 'h%0h to TDR", $time, wdata);

        $display("----------------------------------");

        $display("-STEP-3-Loading-TDR-to-Counter-");
        top.cpu.cpu_write_task(8'h01, 8'b1000_0000);
        $display("At %0t, (TEST) completed loading TDR to Counter", $time);

        $display("----------------------------------");

        $display("-STEP-4-Configuring-TCR-to-count-down-");
        // load[7] 0, updown[5] 1, en[4] 1, cks[1:0] 00 
        top.cpu.cpu_write_task(8'h01, 8'b0_0_1_1_00_00);
        $display("At %0t, (TEST) completed configuring TCR to count down", $time);

        $display("----------------------------------");
        
        // wait_cycle has to minus 1 because, up until this point the pclk2 has run 1 pclk.
        wait_cycle = wdata * 2 + 2 - 1;
        $display("\n-UDF-flag-is-theoretically-expected-to-raise-in-the-next-%0d-decimal-wait-cycles-\n", wait_cycle);

        $display("----------------------------------");
        
        $display("-STEP-5-Waiting-for-a-period-that-is-as-half-as-long-the-expected-wait-cycles-which-is-%0d-cycles-", wait_cycle/2);
        repeat(wait_cycle/2) begin
            @(posedge top.ss_ins.sys_clk);
        end
        $display("At %0t, (TEST) completed waiting for %0d cycles (decimal)", $time, wait_cycle/2);

        $display("----------------------------------");

        $display("-STEP-6-Loading-new-value-to-TDR-");
        // Line 116 - FORK JOIN for 2 cases - UNDERFLOW & NON-UNDERFLOW
        // We want to make sure the CPU's reading tasks of the two cases don't interfere each other
        // Hence, the difference between the 2 waiting cycles of the two cases should be at least 5 (CPU's reading task takes at most 100 ns to finish)
        // And also, non-underflow-wait-cycles = underflow-wait-cycles / 2
        // So the minimum value for wdata2 should be 5
        wdata2 = $urandom_range(255, 5);
        top.cpu.cpu_write_task(8'h00, wdata2);
        $display("At %0t, (TEST) completed writing data = 'h%0h to TDR", $time, wdata2);
        
        $display("----------------------------------");

        $display("-STEP-7-Loading-TDR-with-new-value-to-Counter-");
        top.cpu.cpu_write_task(8'h01, 8'b1000_0000);
        $display("At %0t, (TEST) completed loading TDR to Counter", $time);

        $display("----------------------------------");

        $display("-STEP-8-Configuring-TCR-to-count-down-");
        // load[7] 0, updown[5] 1, en[4] 1, cks[1:0] 00 
        top.cpu.cpu_write_task(8'h01, 8'b0_0_1_1_00_00);
        $display("At %0t, (TEST) completed configuring TCR to count down", $time);

        $display("----------------------------------");
        
        wait_cycle_2 = wdata2 * 2 + 2;                  // No need to minus 1 because pclk and pclk2 sync at this point
        $display("\n-With-the-new-value-UDF-flag-is-theoretically-expected-to-raise-in-the-next-%0d-decimal-wait-cycles-\n", wait_cycle_2);

        $display("----------------------------------");

        fork
            begin
                $display("-STEP-9-1-Waiting-for-a-period-that-is-as-half-as-long-the-new-expected-wait-cycles-which-is-%0d-cycles-", wait_cycle_2/2);
                $display("At %0t, (TEST) 9-1 started waiting for %0d cycles (decimal)", $time, wait_cycle_2/2);
                repeat(wait_cycle_2/2) begin
                    @(posedge top.ss_ins.sys_clk);
                end
                $display("At %0t, (TEST) 9-1 completed waiting for %0d cycles (decimal)", $time, wait_cycle_2/2);
                
                $display("-STEP-9-1-Reading-TSR-to-check-underflow-flag-");
                top.cpu.cpu_read_task(9'h02, rdata);
                $display("At %0t, (TEST) 9-1 completed reading TSR's data = 'b%b", $time, rdata);

                $display("-STEP-9-1-Comparing-");
                if (rdata[1] != 1'b1) begin
                    $display("No underflow flag was detected AS EXPECTED.");
                end
                else begin
                    flag_1 = 1'b1;
                    $display("Underflow flag was detected. UNEXPECTED result.");
                end
            end
            begin
                $display("-STEP-9-2-Waiting-until-the-UDF-flag-raises-");
                $display("At %0t, (TEST) 9-2 started waiting for %0d cycles (decimal)", $time, wait_cycle_2);
                repeat(wait_cycle_2) begin
                    @(posedge top.ss_ins.sys_clk);
                end
                $display("At %0t, (TEST) 9-2 completed waiting for %0d cycles (decimal)", $time, wait_cycle_2);

                $display("-STEP-9-2-Reading-TSR-to-check-underflow-flag-");
                top.cpu.cpu_read_task(9'h02, rdata);
                $display("At %0t, (TEST) completed reading TSR's data = 'b%b", $time, rdata);
                
                $display("-STEP-9-2-Comparing-");
                if (rdata[1] == 1'b1) begin
                    $display("Underflow flag was detected AS EXPECTED.");
                end
                else begin
                    flag_2 = 1'b1;
                    $display("No underflow flag was detected. UNEXPECTED result.");
                end
            end
        join

        #100
        top.timer_tb.get_result(flag_1 || flag_2);
    end

    $display("\nAt %0t", $time);
    $display("-------------------------------------------");
    $display("--------------TEST-T15-END----------------");
    $display("-------------------------------------------\n");
    $finish();
end

endmodule