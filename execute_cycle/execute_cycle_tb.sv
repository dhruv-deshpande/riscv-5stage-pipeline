module execute_cycle_tb();

    logic clk;
    logic rst;
    logic RegWriteE;
    logic ALUSrcE;
    logic MemWriteE;
    logic ResultSrcE;
    logic BranchE;
    logic [2:0] ALUControlE;
    logic [31:0] RD1_E, RD2_E, Imm_Ext_E;
    logic [4:0] RD_E;
    logic [31:0] PCE, PCPlus4E;
    logic [31:0] ResultW;
    logic [1:0] ForwardA_E, ForwardB_E;

    logic PCSrcE;
    logic RegWriteM;
    logic MemWriteM;
    logic ResultSrcM;
    logic [4:0] RD_M;
    logic [31:0] PCPlus4M;
    logic [31:0] WriteDataM;
    logic [31:0] ALU_ResultM;
    logic [31:0] PCTargetE;

    execute_cycle dut (
        .clk(clk),
        .rst(rst),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .ResultW(ResultW),
        .ForwardA_E(ForwardA_E),
        .ForwardB_E(ForwardB_E)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin

        rst = 0; 
        RegWriteE = 0; ALUSrcE = 0; MemWriteE = 0; ResultSrcE = 0; BranchE = 0;
        ALUControlE = 3'b000;
        RD1_E = 32'h0; RD2_E = 32'h0; Imm_Ext_E = 32'h0;
        RD_E = 5'h0;
        PCE = 32'h0; PCPlus4E = 32'h0; ResultW = 32'h0;
        ForwardA_E = 2'b00; ForwardB_E = 2'b00;

        #15 rst = 1; 

        @(posedge clk); 

        $display("\n--- Test Case 1: Standard ALU Operation (No Forwarding) ---");
        RegWriteE = 1;
        ALUSrcE = 0;          
        ALUControlE = 3'b000; 
        RD1_E = 32'd15;
        RD2_E = 32'd25;
        RD_E = 5'd10;
        ForwardA_E = 2'b00;
        ForwardB_E = 2'b00;

        @(posedge clk);
        #1;

        $display("\n--- Test Case 2: Forwarding from Writeback & Immediate Operand ---");
        ALUSrcE = 1;       
        Imm_Ext_E = 32'd50;
        ForwardA_E = 2'b01;   
        ResultW = 32'd100;   
        
        @(posedge clk);

        $display("\n--- Test Case 3: Branch Evaluation (Branch Taken) ---");
        BranchE = 1;
        ALUSrcE = 0;
        ForwardA_E = 2'b00;
        ForwardB_E = 2'b00;
        RD1_E = 32'd42;
        RD2_E = 32'd42;      
        ALUControlE = 3'b001; 
        
        PCE = 32'h00000100;
        Imm_Ext_E = 32'h00000010;

        
        @(posedge clk);
        BranchE = 0; 

        #20;
        $display("\nSimulation Complete.");
        $finish;
    end

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, execute_cycle_tb);

        $monitor("Time=%0t | rst=%b | FwdA=%b FwdB=%b ALUSrc=%b | PCSrcE=%b PCTargetE=%h | ALU_ResultM=%0d (Pipelined)", 
                 $time, rst, ForwardA_E, ForwardB_E, ALUSrcE, PCSrcE, PCTargetE, ALU_ResultM);
    end

endmodule
