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
    input  logic         i_start,
    output logic         o_done,
    output logic signed [63:0] o_result,

    // a[0..7]
    input  logic signed [31:0] i_a0,
    input  logic signed [31:0] i_a1,
    input  logic signed [31:0] i_a2,
    input  logic signed [31:0] i_a3,
    input  logic signed [31:0] i_a4,
    input  logic signed [31:0] i_a5,
    input  logic signed [31:0] i_a6,
    input  logic signed [31:0] i_a7,

    // b[0..7]
    input  logic signed [31:0] i_b0,
    input  logic signed [31:0] i_b1,
    input  logic signed [31:0] i_b2,
    input  logic signed [31:0] i_b3,
    input  logic signed [31:0] i_b4,
    input  logic signed [31:0] i_b5,
    input  logic signed [31:0] i_b6,
    input  logic signed [31:0] i_b7
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
    assign o_done = done_q;
    assign o_result = result_q;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            busy <= 1'b0;
            done_q <= 1'b0;
            acc <= 64'sd0;
            idx <= 4'd0;
            result_q <= 64'sd0;
        end else begin
            if (i_start && !busy) begin
                // latch inputs into internal arrays
                a_reg[0] <= i_a0; a_reg[1] <= i_a1; a_reg[2] <= i_a2; a_reg[3] <= i_a3;
                a_reg[4] <= i_a4; a_reg[5] <= i_a5; a_reg[6] <= i_a6; a_reg[7] <= i_a7;
                b_reg[0] <= i_b0; b_reg[1] <= i_b1; b_reg[2] <= i_b2; b_reg[3] <= i_b3;
                b_reg[4] <= i_b4; b_reg[5] <= i_b5; b_reg[6] <= i_b6; b_reg[7] <= i_b7;

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
                if (!i_start)
                    done_q <= 1'b0;
            end
        end
    end

endmodule
