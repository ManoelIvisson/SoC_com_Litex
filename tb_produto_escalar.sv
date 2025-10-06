module tb_produto_escalar;
    // sinais de entrada/saída
    reg clk;
    reg rst;
    reg start;
    reg signed [7:0] a [0:7];
    reg signed [7:0] b [0:7];
    wire signed [63:0] result;
    wire done;

    // variáveis auxiliares
    integer i;
    reg signed [63:0] sw;

    // DUT
    produto_escalar dut (
      .clk(clk),
      .rst(rst),
      .i_start(start),
      .o_done(done),
      .o_result(result),

      .i_a0(a[0]), .i_a1(a[1]), .i_a2(a[2]), .i_a3(a[3]),
      .i_a4(a[4]), .i_a5(a[5]), .i_a6(a[6]), .i_a7(a[7]),

      .i_b0(b[0]), .i_b1(b[1]), .i_b2(b[2]), .i_b3(b[3]),
      .i_b4(b[4]), .i_b5(b[5]), .i_b6(b[6]), .i_b7(b[7])
    );


    // clock
    always #5 clk = ~clk;

    // teste
    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        #10 rst = 0;

        // atribui valores de teste
        for (i = 0; i < 8; i = i + 1) begin
            a[i] = i;
            b[i] = 8 - i;
        end

        start = 1;
        #10 start = 0;

        // espera terminar
        wait(done);

        // calcula resultado de referência (software)
        sw = 64'sd0;
        for (i = 0; i < 8; i = i + 1) begin
            sw = sw + $signed(a[i]) * $signed(b[i]);
        end

        $display("SW RESULT: %0d", sw);
        $display("HW RESULT: %0d", result);

        if (result !== sw)
            $display("❌ TEST FAILED");
        else
            $display("✅ TEST PASSED");

        $finish;
    end
endmodule
