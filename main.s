;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        Meriç Baglayan
;        150190056
;        BLG 212E Microprocessor Systems
;        Homework 2
;        ARM Cortex M0+ assembly code that
;            implements and measures the
;            running time of Bubble Sort
;            algorithm.
;        In progress as of 2023-12-22
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                THUMB                           ;instruct the assembler to interpret following code as thumb instructions
                AREA main, CODE, READONLY       ;declare new area
                
                
                ALIGN                           ;align code within appropriate boundaries        
                ENTRY                           ;declare as entry point
                EXPORT __main                   ;declare __main symbol to be used by linker
        
SYST_CSR        EQU 0xE000E010                  ;give symbolic name SYST_CSR to address of SysTick Control and Status Register
SYST_RVR        EQU 0xE000E014                  ;give symbolic name SYST_RVR to address of SysTick Reload Value Register
SYST_CVR        EQU 0xE000E018                  ;give symbolic name SYST_CVR to address of Current Value Register

RELOAD          EQU 0xF9FFF                     ;give symbolic name RELOAD to reload value for 64 MHz and period of 16 ms
START           EQU 2_111                       ;give symbolic name START to will set CLKSOURCE, TICKINT and ENABLE values of Control and Status Register to 1

__main          PROC                            ;declare start of procedure 'main'

                BL timer_init                   ;branch with link to timer_init procedure to initialize systick timer
                
                MOVS R0, #8                     ;set main loop iterator to 8
                B m_cmp                         ;branch to loop comparison
        
m_body          BL memcpy
                BL save_start                   ;branch with link to save_start procedure to save start time to memory
                BL bubblesort                   ;branch with link to bubblesort procedure
                BL save_exec                    ;branch with link to save_exec procedure to save execution time to memory
                ADDS R0, R0, #4                 ;increment main loop iterator


m_cmp           PUSH {R1}
                LDR R1, =size
                CMP R0, R1                      ;compare iterator with size
                POP {R1}
                BLS m_body                      ;branch to m_body if R0 is lower than or same as size
        
        
                BL timer_stop                   ;branch to timer_stop to stop systick timer
        
stop            B    stop                       ;infinite loop to signify end of program
        
                ENDP                            ;declare end of procedure
                
memcpy          PROC                            ;declare start of procedure 'memcpy'
                ;;;;;;
                ;arguments:
                ;R1 = destination
                ;R2 = source
                ;R3 = iterator
                ;R0 = size
                ;R0 will not be considered as a scratch
                ;;;;;;
                PUSH {R1-R5}                    ;save registers in stack
                LDR R1, =sorted_array           ;load destionation address into R1
                LDR R2, =array                  ;load source address into R2
                MOVS R3, #0                     ;initialize R3 as iterator with value 0
                B memcpy_cmp                    ;branch to comparison
                
memcpy_body     LDR R4, [R2, R3]                ;load source value into R4
                STR R4, [R1, R3]                ;store the contents of R4 into destination
                ADDS R3, R3, #4                 ;increment iterator

memcpy_cmp      CMP R3, R0                      ;compare R3 with R0
                BCC memcpy_body                 ;branch to loop body if R3 is less than R0

                POP {R1-R5}                     ;pop back saved registers
                BX LR                           ;branch back to caller
                ENDP                            ;declare end of procedure
        
timer_init      PROC                            ;declare start of procedure 'timer_init'

                PUSH {R0-R3}                    ;save registers in stack

                LDR R0, =SYST_CSR               ;load SysTick Control and Status Register address into R0
                LDR R1, =SYST_RVR               ;load SysTick Reload Value Register address into R1
                LDR R2, =RELOAD                 ;load RELOAD value into R2
                LDR R3, =START                  ;load START value into R3

                STR R2, [R1]                    ;store RELOAD value in Reload Value Register
                STR R3, [R0]                    ;store START value in Control and Status Register
                
                POP {R0-R3}                     ;pop back saved registers

                BX LR                           ;branch back to caller
                ENDP                            ;declare end of procedure
        
timer_stop      PROC                            ;declare start of procedure 'timer_stop'

                BX LR                           ;branch back to caller
                ENDP                            ;declare end of procedure
        
save_start      PROC                            ;declare start of procedure 'save_start'               

                BX LR                           ;branch back to caller
                ENDP                            ;declare end of procedure
        
save_exec       PROC                            ;declare start of procedure 'save_exec'

                BX LR                           ;branch back to caller
                ENDP                            ;declare end of procedure
        
bubblesort      PROC                            ;declare start of procedure 'bubblesort'. R0 is the iterator
                PUSH {LR}

outer_loop_init MOVS R1, #0                     ;R1 = i (iterator for the outer loop)
                B    outer_loop_cmp             ;branch to the comparison for outer loop
        
outer_loop_body 
inner_loop_init SUBS R2, R0, #4                 ;R2 = j (iterator for the inner loop)
                B    inner_loop_cmp             ;branch to the comparison for inner loop

