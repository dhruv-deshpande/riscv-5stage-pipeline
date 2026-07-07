// 1. The 2-to-1 Multiplexer
module Mux (
    input [31:0] a,
    input [31:0] b,
    input s,
    output [31:0] c
);
    assign c = s ? b : a;
endmodule


// 2. The Program Counter Register
module PC_Module (
    input clk,
    input rst,
    input [31:0] PC_Next,
    output reg [31:0] PC
);
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0)
            PC <= 32'h00000000;
        else
            PC <= PC_Next;
    end
endmodule


// 3. The Program Counter Adder (+4)
module PC_Adder (
    input [31:0] a,
    input [31:0] b,
    output [31:0] c
);
    assign c = a + b;
endmodule


// 4. Fake Instruction Memory for Testing
module Instruction_Memory (
    input rst,
    input [31:0] A,
    output [31:0] RD
);
    // A simple look-up table to simulate reading instructions from memory addresses
    // Hardcoding a few distinct dummy values so we can see them change!
    assign RD = (rst == 1'b0)      ? 32'h00000000 :
                (A == 32'h00000000) ? 32'h01100013 : // Fake Instr at PC = 0
                (A == 32'h00000004) ? 32'h02200023 : // Fake Instr at PC = 4
                (A == 32'h00000008) ? 32'h03300033 : // Fake Instr at PC = 8
                (A == 32'h0000000C) ? 32'h04400043 : // Fake Instr at PC = 12
                (A == 32'h0000A000) ? 32'hBEEFCAFE : // Fake Instr at Branch Target PC = 0xA000
                                      32'h00000000;  // Default
endmodule
