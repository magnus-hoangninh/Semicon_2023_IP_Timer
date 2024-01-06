module t01_read_write_TDR;

reg [7:0] rdata, wdata;
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
    $display("--------------TEST-T01-BEGIN--------------");
    $display("-------------------------------------------\n");

    for (i = 1; i < 51; i = i + 1) begin
        $display("\n-------------------------------------");
        $display("             -CASE-%0d-              ", i);
        $display("-------------------------------------");
        top.ss_ins.system_reset();
        #50
        $display("-STEP-1-Reading-TDR-data-after-system-reset-");
        top.cpu.cpu_read_task(8'h00, rdata);
        $display("At %0t, (TEST) completed reading TDR's data = 'h%0h", $time, rdata);

        $display("----------------------------------");

        $display("-STEP-2-Writing-random-data-to-TDR-");
        wdata = $random();
        top.cpu.cpu_write_task(8'h00, wdata);
        $display("At %0t, (TEST) completed writing data = 'h%0h to TDR", $time, wdata);

        $display("----------------------------------");

        $display("-STEP-3-Reading-TDR-written-data-");
        top.cpu.cpu_read_task(8'h00, rdata);
        $display("At %0t, (TEST) completed reading TDR's data = 'h%0h", $time, rdata);

        $display("----------------------------------");

        $display("-STEP-4-Comparing-");
        #20
        if(rdata != wdata) begin
            flag_fail = 1'b1;
            $display("\n-RESULT- rdata != wdata\n");
        end
        else begin
            $display("\n-RESULT- rdata = wdata AS EXPECTED\n");
        end
        #20
        top.timer_tb.get_result(flag_fail);
    end

    #50
    $display("\nAt %0t", $time);
    $display("-------------------------------------------");
    $display("--------------TEST-T01-END----------------");
    $display("-------------------------------------------\n");
    $finish();
end

endmodule