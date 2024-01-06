module t02_read_write_TCR;

reg [7:0] rdata, wdata;
reg flag_fail = 1'b0;
integer i;
reg load, up_down, en, cks1, cks0;

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
    $display("--------------TEST-T02-BEGIN--------------");
    $display("-------------------------------------------\n");

    for (i = 1; i < 51; i = i + 1) begin
        $display("\n-------------------------------------");
        $display("             -CASE-%0d-              ", i);
        $display("-------------------------------------");
        top.ss_ins.system_reset();
        #50
        $display("-STEP-1-Reading-TCR-data-after-system-reset-");
        top.cpu.cpu_read_task(8'h01, rdata);
        $display("At %0t, (TEST) completed reading TCR's data = 'b%b", $time, rdata);

        $display("----------------------------------");

        $display("-STEP-2-Writing-random-data-to-TCR-");
        load    = $urandom_range(0,1);
        up_down = $urandom_range(0,1);
        en      = $urandom_range(0,1);
        cks1    = $urandom_range(0,1);
        cks0    = $urandom_range(0,1);
        wdata   = {load, 1'b0, up_down, en, 1'b0, 1'b0, cks1, cks0};
        $display("(TEST) wdata = %b", wdata);
        top.cpu.cpu_write_task(8'h01, wdata);
        $display("At %0t, (TEST) completed writing data = 'b%b to TCR", $time, wdata);

        $display("----------------------------------");

        $display("-STEP-3-Reading-TCR-written-data-");
        top.cpu.cpu_read_task(8'h01, rdata);
        $display("At %0t, (TEST) completed reading TCR's data = 'b%b", $time, rdata);

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
    $display("--------------TEST-T02-END----------------");
    $display("-------------------------------------------\n");
    $finish();
end

endmodule