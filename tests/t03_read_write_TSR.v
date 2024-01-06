module t03_read_write_TSR;

reg [7:0] rdata, wdata;
reg flag_fail = 1'b0;
integer i;
reg ovf_flag, udf_flag;

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
    $display("--------------TEST-T03-BEGIN--------------");
    $display("-------------------------------------------\n");

    for (i = 1; i < 51; i = i + 1) begin
        $display("\n-------------------------------------");
        $display("             -CASE-%0d-              ", i);
        $display("-------------------------------------");
        top.ss_ins.system_reset();
        #50
        $display("-STEP-1-Reading-TSR-data-after-system-reset-");
        top.cpu.cpu_read_task(8'h02, rdata);
        $display("At %0t, (TEST) completed reading TSR's data = 'b%b", $time, rdata);

        $display("----------------------------------");

        $display("-STEP-2-Writing-random-data-to-TSR-");
        ovf_flag    = $urandom_range(0,1);
        udf_flag    = $urandom_range(0,1);
        wdata       = {6'b00_00_00, udf_flag, ovf_flag};
        $display("(TEST) wdata = %b", wdata);
        top.cpu.cpu_write_task(8'h02, wdata);
        $display("At %0t, (TEST) completed writing data = 'b%b to TSR", $time, wdata);

        $display("----------------------------------");

        $display("-STEP-3-Reading-TSR-written-data-");
        top.cpu.cpu_read_task(8'h02, rdata);
        $display("At %0t, (TEST) completed reading TSR's data = 'b%b", $time, rdata);

        $display("----------------------------------");

        $display("-STEP-4-Comparing-");
        #20
        if(rdata != wdata) begin
            if(wdata[1:0] == 2'b11) begin
                $display("\n-RESULT- rdata != wdata AS EXPECTED because wdata[1:0] = 2'b11\n");
            end
            else begin
                flag_fail = 1'b1;
                $display("\n-RESULT- rdata != wdata\n");
            end
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
    $display("--------------TEST-T03-END----------------");
    $display("-------------------------------------------\n");
    $finish();
end

endmodule