        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start
        
        ;; main program begins here
main    MOV R0, #15
        MOV R1, #7
        MOV LR, PC                   ;; guarda o PC no LR para retomada do momento da chamada da subrotina
        CBNZ R1, Mul16b              ;; chama a subrotina de multiplicação
        
        B fim
        

fim     B fim
        ;; main program ends here


Mul16b  LSR R3, R1, #1   ;; faz a decomposição por 2 do multiplicador e guarda no R3 o numero de vezes que deve ser somado
        LSL R4, R3, #1   ;; multiplica por 2 o multiplicador decomposto para ver se há resto/ se é multiplo de 2
        SUBS R4, R1, R4  ;; calcula o resto
        LSL R5, R0, #1   ;; multiplica por 2 o numero que se deseja ser multiplicado
        MOV R6, PC       ;; guarda o momento de partida para retomada após a multiplicação
        B mult           ;; chama a multiplicação
        CBNZ R4, SOMA1   ;; verifica se tem resto e se tiver faz a soma do numero nao multiplicado por 2 para completar a multiplicacao
        MOV PC, LR       ;; coloca no PC o LR para saida da subrotina
        
mult    ADD R2, R2, R5   ;; é feita a soma do numero multiplicado por 2 
        SUBS R3, R3, #1  ;; laço usando o r3 como indice para fazer as somas do numero multiplicado por 2
        CBZ R3, saida    ;; confere se r3 foi zerado e chama a função de saida do laço
        
loop    B mult           ;; laço para realizar a soma

saida   MOV PC, R6       ;; coloca no PC o momento em que foi chamado a multiplicação para continuidade do programa

SOMA1   ADD R2, R2, R0   ;; soma o numero nao multiplicado por 2 para finalizar a multiplicacao
        MOV PC, LR       ;; coloca no PC o LR para saida da subrotina

        

        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END