inner_loop_body LDR R4, =sorted_array           ;load the address of 'array' into R4
                LDR R4, [R4, R2]                ;load the jth element into R4
                
                LDR R5, =sorted_array           ;load the address of 'array' into R5
                SUBS R7, R2, #4                 ;load the value of j-1 into R7
                LDR R5, [R5, R7]                ;load the j-1th element into R5
                
                SUBS R2, R2, #4                 ;decrement inner loop iterator
                ADDS R1, R1, #4                 ;increment outer loop iterator
                
                CMP R4, R5                      ;compare R4 and R5
                BCS inner_loop_cmp              ;branch to inner_loop_cmp if R4 is higher than or equal to R5
                                
                BL swap_elements                ;branch with link to 'swap_elements' procedure to swap elements
                

inner_loop_cmp  PUSH {R2}
                ADDS R2, R2, R3
                CMP R2, R1                      ;compare inner loop iterator with outer loop iterator
                POP {R2}
                BCS inner_loop_body             ;branch to inner_loop_body if higher or equal

outer_loop_cmp  SUBS R3, R0, #4                 ;decrement main iterator R0 and put the value into R3
                CMP R1, R3                      ;compare the outer loop iterator with main iterator - 1
                BCC outer_loop_body             ;branch to outer_loop_body if R1 is lower than or same as R3

                POP {PC}                        ;branch back to caller
                ENDP                            ;declare end of procedure
        
swap_elements   PROC                            ;declare start of procedure 'swap_elements'
                PUSH {R0-R7}                    ;save R0 in stack

                LDR R4, =sorted_array           ;load the start address of array into R4
                
                ADDS R2, R2, #4
                ADDS R5, R4, R2                 ;R5 holds the address of A[j]
                
                SUBS R7, R2, #4
                ADDS R4, R4, R7                 ;R4 now holds the address of A[j-1]
                
                LDR R6, [R4]                    ;R6 will act as a temporary holder
                LDR R0, [R5]                    ;R0 will hold the value of R5
                STR R6, [R5]                    ;R6 is stored into address specified by R5
                STR R0, [R4]                    ;R0 is stored into address specified by R4
                
                POP {R0-R7}                     ;pop back R0 from the stack
                
                BX LR                           ;branch back to caller
                ENDP                            ;declare end of procedure
                
        
                AREA arraydata, DATA, READONLY  ;declare data area
        
array           DCD 0xa603e9e1, 0xb38cf45a, 0xf5010841, 0x32477961, 0x10bc09c5, 0x5543db2b, 0xd09b0bf1, 0x2eef070e, 0xe8e0e237, 0xd6ad2467, 0xc65a478b, 0xbd7bbc07, 0xa853c4bb, 0xfe21ee08, 0xa48b2364, 0x40c09b9f, 0xa67aff4e, 0x86342d4a, 0xee64e1dc, 0x87cdcdcc, 0x2b911058, 0xb5214bbc, 0xff4ecdd7, 0x3da3f26, 0xc79b2267, 0x6a72a73a, 0xd0d8533d, 0x5a4af4a6, 0x5c661e05, 0xc80c1ae8, 0x2d7e4d5a, 0x84367925, 0x84712f8b, 0x2b823605, 0x17691e64, 0xea49cba, 0x1d4386fb, 0xb085bec8, 0x4cc0f704, 0x76a4eca9, 0x83625326, 0x95fa4598, 0xe82d995e, 0xc5fb78cb, 0xaf63720d, 0xeb827b5, 0xcc11686d, 0x18db54ac, 0x8fe9488c, 0xe35cf1, 0xd80ec07d, 0xbdfcce51, 0x9ef8ef5c, 0x3a1382b2, 0xe1480a2a, 0xfe3aae2b, 0x2ef7727c, 0xda0121e1, 0x4b610a78, 0xd30f49c5, 0x1a3c2c63, 0x984990bc, 0xdb17118a, 0x7dae238f, 0x77aa1c96, 0xb7247800, 0xb117475f, 0xe6b2e711, 0x1fffc297, 0x144b449f, 0x6f08b591, 0x4e614a80, 0x204dd082, 0x163a93e0, 0xeb8b565a, 0x5326831, 0xf0f94119, 0xeb6e5842, 0xd9c3b040, 0x9a14c068, 0x38ccce54, 0x33e24bae, 0xc424c12b, 0x5d9b21ad, 0x355fb674, 0xb224f668, 0x296b3f6b, 0x59805a5f, 0x8568723b, 0xb9f49f9d, 0xf6831262, 0x78728bab, 0x10f12673, 0x984e7bee, 0x214f59a2, 0xfb088de7, 0x8b641c20, 0x72a0a379, 0x225fe86a, 0xd98a49f3
size            EQU 0x190                       ;array size in bytes

                AREA writeable, DATA, READWRITE
execution_times SPACE size                      ;initialize location for execution times in the memory
sorted_array    SPACE size
        
                END                             ;declare the end of code