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
                EXPORT __main                   ;declare __main symbol to be used by linker,
        
SYST_CSR        EQU 0xE000E010                  ;give symbolic name SYST_CSR to address of SysTick Control and Status Register
SYST_RVR        EQU 0xE000E014                  ;give symbolic name SYST_RVR to address of SysTick Reload Value Register
SYST_CVR        EQU 0xE000E018                  ;give symbolic name SYST_CVR to address of Current Value Register

RELOAD          EQU 0xF9FFF                     ;give symbolic name RELOAD to reload value for 64 MHz and period of 16 ms
START           EQU 2_111                       ;give symbolic name START to will set CLKSOURCE, TICKINT and ENABLE values of Control and Status Register to 1

__main          FUNCTION                        ;declare function start

                BL timer_init
                
                MOVS R0, #2                     ;set main loop iterator to 2
                B m_cmp                         ;branch to loop comparison
        
m_body          BL save_start                   ;branch with link to save_start procedure to save start time to memory
                BL bubblesort                   ;branch with link to bubblesort procedure
                BL save_exec                    ;branch with link to save_exec procedure to save execution time to memory

m_cmp           CMP R0, #size
                BLE m_body
        
        
                BL timer_stop
        
stop            B    stop                       ;infinite loop to signify end of program
        
                ENDFUNC
        
timer_init      PROC                            ;declare start of procedure 'timer_init'

                LDR R0, =SYST_CSR               ;load SysTick Control and Status Register address into R0
                LDR R1, =SYST_RVR               ;load SysTick Reload Value Register address into R1
                LDR R2, =RELOAD                 ;load RELOAD value into R2
                LDR R3, =START                  ;load START value into R3
                
                STR    R2, [R1]                 ;store RELOAD value in Reload Value Register
                STR R3, [R0]                    ;store START value in Control and Status Register
                
				BX LR
                ENDP                            ;declare end of procedure
        
timer_stop      PROC                            ;declare start of procedure 'timer_stop'

                BX LR
                ENDP                            ;declare end of procedure
        
save_start      PROC                        

                BX LR
                ENDP
        
save_exec       PROC

                BX LR
                ENDP
        
bubblesort      PROC                            ;declare start of procedure 'bubblesort'. R0 is the iterator

                MOVS R1, #0                     ;R1 = i (iterator for the outer loop)
                B    outer_loop_cmp             ;branch to the comparison for outer loop
        
outer_loop_body SUBS R2, R0, #1                 ;R2 = j (iterator for the inner loop)
                B    inner_loop_cmp
                ADDS R1, R1, #1

inner_loop_body LDR R4, =array
                LDR R4, [R4, #0]
                
                LDR R5, =array
                SUBS R7, R5, #1
                LDR R5, [R6, #0]
                
                CMP R4, R5
                BCS inner_loop_cmp
                
                BL swap_elements
                
                SUBS R2, R2, #1

inner_loop_cmp  CMP R2, R1
                BCS    inner_loop_body

outer_loop_cmp  SUBS R3, R0, #1
                CMP R1, R3
                BCC outer_loop_body

                BX LR
                ENDP                            ;declare end of procedure
        
swap_elements   PROC

                MOVS R6, R5
                MOVS R5, R4
                MOVS R4, R6
				
                BX LR
				ENDP
                
        
                AREA arraydata, DATA, READWRITE  ;declare data area
        
array           DCD 0xa603e9e1, 0xb38cf45a, 0xf5010841, 0x32477961, 0x10bc09c5, 0x5543db2b, 0xd09b0bf1, 0x2eef070e, 0xe8e0e237, 0xd6ad2467, 0xc65a478b, 0xbd7bbc07, 0xa853c4bb, 0xfe21ee08, 0xa48b2364, 0x40c09b9f, 0xa67aff4e, 0x86342d4a, 0xee64e1dc, 0x87cdcdcc, 0x2b911058, 0xb5214bbc, 0xff4ecdd7, 0x3da3f26, 0xc79b2267, 0x6a72a73a, 0xd0d8533d, 0x5a4af4a6, 0x5c661e05, 0xc80c1ae8, 0x2d7e4d5a, 0x84367925, 0x84712f8b, 0x2b823605, 0x17691e64, 0xea49cba, 0x1d4386fb, 0xb085bec8, 0x4cc0f704, 0x76a4eca9, 0x83625326, 0x95fa4598, 0xe82d995e, 0xc5fb78cb, 0xaf63720d, 0xeb827b5, 0xcc11686d, 0x18db54ac, 0x8fe9488c, 0xe35cf1, 0xd80ec07d, 0xbdfcce51, 0x9ef8ef5c, 0x3a1382b2, 0xe1480a2a, 0xfe3aae2b, 0x2ef7727c, 0xda0121e1, 0x4b610a78, 0xd30f49c5, 0x1a3c2c63, 0x984990bc, 0xdb17118a, 0x7dae238f, 0x77aa1c96, 0xb7247800, 0xb117475f, 0xe6b2e711, 0x1fffc297, 0x144b449f, 0x6f08b591, 0x4e614a80, 0x204dd082, 0x163a93e0, 0xeb8b565a, 0x5326831, 0xf0f94119, 0xeb6e5842, 0xd9c3b040, 0x9a14c068, 0x38ccce54, 0x33e24bae, 0xc424c12b, 0x5d9b21ad, 0x355fb674, 0xb224f668, 0x296b3f6b, 0x59805a5f, 0x8568723b, 0xb9f49f9d, 0xf6831262, 0x78728bab, 0x10f12673, 0x984e7bee, 0x214f59a2, 0xfb088de7, 0x8b641c20, 0x72a0a379, 0x225fe86a, 0xd98a49f3
size            EQU 0x64                           ;array size
        
                END                                ;declare the end of code