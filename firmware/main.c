#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <irq.h>
#include <uart.h>
#include <console.h>
#include <generated/csr.h>

#define VECTOR_SIZE 8

// Endereços de CSR relativos (cada CSR ocupa 4 bytes)
#define CSR_PRODUTO_ESCALAR_A_OFFSET        0x00
#define CSR_PRODUTO_ESCALAR_B_OFFSET        0x20
#define CSR_PRODUTO_ESCALAR_START_OFFSET    0x40
#define CSR_PRODUTO_ESCALAR_DONE_OFFSET     0x44
#define CSR_PRODUTO_ESCALAR_RESULT_OFFSET   0x48

// -----------------------------------------------------------------------------
// Funções utilitárias para console 
// -----------------------------------------------------------------------------
static char *readstr(void)
{
    char c[2];
    static char s[64];
    static int ptr = 0;

    if(readchar_nonblock()) {
        c[0] = readchar();
        c[1] = 0;
        switch(c[0]) {
            case 0x7f:
            case 0x08:
                if(ptr > 0) {
                    ptr--;
                    putsnonl("\x08 \x08");
                }
                break;
            case 0x07:
                break;
            case '\r':
            case '\n':
                s[ptr] = 0x00;
                putsnonl("\n");
                ptr = 0;
                return s;
            default:
                if(ptr >= (sizeof(s) - 1))
                    break;
                putsnonl(c);
                s[ptr] = c[0];
                ptr++;
                break;
        }
    }
    return NULL;
}

static char *get_token(char **str)
{
    char *c, *d;
    c = (char *)strchr(*str, ' ');
    if(c == NULL) {
        d = *str;
        *str = *str + strlen(*str);
        return d;
    }
    *c = 0;
    d = *str;
    *str = c + 1;
    return d;
}

// -----------------------------------------------------------------------------
// Prompt, help, reboot e LED 
// -----------------------------------------------------------------------------
static void prompt(void)
{
    printf("RUNTIME>");
}

static void help(void)
{
    puts("Available commands:");
    puts("help                            - show commands");
    puts("reboot                          - reboot CPU");
    puts("led                             - toggle LED");
    puts("dot                             - compute dot product (produto escalar)");
}

static void reboot(void)
{
    ctrl_reset_write(1);
}

static void toggle_led(void)
{
    int i;
    printf("Invertendo LED...\n");
    i = leds_out_read();
    leds_out_write(!i);
}

// -----------------------------------------------------------------------------
// Função principal: produto escalar HW vs SW
// -----------------------------------------------------------------------------
static void calc_dot_product(void)
{
    uint32_t a[VECTOR_SIZE];
    uint32_t b[VECTOR_SIZE];
    uint64_t result_sw = 0;
    uint64_t result_hw = 0;

    printf("Digite os valores dos vetores A e B (%d elementos cada)\n", VECTOR_SIZE);

    for (int i = 0; i < VECTOR_SIZE; i++) {
        printf("A[%d] = ", i);
        scanf("%u", &a[i]);
    }

    for (int i = 0; i < VECTOR_SIZE; i++) {
        printf("B[%d] = ", i);
        scanf("%u", &b[i]);
    }

    // --- Produto escalar em software ---
    for (int i = 0; i < VECTOR_SIZE; i++) {
        result_sw += ((uint64_t)a[i]) * ((uint64_t)b[i]);
    }

    // --- Produto escalar em hardware ---
    volatile uint32_t *produto_escalar = (uint32_t*)(CSR_BASE + CSR_PRODUTO_ESCALAR_BASE);

    for (int i = 0; i < VECTOR_SIZE; i++) {
        produto_escalar[(CSR_PRODUTO_ESCALAR_A_OFFSET / 4) + i] = a[i];
        produto_escalar[(CSR_PRODUTO_ESCALAR_B_OFFSET / 4) + i] = b[i];
    }

    produto_escalar[CSR_PRODUTO_ESCALAR_START_OFFSET / 4] = 1;

    while (produto_escalar[CSR_PRODUTO_ESCALAR_DONE_OFFSET / 4] == 0);

    uint32_t low  = produto_escalar[CSR_PRODUTO_ESCALAR_RESULT_OFFSET / 4];
    uint32_t high = produto_escalar[CSR_PRODUTO_ESCALAR_RESULT_OFFSET / 4 + 1];
    result_hw = ((uint64_t)high << 32) | low;

    printf("\n--- RESULTADOS ---\n");
    printf("Produto escalar (software): %lld\n", result_sw);
    printf("Produto escalar (hardware): %lld\n", result_hw);

    if (result_hw == result_sw)
        printf("✅ Resultado OK! Hardware e software coincidem.\n");
    else
        printf("❌ ERRO: resultado do hardware difere do software!\n");
}

// -----------------------------------------------------------------------------
// Serviço de console (loop principal de comandos)
// -----------------------------------------------------------------------------
static void console_service(void)
{
    char *str;
    char *token;

    str = readstr();
    if(str == NULL) return;
    token = get_token(&str);

    if(strcmp(token, "help") == 0)
        help();
    else if(strcmp(token, "reboot") == 0)
        reboot();
    else if(strcmp(token, "led") == 0)
        toggle_led();
    else if(strcmp(token, "dot") == 0)
        calc_dot_product();
    else
        printf("Comando desconhecido. Digite 'help'.\n");

    prompt();
}

// -----------------------------------------------------------------------------
// main()
// -----------------------------------------------------------------------------
int main(void)
{
#ifdef CONFIG_CPU_HAS_INTERRUPT
    irq_setmask(0);
    irq_setie(1);
#endif
    uart_init();

    printf("\n==== Firmware Produto Escalar ====\n");
    help();
    prompt();

    while(1) {
        console_service();
    }

    return 0;
}
