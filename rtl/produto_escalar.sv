// verilog/dot_product.sv
// Produto escalar entre dois vetores de 8 elementos (32-bit signed).
// Implementação sequencial (1 MAC por ciclo) - latência: ~8 ciclos (+1).
// Entradas via CSR: a0..a7, b0..b7 (cada 32 bits)
// start : inicia o cálculo (pulso de 1 para iniciar)
// Saídas via CSR: done (1 bit), result (signed 64 bits)

module produto_escalar (
    input  logic         clk,
    input  logic         rst,

    // control
    input  logic         start,
    output logic         done,
    output logic signed [63:0] result,

    // a[0..7]
    input  logic signed [31:0] a0,
    input  logic signed [31:0] a1,
    input  logic signed [31:0] a2,
    input  logic signed [31:0] a3,
    input  logic signed [31:0] a4,
    input  logic signed [31:0] a5,
    input  logic signed [31:0] a6,
    input  logic signed [31:0] a7,

    // b[0..7]
    input  logic signed [31:0] b0,
    input  logic signed [31:0] b1,
    input  logic signed [31:0] b2,
    input  logic signed [31:0] b3,
    input  logic signed [31:0] b4,
    input  logic signed [31:0] b5,
    input  logic signed [31:0] b6,
    input  logic signed [31:0] b7
);

    // Local regs
    logic signed [31:0] a_reg [0:7];
    logic signed [31:0] b_reg [0:7];
    logic signed [63:0] acc;
    logic [3:0] idx;
    logic busy;
    logic done_q;
    logic signed [63:0] result_q;

    // Default assignments
    assign done = done_q;
    assign result = result_q;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            busy <= 1'b0;
            done_q <= 1'b0;
            acc <= 64'sd0;
            idx <= 4'd0;
            result_q <= 64'sd0;
        end else begin
            if (start && !busy) begin
                // latch inputs into internal arrays
                a_reg[0] <= a0; a_reg[1] <= a1; a_reg[2] <= a2; a_reg[3] <= a3;
                a_reg[4] <= a4; a_reg[5] <= a5; a_reg[6] <= a6; a_reg[7] <= a7;
                b_reg[0] <= b0; b_reg[1] <= b1; b_reg[2] <= b2; b_reg[3] <= b3;
                b_reg[4] <= b4; b_reg[5] <= b5; b_reg[6] <= b6; b_reg[7] <= b7;

                acc <= 64'sd0;
                idx <= 4'd0;
                busy <= 1'b1;
                done_q <= 1'b0;
                result_q <= 64'sd0;
            end else if (busy) begin
                // compute MAC for current idx
                acc <= acc + ( $signed(a_reg[idx]) * $signed(b_reg[idx]) );
                if (idx == 4'd7) begin
                    // finished after this cycle
                    busy <= 1'b0;
                    done_q <= 1'b1;
                    result_q <= acc + ( $signed(a_reg[7]) * $signed(b_reg[7]) );
                end else begin
                    idx <= idx + 1;
                end
            end else begin
                // idle: keep done asserted until next start or until software clears by writing new inputs/start
                if (!start)
                    done_q <= 1'b0;
            end
        end
    end

endmodule
