module t13_pause_countdown_pclk2;

reg [7:0] rdata, wdata;
reg flag_1      = 1'b0;
reg flag_2      = 1'b0;
reg flag_fail   = 1'b0;
integer i, wait_cycle;

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
    $display("--------------TEST-T13-BEGIN--------------");
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
        // The minimum value for wdata should be 5 and should not be any other smaller number like 4, 3, 2, etc..
        // Because, the process of "Pausing the Counter" (which is writing "0" to the "en" bit of TCR) requires at most 100 nano seconds
        // (In this test, we will wait for as half as long of the expected UDF-flag-rising wait_cycle)
        // If we set the random initial data to be less than 5, the counter would reach the UNDERFLOW state during the process of "Pausing the Counter"
        // For example:
        // Case 1: wdata = 5 -> UDF flag is expected to raise after 11 pclk (line 75)
        //                   -> wait for half which is 11/2 = 5 pclk
        //                   -> config for pausing: 5 + 5 = 10 pclk (At this point, the flag SURELY has not raised yet)
        //                   -> when we read TSR, the rdata would be 00 (PASSED)
        // Case 2: wdata = 4 -> UDF flag is expected to raise after 9 pclk (line 75)
        //                   -> wait for half which is 9/2 = 4 pclk
        //                   -> config for pausing: 4 + 5 = 9 pclk (At this point, the flag has raised, but it takes 1 more pclk for TSR to receive the flag)
        //                   -> when we read TSR, the rdata would be 00 (PASSED), but I want to be precise (not dependent on the delay time), so I choose 5
        // Case 3: wdata = 3 -> UDF flag is expected to raise after 7 pclk (line 75)
        //                   -> wait for half which is 7/2 = 3 pclk
        //                   -> config for pausing: 3 + 5 = 8 pclk (At this point, the flag has raised, and TSR has also received the flag)
        //                   -> when we read TSR, the rdata would be 'b01 (FAILED)
        wdata = $urandom_range(255, 5);
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

        $display("-STEP-6-Configuring-TCR-to-pause-and-delay");
        // load[7] 0, updown[5] 1, en[4] 0, cks[1:0] 00 
        top.cpu.cpu_write_task(8'h01, 8'b0_0_1_0_00_00);
        $display("At %0t, (TEST) completed configuring TCR to pause", $time);
        repeat(100) begin
            @(posedge top.ss_ins.sys_clk);
        end
        $display("At %0t, (TEST) completed pausing for 100 pclk", $time);

        $display("----------------------------------");

        $display("-STEP-7-Reading-TSR-to-check-underflow-flag-");
        top.cpu.cpu_read_task(8'h02, rdata);
        $display("At %0t, (TEST) completed reading TSR's data = 'b%b", $time, rdata);

        $display("----------------------------------");
        
        $display("-STEP-8-Comparing-");
        if (rdata[1] != 1'b1) begin
            $display("No underflow flag was detected AS EXPECTED.");
        end
        else begin
            flag_1 = 1'b1;
            $display("Underflow flag was detected. UNEXPECTED result.");
        end

        $display("----------------------------------");

        $display("-STEP-9-Configuring-TCR-to-keep-counting-down-");
        //load[7] 0, updown[5] 1, en[4] 1, cks[1:0] 00 
        top.cpu.cpu_write_task(8'h01, 8'b0_0_1_1_00_00);
        $display("At %0t, (TEST) completed configuring TCR to keep counting down", $time);

        $display("----------------------------------");
                
        $display("-STEP-10-Waiting-until-UDF-flag-raises-");
        repeat(wait_cycle/2) begin
            @(posedge top.ss_ins.sys_clk);
        end
        $display("At %0t, (TEST) completed waiting for %0d cycles (decimal)", $time, wait_cycle/2);

        $display("----------------------------------");

        $display("-STEP-11-Reading-TSR-to-check-underflow-flag-");
        top.cpu.cpu_read_task(8'h02, rdata);
        $display("At %0t, (TEST) completed reading TSR's data = 'b%b", $time, rdata);
        
        $display("----------------------------------");

        $display("-STEP-12-Comparing-");
        if (rdata[1] == 1'b1) begin
            $display("Underflow flag was detected AS EXPECTED.");
        end
        else begin
            flag_2 = 1'b1;
            $display("No underflow flag was detected. UNEXPECTED result.");
        end

        #100
        top.timer_tb.get_result(flag_1 || flag_2);
    end

    $display("\nAt %0t", $time);
    $display("-------------------------------------------");
    $display("--------------TEST-T13-END----------------");
    $display("-------------------------------------------\n");
    $finish();
end

endmodule