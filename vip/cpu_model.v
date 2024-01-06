`define DELAY_TIME  2
`define HIGH        1'b1
`define LOW         1'b0
`define RESET_VALUE 8'h00

module cpu_model (
    // Inputs
    input           cpu_clk,
    input           cpu_reset_n,
    input           cpu_slverr,
    input           cpu_ready,
    input   [7:0]   cpu_rdata,

    // Output
    output  reg         cpu_sel,
    output  reg         cpu_write,
    output  reg         cpu_enable,
    output  reg  [7:0]  cpu_address,
    output  reg  [7:0]  cpu_wdata
);

// initial begin
//   $display("At %0t, (CPU) is being initiated", $time);
// end

/***********************************|
|I.           BEHAVIOUR             |
|***********************************/
/*************************|
|1.     Writing data      |
|*************************/
task cpu_write_task(
    input [7:0] address, wdata
);
    begin
        $display("At %0t, (CPU) cpu_write task started", $time);
        // Set-up phase
        @(posedge cpu_clk);
        #`DELAY_TIME
        cpu_sel     =   `HIGH;
        cpu_write   =   `HIGH;
        cpu_enable  =   `LOW;
        cpu_address =   address;
        cpu_wdata   =   wdata;
        $display("At %0t, (CPU) set-up phase completed. cpu_address = 'h%0h, cpu_wdata = 'h%0h",
         $time, cpu_address, cpu_wdata);

        // Access phase
        @(posedge cpu_clk);
        #`DELAY_TIME
        cpu_enable  =   `HIGH;
        $display("At %0t, (CPU) access phase completed", $time);

        // End-of-access phase
        @(posedge cpu_clk);
        while(!cpu_ready) begin
            @(posedge cpu_clk);
        end
        $display("At %0t, (CPU) received ready signals", $time);

        if(cpu_slverr) begin
            $display("At %0t, (CPU), incorrect address", $time);
        end

        cpu_sel     =   `LOW;
        cpu_write   =   `LOW;
        cpu_enable  =   `LOW;
        cpu_address =   `RESET_VALUE;
        cpu_wdata   =   `RESET_VALUE;
        $display("At %0t, (CPU) end-of-access phase completed. cpu_write task finished", $time);
    end
endtask

/*************************|
|2.     Reading data      |
|*************************/
task cpu_read_task(
    input   [7:0]   address,
    output  [7:0]   rdata
);
    begin
        $display("At %0t, (CPU) cpu_read task started", $time);
        // Set-up phase
        @(posedge cpu_clk);
        #`DELAY_TIME
        cpu_sel     =   `HIGH;
        cpu_write   =   `LOW;
        cpu_enable  =   `LOW;
        cpu_address =   address;
        $display("At %0t, (CPU) set-up phase completed. cpu_address = 'h%0h",
         $time, cpu_address);

        // Access phase
        @(posedge cpu_clk);
        #`DELAY_TIME
        cpu_enable  =   `HIGH;
        $display("At %0t, (CPU) access phase completed", $time);

        // End-of-access phase
        @(posedge cpu_clk);
        while(!cpu_ready) begin
            @(posedge cpu_clk);
        end
        rdata   =   cpu_rdata;
        #`DELAY_TIME
        cpu_sel     =   `LOW;
        cpu_write   =   `LOW;
        cpu_enable  =   `LOW;
        cpu_address =   `RESET_VALUE;
        cpu_wdata   =   `RESET_VALUE;

        if(cpu_slverr) begin
            $display("At %0t, (CPU), incorrect address", $time);
        end
        
        $display("At %0t, (CPU) end-of-access phase completed. cpu_read task finished. rdata = 'h%0h",
         $time, rdata);
    end

endtask

endmodule