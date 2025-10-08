#include <stdio.h>
#include <stdint.h>
#include <generated/csr.h>  // Header gerado pelo LiteX

#define VECTOR_SIZE 8

// Cada CSR ocupa 4 bytes (32 bits)
#define CSR_PRODUTO_ESCALAR_A_OFFSET        0x00  // A[0..7]
#define CSR_PRODUTO_ESCALAR_B_OFFSET        0x20  // B[0..7], começa após 8*4 bytes
#define CSR_PRODUTO_ESCALAR_START_OFFSET    0x40  // 1 word
#define CSR_PRODUTO_ESCALAR_DONE_OFFSET     0x44  // 1 word
#define CSR_PRODUTO_ESCALAR_RESULT_OFFSET   0x48  // 64 bits (2 words)

int main() {
    uint32_t a[VECTOR_SIZE] = {1,2,3,4,5,6,7,8};
    uint32_t b[VECTOR_SIZE] = {8,7,6,5,4,3,2,1};
    uint64_t result_hw = 0;
    uint64_t result_sw = 0;

    // Calcula o produto escalar em software para comparação
    for (int i = 0; i < VECTOR_SIZE; i++) {
        result_sw += ((int64_t)a[i]) * ((int64_t)b[i]);
    }

    printf("Produto escalar em software: %lld\n", result_sw);

    // Ponteiro base para o bloco de CSRs do produto escalar
    volatile uint32_t *produto_escalar = (uint32_t*)(CSR_BASE + CSR_PRODUTO_ESCALAR_BASE);

    // Escreve os vetores no acelerador via CSR
    for (int i = 0; i < VECTOR_SIZE; i++) {
        produto_escalar[(CSR_PRODUTO_ESCALAR_A_OFFSET / 4) + i] = a[i];
        produto_escalar[(CSR_PRODUTO_ESCALAR_B_OFFSET / 4) + i] = b[i];
    }

    // Inicia o cálculo
    produto_escalar[CSR_PRODUTO_ESCALAR_START_OFFSET / 4] = 1;

    // Espera a conclusão
    while (produto_escalar[CSR_PRODUTO_ESCALAR_DONE_OFFSET / 4] == 0);

    // Lê o resultado (64 bits)
    uint32_t low  = produto_escalar[CSR_PRODUTO_ESCALAR_RESULT_OFFSET / 4];
    uint32_t high = produto_escalar[CSR_PRODUTO_ESCALAR_RESULT_OFFSET / 4 + 1];
    result_hw = ((uint64_t)high << 32) | low;

    printf("Produto escalar via hardware: %lld\n", result_hw);

    return 0;
}
