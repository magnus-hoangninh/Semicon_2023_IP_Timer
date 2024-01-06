module system_signals(
    output reg sys_clk, sys_resetn
);

// initial begin
//   $display("At %0t, (SS) is being initiated", $time);
// end

initial begin
    sys_clk = 1'b0;
    forever #10 sys_clk =~ sys_clk;
end

initial begin
    sys_resetn = 1'b1;
    #20
    sys_resetn = 1'b0;
    #20
    sys_resetn = 1'b1;
end

task system_reset();
    begin
        sys_resetn = 1'b0;
        #20
        sys_resetn = 1'b1;
    end
endtask

endmodule
