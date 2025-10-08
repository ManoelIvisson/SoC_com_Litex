from migen import *
from litex.gen import *
from litex.soc.interconnect.csr import *

from migen import *
from litex.gen import *
from litex.soc.interconnect.csr import *

# Para usar LiteXModule, certifique-se de que o litex.gen foi importado (já está)
# A classe deve herdar de LiteXModule para usar a sintaxe 'LiteXModule'
class ProdutoEscalar(LiteXModule):
    def __init__(self, platform):
        # 1. Adiciona a fonte
        platform.add_source("rtl/produto_escalar.sv")

        # 2. Definição dos CSRs

        # Registradores de entrada
        self.a = [CSRStorage(32, name=f"a{i}") for i in range(8)]
        self.b = [CSRStorage(32, name=f"b{i}") for i in range(8)]
        # Usamos 'pulse=True' na entrada 'start' para garantir que seja apenas um pulso
        # (Se o seu bloco espera um pulso, isso é recomendado)
        self.start = CSRStorage(1, name="start", fields=[CSRField("start_pulse", size=1, pulse=True)])

        # Registradores de saída
        self.o_done = CSRStatus(1, name="o_done")
        self.o_result = CSRStatus(64, name="o_result")

        # 3. Definição dos Sinais Intermediários

        # Sinais de entrada
        i_start_sig = Signal()
        
        # Sinais de saída
        o_done_sig = Signal()
        o_result_sig = Signal(64)

        # 4. Instância do Módulo SystemVerilog (Conecta APENAS a sinais)

        self.specials += Instance("produto_escalar",
            i_clk=ClockSignal(),
            i_rst=ResetSignal(),
            
            # Entradas de controle
            i_start=i_start_sig, # Conectado ao sinal intermediário
            
            # Entradas de dados (Podem ser conectadas diretamente ao .storage do CSR)
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
            
            # Saídas (Conectadas aos sinais intermediários)
            o_done=o_done_sig,
            o_result=o_result_sig
        )

        # 5. Mapeamento dos CSRs (Conexão do SINAL intermediário ao STATUS/STORAGE do CSR)

        self.comb += [
            # Entrada de controle: CSR -> Sinal Interno
            i_start_sig.eq(self.start.fields.start_pulse),
            
            # Saídas: Sinal Interno -> CSR Status
            self.o_done.status.eq(o_done_sig),
            self.o_result.status.eq(o_result_sig)
        ]