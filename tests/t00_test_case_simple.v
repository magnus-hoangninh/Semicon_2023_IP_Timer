module t00_test_case_simple;

reg [7:0] rdata;
reg flag_fail;

/***********************************|
|       INSTANTIATING MODULES       |
|***********************************/
timer_tb top();

/***********************************|
|            TESTING CODE           |
|***********************************/
initial begin
    #100
    // Load 100 to TDR
    top.cpu.cpu_write_task(8'h00, 8'h64);
    // Load TDR to counter
    // TCR[7] = 1
    top.cpu.cpu_write_task(8'h01, 8'b1000_0000);
    top.cpu.cpu_read_task(8'h01, rdata);
    // Load TCR Enable = 1, updown = 0, cks = 1(4T)
    top.cpu.cpu_write_task(8'h01, 8'b0_0_0_1_00_01);
    // Start counting
    $display("Stating counting up....");
    
    // Wait 300 pclk then check ovf_flag
    repeat(300)
    begin
        @(posedge top.pclk);
        top.cpu.cpu_read_task(8'h02, rdata);
        if (rdata[0] != 1'b0) begin
            $display("Overflowed detected! FAILED");
            flag_fail = 1'b1;
        end
        else begin
            $display("Not overflowed! PASSED");
        end
    end
    // Wait 330 more pclk then check ovf_flag
    repeat(330)
    begin
        @(posedge top.pclk);
        top.cpu.cpu_read_task(8'h02, rdata);
        if (rdata[0] != 1'b0) begin
            $display("Overflowed detected! FAILED");
            flag_fail = 1'b1;
        end
        else begin
            $display("Not overflowed! PASSED");
        end
    end

    #10
    top.timer_tb.get_result(flag_fail);

    // #50
    $finish();
end

endmodule