module tb_produto_escalar;
    reg clk;
    reg rst;
    reg start;
    reg signed [31:0] a [0:7];   
    reg signed [31:0] b [0:7];  
    wire signed [63:0] result;
    wire done;

    integer i;
    reg signed [63:0] sw;

    produto_escalar dut (
        .clk(clk), .rst(rst), .start(start),
        .done(done), .result(result),
        .a0(a[0]), .a1(a[1]), .a2(a[2]), .a3(a[3]),
        .a4(a[4]), .a5(a[5]), .a6(a[6]), .a7(a[7]),
        .b0(b[0]), .b1(b[1]), .b2(b[2]), .b3(b[3]),
        .b4(b[4]), .b5(b[5]), .b6(b[6]), .b7(b[7])
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start = 0;
        #10 rst = 0;

        for (i = 0; i < 8; i = i + 1) begin
            a[i] = i;
            b[i] = 8 - i;
        end

        start = 1; #10 start = 0;
        wait(done);

        sw = 0;
        for (i = 0; i < 8; i = i + 1)
            sw = sw + a[i] * b[i];

        $display("RESULTADO SOFTWARE: %0d", sw);
        $display("RESULTADO HARDWARE: %0d", result);
        if (result !== sw)
            $display("❌ TESTE FALHOU");
        else
            $display("✅ TESTE PASSOU");
        $finish;
    end
endmodule
