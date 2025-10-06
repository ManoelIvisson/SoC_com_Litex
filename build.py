#!/usr/bin/env python3

from soc import Soc
from litex.soc.integration.builder import Builder

# Instancia o SoC
soc = Soc()

# Cria o builder
builder = Builder(soc, csr_csv="csr.csv")

# Gera apenas CSR
builder.build(run=False)  # run=False evita tentar gerar o bitstream
