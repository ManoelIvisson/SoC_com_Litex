# SoC com Litex - Acelerador de Produto Escalar

## Descrição do projeto

O presente projeto tem como objetivo criar um Sytem on Chip (SoC) com acelarador utilizando a ferramenta LiteX para o colorlight i5/colorlight i9, cujo contem o FPGA ECP5 da Lattice Semiconductor. O LiteX é um framework de criação de SoCs que possui nativamente integrado barramentos CSR (Control and Status Register), os quais foram usados para a conexão dos periféricos e para leituras de status do hardware.
  
Foi construído um acelerador de produto escalar devido a performance desse cálculo na CPU, pois caso o cálculo fosse processado por ela muitos ciclos de clock seriam necessários para a entrega do resultado. Logo, um acelarador dedicado a esse cálculo seria bem mais eficiente.  

## Arquitetura do SoC e mapa CSR

A arquitetura do SoC consiste em:

1. **CPU RISC-V (VexRiscV):** responsável por executar o firmware do sistema, controlar os periféricos e iniciar o acelerador de produto escalar.
2. **Barramento CSR (Control and Status Registers):** utilizado para comunicação entre a CPU e os periféricos. Os CSRs permitem leitura e escrita de registradores que controlam o estado do hardware e fornecem informações de status.
3. **Acelerador de Produto Escalar:** bloco customizado que realiza o cálculo do produto escalar entre dois vetores de 32 bits com 8 elementos cada. Como explicado na introdução, o acelerador foi desenvolvido para reduzir significativamente o número de ciclos de clock necessários para o cálculo em comparação à execução na CPU.

O **fluxo de operação** do acelerador é simples:

- A CPU escreve os vetores de entrada **A** e **B** nos registradores do acelerador via CSRs.
- Em seguida, a CPU dispara o cálculo através de um registrador de **start**.
- O acelerador processa o produto escalar em ciclos sequenciais e indica a conclusão por meio do registrador **done**.
- O resultado de 64 bits do produto escalar pode então ser lido via CSR pela CPU.

#### Mapa de CSRs do Acelerador de Produto Escalar

O acelerador possui os seguintes CSRs mapeados:

| Endereço (Offset) | Nome do CSR              | Descrição                                        | Largura  |
|------------------|------------------------|------------------------------------------------|----------|
| 0x00 – 0x1C      | `produto_escalar_a[i]` | Registradores de entrada do vetor A (i=0..7)   | 32 bits  |
| 0x20 – 0x3C      | `produto_escalar_b[i]` | Registradores de entrada do vetor B (i=0..7)   | 32 bits  |
| 0x40             | `start`                | Pulso para iniciar o cálculo                    | 1 bit    |
| 0x44             | `done`                 | Indica que o cálculo foi concluído             | 1 bit    |
| 0x48 – 0x4C      | `result`               | Resultado do produto escalar                    | 64 bits  |

Com este mapeamento, a CPU consegue gerenciar de forma simples e eficiente a operação do acelerador, garantindo alto desempenho sem sobrecarregar o processador principal com cálculos intensivos. O uso do barramento CSR do LiteX facilita a expansão futura do SoC, permitindo a adição de outros periféricos de maneira modular.

## Instruções para compilação

Aqui seguem as instruções para a compilação tanto do SoC quanto do firmware:

#### 1 - Clonando o repositório

    git clone https://github.com/ManoelIvisson/SoC_com_Litex/
    cd SoC_com_LiteX
#### 2 - 
