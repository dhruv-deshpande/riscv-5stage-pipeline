module Mux (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        s,
    output logic [31:0] c
);
    assign c = s ? b : a;
endmodule

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

module PC_Adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] c
);
    assign c = a + b;
endmodule

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
