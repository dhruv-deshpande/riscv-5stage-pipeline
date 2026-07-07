module decode_cycle_tb();

    logic clk;
    logic rst;
    logic RegWriteW;
    logic [4:0] RDW;
    logic [31:0] InstrD;
    logic [31:0] PCD;
    logic [31:0] PCPlus4D;
    logic [31:0] ResultW;

    logic RegWriteE;
    logic ALUSrcE;
    logic MemWriteE;
    logic ResultSrcE;
    logic BranchE;
    logic [2:0] ALUControlE;
    logic [31:0] RD1_E;
    logic [31:0] RD2_E;
    logic [31:0] Imm_Ext_E;
    logic [4:0] RS1_E;
    logic [4:0] RS2_E;
    logic [4:0] RD_E;
    logic [31:0] PCE;
    logic [31:0] PCPlus4E;

    decode_cycle dut (
        .clk(clk),
        .rst(rst),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteW),
        .RDW(RDW),
        .ResultW(ResultW),
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
        .RS1_E(RS1_E),
        .RS2_E(RS2_E)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 0; 
        RegWriteW = 0;
        RDW = 5'b0;
        InstrD = 32'b0;
        PCD = 32'b0;
        PCPlus4D = 32'b0;
        ResultW = 32'b0;

        #20 rst = 1;

        #10;
        InstrD = 32'h002081B3; 
        PCD = 32'h00000010;
        PCPlus4D = 32'h00000014;

        #10;
        InstrD = 32'h00508213;
        PCD = 32'h00000014;
        PCPlus4D = 32'h00000018;

        #10;
        RegWriteW = 1;          // Enable write
        RDW = 5'd1;             // Write to register x1
        ResultW = 32'hDEADBEEF; // Data to write
        
        #10;
        RegWriteW = 0;

        #30;
        $finish;
    end

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, decode_cycle_tb);
        
        $monitor("Time: %0t | rst: %b | InstrD: %h | PCE: %h | RD_E: %d | RS1_E: %d", 
                 $time, rst, InstrD, PCE, RD_E, RS1_E);
    end

endmodule
