// A basic 32-bit 2-to-1 Multiplexer
module mux2 (
    input  [31:0] d0, d1,
    input         s,
    output [31:0] y
);
    assign y = s ? d1 : d0;
endmodule


// A 32-bit 3-to-1 Multiplexer (This selects the forwarded data for ALU inputs)
module mux3 (
    input  [31:0] d0, d1, d2,
    input  [1:0]  s,
    output [31:0] y
);
    assign y = (s == 2'b00) ? d0 :
               (s == 2'b01) ? d1 :
               (s == 2'b10) ? d2 : 32'b0;
endmodule


// A standard 32-bit Pipeline Register (with synchronous reset)
module pipe_reg (
    input             clk, reset,
    input      [31:0] d,
    output reg [31:0] q
);
    always @(posedge clk) begin
        if (reset) q <= 32'b0;
        else       q <= d;
    end
endmodule
