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
