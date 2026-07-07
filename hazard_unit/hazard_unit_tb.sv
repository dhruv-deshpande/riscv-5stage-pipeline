module hazard_unit_tb;

    logic clk;
    logic rst;
    logic RegWriteM;
    logic RegWriteW;
    logic [4:0] RD_M;
    logic [4:0] RD_W;
    logic [4:0] Rs1_E;
    logic [4:0] Rs2_E;
    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;

    // Instantiate Unit Under Test (UUT)
    hazard_unit dut (
        .rst(rst),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .RD_M(RD_M),
        .RD_W(RD_W),
        .Rs1_E(Rs1_E),
        .Rs2_E(Rs2_E),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );

    // 1. Clock Generator Block
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // 2. Stimulus Block
    initial begin
        $display("--- Starting Pipeline Simulation ---");

        // Set initial safe states
        RegWriteM = 0; RegWriteW = 0;
        RD_M = 0; RD_W = 0; Rs1_E = 0; Rs2_E = 0;

        // Active-low Reset sequence matching your timeline
        rst = 1'b1;
        #2  rst = 1'b0; // Enter reset state
        #10 rst = 1'b1; // Exit reset state

        // --- TEST 1: Normal Flow (No Hazards) ---
        RegWriteM = 0; RegWriteW = 0; 
        RD_M = 5'd0;   RD_W = 5'd0; 
        Rs1_E = 5'd1;  Rs2_E = 5'd2;
        #10;

        // --- TEST 2: EX/MEM Hazard (Forward to Rs1) ---
        RegWriteM = 1; RegWriteW = 0; 
        RD_M = 5'd10;  RD_W = 5'd0; 
        Rs1_E = 5'd10; Rs2_E = 5'd2;
        #10; // Expected: ForwardAE = 2'b10

        // --- TEST 3: MEM/WB Hazard (Forward to Rs2) ---
        RegWriteM = 0; RegWriteW = 1; 
        RD_M = 5'd0;   RD_W = 5'd15; 
        Rs1_E = 5'd1;  Rs2_E = 5'd15;
        #10; // Expected: ForwardBE = 2'b01

        // --- TEST 4: Zero-Register Protection (x0 check) ---
        RegWriteM = 1; RegWriteW = 0; 
        RD_M = 5'd0;   RD_W = 5'd0; 
        Rs1_E = 5'd0;  Rs2_E = 5'd0;
        #10; // Expected: ForwardAE = 2'b00

        #100; // Let the simulation run for a tracking window

        $display("--- Simulation Complete ---");
        $finish;
    end

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, hazard_unit_tb);

        $monitor("Time: %0t | rst: %b | RegWM: %b | RegWW: %b | Rs1_E: %d | Rs2_E: %d | FwdAE: %b | FwdBE: %b", 
                 $time, rst, RegWriteM, RegWriteW, Rs1_E, Rs2_E, ForwardAE, ForwardBE);
    end

endmodule
