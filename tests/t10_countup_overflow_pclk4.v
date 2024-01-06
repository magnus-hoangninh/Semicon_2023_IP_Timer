module t10_countup_overflow_pclk4;

reg [7:0] rdata, wdata;
reg flag_1      = 1'b0;
reg flag_2      = 1'b0;
reg flag_fail   = 1'b0;
integer i, wait_cycle, random_wait_cycle;

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
    $display("--------------TEST-T10-BEGIN--------------");
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
        wdata = $urandom_range(254, 0);                 // Check line 61 for knowing why the minimum value of wdata should be 254
        top.cpu.cpu_write_task(8'h00, wdata);
        $display("At %0t, (TEST) completed writing data = 'h%0h to TDR", $time, wdata);

        $display("----------------------------------");

        $display("-STEP-3-Loading-TDR-to-Counter-");
        top.cpu.cpu_write_task(8'h01, 8'b1000_0000);
        $display("At %0t, (TEST) completed loading TDR to Counter", $time);

        $display("----------------------------------");

        $display("-STEP-4-Configuring-TCR-to-count_up-");
        // load[7] 0, updown[5] 0, en[4] 1, cks[1:0] 01 
        top.cpu.cpu_write_task(8'h01, 8'b0_0_0_1_00_01);
        $display("At %0t, (TEST) completed configuring TCR to count up", $time);

        $display("----------------------------------");
        
        // wait_cycle has to minus 1 because, up until this point the pclk4 has run 1 pclk.
        wait_cycle = (255 - wdata) * 4 + 4 - 1;
        $display("\n-OVF-flag-is-theoretically-expected-to-raise-in-the-next-%0d-decimal-wait-cycles-\n", wait_cycle);

        // maximum value of random_wait_cycle has to be smaller wait_cycle at least 5
        // because we don't want the two reading tasks of the underflow case and the non-underflow case
        // to interfere each other (CPU's reading task requires at most 100 nano senconds / 5 pclk to finish)

        // Note: if we set the difference to be 4 or even 3, the results of NON-UNDERFLOW cases might also be PASSED (but NOT Expected)
        // for the reason that in register modules, the default read data is 8'h00, we can try setting the value to 8'hxx, 
        // then the results would be SUCCESFULLY FAILED (or Expected)
        random_wait_cycle = $urandom_range(wait_cycle - 5, 0);

        $display("----------------------------------");
        
        fork
            begin
                $display("-STEP-5-1-Waiting-for-a-random-number-of-cycles-");
                $display("At %0t, (TEST) 5-1 started waiting for %0d cycles (decimal)", $time, random_wait_cycle);
                repeat(random_wait_cycle) begin
                    @(posedge top.ss_ins.sys_clk);
                end
                $display("At %0t, (TEST) 5-1 completed waiting for %0d cycles (decimal)", $time, random_wait_cycle);
                
                $display("-STEP-5-1-Reading-TSR-to-check-overflow-flag-");
                top.cpu.cpu_read_task(8'h02, rdata);
                $display("At %0t, (TEST) 5-1 completed reading TSR's data = 'b%b", $time, rdata);

                $display("-STEP-5-1-Comparing-");
                if (rdata[0] != 1'b1) begin
                    $display("No overflow flag was detected AS EXPECTED.");
                end
                else begin
                    flag_1 = 1'b1;
                    $display("Overflow flag was detected. UNEXPECTED result.");
                end
            end
            begin
                $display("-STEP-5-2-Waiting-until-the-OVF-flag-raises-");
                $display("At %0t, (TEST) 5-2 started waiting for %0d cycles (decimal)", $time, wait_cycle);
                repeat(wait_cycle) begin
                    @(posedge top.ss_ins.sys_clk);
                end
                $display("At %0t, (TEST) 5-2 completed waiting for %0d cycles (decimal)", $time, wait_cycle);

                $display("-STEP-5-2-Reading-TSR-to-check-overflow-flag-");
                top.cpu.cpu_read_task(8'h02, rdata);
                $display("At %0t, (TEST) completed reading TSR's data = 'b%b", $time, rdata);
                
                $display("-STEP-5-2-Comparing-");
                if (rdata[0] == 1'b1) begin
                    $display("Overflow flag was detected AS EXPECTED.");
                end
                else begin
                    flag_2 = 1'b1;
                    $display("No overflow flag was detected. UNEXPECTED result.");
                end
            end
        join

        #100
        top.timer_tb.get_result(flag_1 || flag_2);
    end

    $display("\nAt %0t", $time);
    $display("-------------------------------------------");
    $display("--------------TEST-T10-END----------------");
    $display("-------------------------------------------\n");
    $finish();
end

endmodule