module fetch_cycle_tb;

    logic clk;
    logic rst;
    logic PCSrcE;
    logic [31:0] PCTargetE;
    
    logic [31:0] InstrD;
    logic [31:0] PCD;
    logic [31:0] PCPlus4D;

    fetch_cycle DUT (
        .clk(clk),
        .rst(rst),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    initial begin
        $dumpfile("simulation.vcd"); // Creates the waveform data file
        $dumpvars(0, fetch_cycle_tb); // Dumps ALL signals inside this testbench module
        
        $display("Time\t rst\t PCSrcE\t PCTargetE\t PCD\t\t PCPlus4D\t InstrD");
        $monitor("%0t\t %b\t %b\t %h\t %h\t %h\t %h", 
                 $time, rst, PCSrcE, PCTargetE, PCD, PCPlus4D, InstrD);
    end

    initial begin
        // --- Initialize Inputs ---
        rst       = 1'b1; // Start high
        PCSrcE    = 1'b0;
        PCTargetE = 32'h0000_0000;
        #2; // Wait a tiny bit off-alignment

        // --- Scenario 1: Assert Active-Low Reset ---
        $display("\n--- [TB INFO] Asserting Reset ---");
        rst = 1'b0; 
        #15;        // Hold it across at least one clock edge
        
        // --- Scenario 2: Release Reset & Watch Normal Fetching ---
        $display("\n--- [TB INFO] Releasing Reset: Normal Fetching Starts ---");
        rst = 1'b1; 
        
        // Let it run for 4 clock cycles. PC should go: 0 -> 4 -> 8 -> C
        // Note: Because of your pipeline registers, the outputs (PCD) will lag by 1 cycle!
        #40; 

        // --- Scenario 3: Force a Branch / Jump ---
        $display("\n--- [TB INFO] Injecting a Branch Target ---");
        // Force the PC Mux to choose our custom target instead of PC+4
        PCSrcE    = 1'b1; 
        PCTargetE = 32'h0000_A000; 
        
        #10; // Wait 1 clock cycle for the target to get latched into PC_Module
        
        // --- Scenario 4: Return to Normal Fetching from the new Target ---
        $display("\n--- [TB INFO] Clearing Branch: Fetching sequentially from new target ---");
        PCSrcE    = 1'b0; 
        
        #30; // Let it run a few cycles to see if it counts up from A000 (A004, A008...)

        // --- Wrap Up ---
        $display("\n--- [TB INFO] Simulation Finished ---");
        $finish;
    end

endmodule
