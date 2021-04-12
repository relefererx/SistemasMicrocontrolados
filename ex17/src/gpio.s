        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

SYSCTL_RCGCGPIO_R       EQU     0x400FE608
SYSCTL_PRGPIO_R		EQU     0x400FEA08
PORTN_BIT               EQU     0001000000000000b ; bit 12 = Port N
PORTF_BIT               EQU     0000000000100000b ; bit 05 = Port F

GPIO_PORTN_DATA_R    	EQU     0x40064000
GPIO_PORTN_DIR_R     	EQU     0x40064400
GPIO_PORTN_DEN_R     	EQU     0x4006451C

GPIO_PORTF_DATA_R    	EQU     0x4005D000
GPIO_PORTF_DIR_R     	EQU     0x4005D400
GPIO_PORTF_DEN_R     	EQU     0x4005D51C

__iar_program_start
        
main    MOV R2, #PORTN_BIT
        MOV R3, #PORTF_BIT
	LDR R0, = SYSCTL_RCGCGPIO_R
	LDR R1, [R0] ; leitura do estado anterior
        ORR R2, R3  ; habilita port N e F
	ORR R1, R2  ; habilita todas as portas selecionadas anteriormente
	STR R1, [R0] ; escrita do novo estado

        LDR R0, =SYSCTL_PRGPIO_R
wait	LDR R2, [R0] ; leitura do estado atual
	TST R1, R2 ; clock das portas habilitadas?
	BEQ wait ; caso negativo, aguarda

        MOV R2, #00000011b ; bit 0 e 1 para porta N
        
	LDR R0, = GPIO_PORTN_DIR_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; bit de saída
	STR R1, [R0] ; escrita do novo estado

	LDR R0, = GPIO_PORTN_DEN_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita função digital
	STR R1, [R0] ; escrita do novo estado

        MOV R2, #00010001b ; bit 0 e 4 para porta F
        
	LDR R0, = GPIO_PORTF_DIR_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; bit de saída
	STR R1, [R0] ; escrita do novo estado

	LDR R0, = GPIO_PORTF_DEN_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita função digital
	STR R1, [R0] ; escrita do novo estado
        
        MOV R2, #00000000b ; estado inicial
 	LDR R0, = GPIO_PORTN_DATA_R
        LDR R1, [R0, #0x00C] ; acessa apenas PN0 e PN1
        AND R1, R2
        STR R1, [R0, #0x00C]

        MOV R5, #00000000b ; estado inicial
 	LDR R3, = GPIO_PORTF_DATA_R
        LDR R4, [R3, #0x044] ; acessa apenas PF0 e PF4
        AND R4, R5
        STR R4, [R3, #0x044]
        
        MOV R6, #00000000b ; estado inicial
        
loop	ADD R6, R6, #1

        MOV R4, #00000001b; Seleciona apenas o led PF0
        AND R4, R6
        STR R4, [R3, #0x004] ; utiliza a máscara 0000 0000 0100
        
        MOV R4, #00010000b; Seleciona apenas o led PF4
        LSL R7, R6, #3    ; desloca o numero para poder comparar com a posição do LED
        AND R4, R7
        STR R4, [R3, #0x040] ; utiliza a máscara 0000 0100 0000
        
        MOV R2, #00000001b; Seleciona apenas o led PN0
        LSR R7, R6, #2    ; desloca o numero para poder comparar com a posição do LED
        AND R2, R7
        STR R2, [R0, #0x004] ; utiliza a máscara 0000 0000 0100
        
        MOV R2, #00000010b; Seleciona apenas o led PN1
        LSR R7, R6, #2    ;desloca o numero para poder comparar com a posição do LED
        AND R2, R7
        STR R2, [R0, #0x008] ; utiliza a máscara 0000 0000 1000
        
        
        
theend   
        B loop

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
