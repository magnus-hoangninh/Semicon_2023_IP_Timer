`define HIGH        1'b1
`define LOW         1'b0

module select_clock (
    // Inputs
    input           sc_clk,
    input           sc_reset_n,
    input   [1:0]   sc_cks,

    //Outputs
    output  reg     selected_internal_clock
);

/***********************************|
|I.        INTERNAL  SIGNALS        |
|***********************************/
reg     clk2, clk4, clk8, clk16;
wire    q2, q4, q8, q16;

/***********************************|
|II.           BEHAVIOUR            |
|***********************************/
/*************************|
|1.     Choose clock      |
|*************************/
always @(*) begin
    case (sc_cks)
        2'b00: selected_internal_clock = q2;
        2'b01: selected_internal_clock = q4; 
        2'b10: selected_internal_clock = q8; 
        2'b11: selected_internal_clock = q16;
    endcase
end

/*************************|
|2.         CLK2          |
|*************************/
always @(posedge sc_clk or negedge sc_reset_n) begin
    if(~sc_reset_n) begin
        clk2 <= `LOW;
    end
    else begin
        clk2 <= ~clk2;
    end
end
assign q2 = clk2;

/*************************|
|3.         CLK4          |
|*************************/
always @(posedge clk2 or negedge sc_reset_n) begin
    if(~sc_reset_n) begin
        clk4 <= `LOW;
    end
    else begin
        clk4 <= ~clk4;
    end
end
assign q4 = clk4;

/*************************|
|4.         CLK8          |
|*************************/
always @(posedge clk4 or negedge sc_reset_n) begin
    if(~sc_reset_n) begin
        clk8 <= `LOW;
    end
    else begin
        clk8 <= ~clk8;
    end
end
assign q8 = clk8;

/*************************|
|5.         CLK16         |
|*************************/
always @(posedge clk8 or negedge sc_reset_n) begin
    if(~sc_reset_n) begin
        clk16 <= `LOW;
    end
    else begin
        clk16 <= ~clk16;
    end
end
assign q16 = clk16;
    
endmodule