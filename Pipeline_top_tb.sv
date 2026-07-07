module Pipeline_top_tb();

    logic clk;
    logic rst;

    // Instantiate the complete 5-stage pipelined processor core
    Pipeline_top dut (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        $display("--- Starting Integrated RISC-V Pipeline Simulation ---");

        rst = 1'b1;
        #2  rst = 1'b0; 
        #10 rst = 1'b1; 

        #500; 

        $display("--- Simulation Complete ---");
        $finish;
    end

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, Pipeline_top_tb);

        $monitor("Time: %0t | rst: %b | PC_Dec: %h | Inst_Dec: %h | PC_Ex: %h | FwdAE/BE: %b/%b | ALU_OutM: %h | WB_Res: %h", 
         $time, rst, dut.PCD, dut.InstrD, dut.PCE, dut.ForwardAE, dut.ForwardBE, dut.ALU_ResultM, dut.ResultW);
    end

endmodule
