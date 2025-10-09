// Produto escalar entre dois vetores de 8 elementos (32-bit signed).
// Implementação sequencial (1 MAC por ciclo) - latência: ~8 ciclos (+1).

module produto_escalar (
    input  logic         clk,
    input  logic         rst,
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
    logic [2:0] idx;       // <= corrigido (era 4 bits)
    logic busy;
    logic done_q;
    logic signed [63:0] result_q;

    assign done = done_q;
    assign result = result_q;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            busy <= 1'b0;
            done_q <= 1'b0;
            acc <= 64'sd0;
            idx <= 3'd0;
            result_q <= 64'sd0;
        end else begin
            if (start && !busy) begin
                // latch inputs
                a_reg[0] <= a0; a_reg[1] <= a1; a_reg[2] <= a2; a_reg[3] <= a3;
                a_reg[4] <= a4; a_reg[5] <= a5; a_reg[6] <= a6; a_reg[7] <= a7;
                b_reg[0] <= b0; b_reg[1] <= b1; b_reg[2] <= b2; b_reg[3] <= b3;
                b_reg[4] <= b4; b_reg[5] <= b5; b_reg[6] <= b6; b_reg[7] <= b7;

                acc <= 64'sd0;
                idx <= 3'd0;
                busy <= 1'b1;
                done_q <= 1'b0;
                result_q <= 64'sd0;
            end else if (busy) begin
                acc <= acc + ( $signed(a_reg[idx]) * $signed(b_reg[idx]) );
                if (idx == 3'd7) begin
                    busy <= 1'b0;
                    done_q <= 1'b1;
                    result_q <= acc + ( $signed(a_reg[7]) * $signed(b_reg[7]) );
                end else begin
                    idx <= idx + 1;
                end
            end else begin
                if (!start)
                    done_q <= 1'b0;
            end
        end
    end
endmodule
