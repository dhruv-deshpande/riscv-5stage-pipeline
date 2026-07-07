// ==========================================
// 1. Multiplexers
// ==========================================

// 2-to-1 Multiplexer
module Mux (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        s,
    output logic [31:0] c
);
    assign c = s ? b : a;
endmodule

// 3-to-1 Multiplexer
module Mux_3_by_1 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic [1:0]  s,
    output logic [31:0] d
);
    always_comb begin
        case(s)
            2'b00: d = a;
            2'b01: d = b;
            2'b10: d = c;
            default: d = 32'h00000000;
        endcase
    end
endmodule


// ==========================================
// 2. Program Counter Logic
// ==========================================

// The Program Counter Register
module PC_Module (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] PC_Next,
    output logic [31:0] PC
);
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0)
            PC <= 32'h00000000;
        else
            PC <= PC_Next;
    end
endmodule

// The Program Counter Adder (+4)
module PC_Adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] c
);
    assign c = a + b;
endmodule


// ==========================================
// 3. Memory Blocks
// ==========================================

// Actual Instruction Memory using a .hex file
module Instruction_Memory (
    input  logic        rst,
    input  logic [31:0] A,
    output logic [31:0] RD
);
    // Create an array of 256 32-bit words
    logic [31:0] rom [0:255]; 

    // Load the hex file into the rom array at the start of the simulation
    initial begin
        // Make sure this name exactly matches your saved file!
        $readmemh("memfile.hex", rom); 
    end

    // Read the memory. 
    assign RD = (rst == 1'b0) ? 32'h00000000 : rom[A[9:2]];

endmodule

// Data Memory
module Data_Memory (
    input  logic        clk,
    input  logic        rst,
    input  logic        WE,
    input  logic [31:0] WD,
    input  logic [31:0] A,
    output logic [31:0] RD
);
    logic [31:0] ram [0:255];
    
    assign RD = ram[A[9:2]]; 

    always_ff @(posedge clk) begin
        if (WE) begin
            ram[A[9:2]] <= WD;
        end
    end
endmodule

// Register File
module Register_File (
    input  logic        clk,
    input  logic        rst,
    input  logic        WE3,
    input  logic [4:0]  A1,
    input  logic [4:0]  A2,
    input  logic [4:0]  A3,
    input  logic [31:0] WD3,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);
    logic [31:0] rf [31:0];
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


// ==========================================
// 4. Execution & Control Logic
// ==========================================

// Sign Extend
module Sign_Extend (
    input  logic [31:0] In,
    input  logic [1:0]  ImmSrc,
    output logic [31:0] Imm_Ext
);
    always @(*) begin
        case(ImmSrc)
            2'b00: Imm_Ext = {{20{In[31]}}, In[31:20]}; // I-Type
            2'b01: Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]}; // S-Type
            2'b10: Imm_Ext = {{20{In[31]}}, In[7], In[30:25], In[11:8], 1'b0}; // B-Type
            2'b11: Imm_Ext = {{12{In[31]}}, In[19:12], In[20], In[30:21], 1'b0}; // J-Type
            default: Imm_Ext = 32'bx; 
        endcase
    end
endmodule

// ALU
module ALU (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [2:0]  ALUControl,
    output logic [31:0] Result,
    output logic        OverFlow,
    output logic        Carry,
    output logic        Zero,
    output logic        Negative
);
    always_comb begin
        case(ALUControl)
            3'b000: Result = A + B;       // ADD
            3'b001: Result = A - B;       // SUB
            3'b010: Result = A & B;       // AND
            3'b011: Result = A | B;       // OR
            3'b100: Result = A ^ B;       // XOR
            3'b101: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            default: Result = 32'd0;
        endcase
    end

    assign Zero     = (Result == 32'd0);
    assign Negative = Result[31];
    assign Carry    = 1'b0; 
    assign OverFlow = 1'b0; 
endmodule

// Control Unit Top
module Control_Unit_Top (
    input  logic [6:0] Op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic       RegWrite,
    output logic [1:0] ImmSrc,
    output logic       ALUSrc,
    output logic       MemWrite,
    output logic       ResultSrc,
    output logic       Branch,
    output logic [2:0] ALUControl
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
                if (funct3 == 3'b000) begin
                    if (funct7[5] == 1'b1) ALUControl = 3'b001; // SUB
                    else ALUControl = 3'b000;                   // ADD
                end
            end
            
            7'b0010011: begin // I-type ALU instructions
                RegWrite = 1'b1;
                ALUSrc = 1'b1;   
                ImmSrc = 2'b00;  
                ALUControl = 3'b000; 
            end
        endcase
    end
endmodule
