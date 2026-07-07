module memory_cycle_tb();

    logic        clk;
    logic        rst;

    logic        RegWriteM;
    logic        MemWriteM;
    logic        ResultSrcM;
    logic [4:0]  RD_M;
    logic [31:0] PCPlus4M;
    logic [31:0] WriteDataM;
    logic [31:0] ALU_ResultM;

    logic        RegWriteW;
    logic        ResultSrcW;
    logic [4:0]  RD_W;
    logic [31:0] PCPlus4W;
    logic [31:0] ALU_ResultW;
    logic [31:0] ReadDataW;

    memory_cycle dut (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period (100 MHz)
    end

    initial begin
        rst = 1'b1;
        RegWriteM = 0; MemWriteM = 0; ResultSrcM = 0;
        RD_M = 0; PCPlus4M = 0; WriteDataM = 0; ALU_ResultM = 0;

        $display("--- Applying Reset ---");
        #2  rst = 1'b0; // Assert reset
        #10 rst = 1'b1; // De-assert reset

        @(posedge clk);
        #1; 
        $display("--- Test 1: Write to Memory ---");
        MemWriteM   = 1'b1;          // Enable memory write
        ALU_ResultM = 32'h0000_0020; // Memory Address
        WriteDataM  = 32'hDEAD_BEEF; // Data to write

        RegWriteM   = 1'b1;           
        ResultSrcM  = 1'b0;
        RD_M        = 5'd15;
        PCPlus4M    = 32'h0000_0104;

        @(posedge clk);
        #1; 
        $display("--- Test 2: Read from Memory ---");
        MemWriteM   = 1'b0;          // Disable write (Read mode)
        ALU_ResultM = 32'h0000_0020; // Read from the same address we just wrote to

        RegWriteM   = 1'b0;
        ResultSrcM  = 1'b1;
        RD_M        = 5'd16;
        PCPlus4M    = 32'h0000_0108;

        @(posedge clk);
        #1;

        @(posedge clk);
        $display("--- Simulation Complete ---");
        $finish;
    end

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, memory_cycle_tb);
        
        $monitor("Time: %0t | rst: %b | MW: %b | Addr_M: %h | WD_M: %h || RegW_W: %b | RD_W: %0d | ALU_W: %h | ReadData_W: %h", 
                 $time, rst, MemWriteM, ALU_ResultM, WriteDataM, RegWriteW, RD_W, ALU_ResultW, ReadDataW);
    end

endmodule
