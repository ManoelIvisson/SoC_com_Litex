#include <stdio.h>
#include <stdint.h>
#include "csr.h"    // Header gerado pelo LiteX

#define VECTOR_SIZE 8

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

    // Escreve os vetores no acelerador via CSR
    for (int i = 0; i < VECTOR_SIZE; i++) {
        *((volatile uint32_t*)(CSR_BASE + CSR_PRODUTO_ESCALAR_A0 + i*4)) = a[i];
        *((volatile uint32_t*)(CSR_BASE + CSR_PRODUTO_ESCALAR_B0 + i*4)) = b[i];
    }

    // Inicia o cálculo
    *((volatile uint32_t*)(CSR_BASE + CSR_PRODUTO_ESCALAR_START)) = 1;

    // Espera a conclusão
    while(*((volatile uint32_t*)(CSR_BASE + CSR_PRODUTO_ESCALAR_DONE)) == 0);

    // Lê o resultado (64 bits)
    uint32_t low  = *((volatile uint32_t*)(CSR_BASE + CSR_PRODUTO_ESCALAR_RESULT));
    uint32_t high = *((volatile uint32_t*)(CSR_BASE + CSR_PRODUTO_ESCALAR_RESULT + 4));
    result_hw = ((uint64_t)high << 32) | low;

    printf("Produto escalar via hardware: %lld\n", result_hw);

    return 0;
}
