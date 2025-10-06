from migen import *
from litex.soc.interconnect.csr import *

class ProdutoEscalar(Module, AutoCSR):
    def __init__(self):
        # Registradores de entrada
        self.a = [CSRStorage(32, name=f"a{i}") for i in range(8)]
        self.b = [CSRStorage(32, name=f"b{i}") for i in range(8)]
        self.start = CSRStorage(1, name="start")

        # Registradores de saída
        self.done = CSRStatus(1, name="done")
        self.result = CSRStatus(64, name="result")

        # Instancia o módulo SystemVerilog
        self.specials += Instance("dot_product",
            i_clk=ClockSignal(),
            i_rst=ResetSignal(),
            i_start=self.start.storage,
            i_a0=self.a[0].storage,
            i_a1=self.a[1].storage,
            i_a2=self.a[2].storage,
            i_a3=self.a[3].storage,
            i_a4=self.a[4].storage,
            i_a5=self.a[5].storage,
            i_a6=self.a[6].storage,
            i_a7=self.a[7].storage,
            i_b0=self.b[0].storage,
            i_b1=self.b[1].storage,
            i_b2=self.b[2].storage,
            i_b3=self.b[3].storage,
            i_b4=self.b[4].storage,
            i_b5=self.b[5].storage,
            i_b6=self.b[6].storage,
            i_b7=self.b[7].storage,
            o_done=self.done.status,
            o_result=self.result.status
        )
