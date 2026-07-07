// Register File
module Register_File (
    input clk,
    input rst,
    input WE3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,
    output [31:0] RD1,
    output [31:0] RD2
);
    reg [31:0] rf [31:0];
    integer i;

    // Asynchronous reads. Hardwire register 0 to ground.
    assign RD1 = (A1 == 5'b00000) ? 32'b0 : rf[A1];
    assign RD2 = (A2 == 5'b00000) ? 32'b0 : rf[A2];

    // Synchronous writes
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            for (i = 0; i < 32; i = i + 1) begin
                rf[i] <= 32'b0;
            end
        end else if (WE3 && (A3 != 5'b00000)) begin
            rf[A3] <= WD3;
        end
    end
endmodule

// Sign Extend
module Sign_Extend (
    input [31:0] In,
    input [1:0] ImmSrc,
    output reg [31:0] Imm_Ext
);
    always @(*) begin
        case(ImmSrc)
            // I-Type (e.g., ADDI, LW)
            2'b00: Imm_Ext = {{20{In[31]}}, In[31:20]}; 
            
            // S-Type (e.g., SW)
            2'b01: Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]}; 
            
            // B-Type (e.g., BEQ)
            2'b10: Imm_Ext = {{20{In[31]}}, In[7], In[30:25], In[11:8], 1'b0}; 
            
            // J-Type (e.g., JAL)
            2'b11: Imm_Ext = {{12{In[31]}}, In[19:12], In[20], In[30:21], 1'b0}; 
            
            default: Imm_Ext = 32'bx; // Unknown state
        endcase
    end
endmodule

// Control Unit Top
module Control_Unit_Top (
    input [6:0] Op,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg RegWrite,
    output reg [1:0] ImmSrc,
    output reg ALUSrc,
    output reg MemWrite,
    output reg ResultSrc,
    output reg Branch,
    output reg [2:0] ALUControl
);
    always @(*) begin
        // Default assignments to prevent inferred latches
        RegWrite = 1'b0;
        ImmSrc = 2'b00;
        ALUSrc = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 1'b0;
        Branch = 1'b0;
        ALUControl = 3'b000;

        case(Op)
            7'b0110011: begin // R-type instructions
                RegWrite = 1'b1;
                // Distinguish based on funct3 and funct7 bit 5
                if (funct3 == 3'b000) begin
                    if (funct7[5] == 1'b1) ALUControl = 3'b001; // SUB
                    else ALUControl = 3'b000;                   // ADD
                end
                // Expand for XOR, OR, AND, etc.
            end
            
            7'b0010011: begin // I-type ALU instructions
                RegWrite = 1'b1;
                ALUSrc = 1'b1;   // Force ALU to use the immediate value
                ImmSrc = 2'b00;  // I-Type extension
                ALUControl = 3'b000; // ADD logic for ADDI
            end

        endcase
    end
endmodule
