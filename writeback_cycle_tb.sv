module writeback_cycle_tb();

    logic        clk;
    logic        rst;
    
    logic        ResultSrcW;
    logic [31:0] PCPlus4W;
    logic [31:0] ALU_ResultW;
    logic [31:0] ReadDataW;
    
    logic [31:0] ResultW;

    writeback_cycle dut (
        .clk(clk),
        .rst(rst),
        .ResultSrcW(ResultSrcW),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW),
        .ResultW(ResultW)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst         = 1'b1;
        ResultSrcW  = 0;
        PCPlus4W    = 0; 
        ALU_ResultW = 0;
        ReadDataW   = 0;

        $display("--- Applying Reset ---");
        #2  rst = 1'b0; 
        #10 rst = 1'b1; 

        @(posedge clk);
        #1; 
        $display("--- Test 1: Select ALU Result ---");
        PCPlus4W    = 32'h0000_0004;
        ALU_ResultW = 32'hAAAA_AAAA;
        ReadDataW   = 32'hBBBB_BBBB;
        ResultSrcW  = 1'b0;       

        @(posedge clk);
        #1; 
        $display("--- Test 2: Select Memory Read Data ---");
        ResultSrcW  = 1'b1;       

        @(posedge clk);
        #1;

        @(posedge clk);
        $display("--- Simulation Complete ---");
        $finish;
    end

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, writeback_cycle_tb);
        
        $monitor("Time: %0t | rst: %b | ResultSrcW: %b | ALU_ResultW: %h | ReadDataW: %h || ResultW: %h", 
                 $time, rst, ResultSrcW, ALU_ResultW, ReadDataW, ResultW);
    end

endmodule
