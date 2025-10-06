from litex_boards.targets.colorlight_i5 import BaseSoC as ColorlightBase
from produto_escalar_wrapper import ProdutoEscalar

class Soc(ColorlightBase):
    def __init__(self, **kwargs):
        # Chama o construtor do SoC base
        super().__init__(**kwargs)

        # Adiciona o acelerador produto escalar
        self.submodules.produto_escalar = ProdutoEscalar()
