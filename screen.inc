                    IFNDEF SCREEN_ADDR
                        DEFINE SCREEN_ADDR #4000
                    ENDIF

                    ASSERT LOW(SCREEN_ADDR) == 0


; Size = 14
; Time = 54
; Input:  BC = y,x - char coords
; Output: BC = char addr
                    MACRO get_screen_char_addr_inline
                        LD A,B
                        ADD A,A
                        ADD A,A
                        ADD A,A
                        ADD A,A
                        ADD A,A
                        ADD A,C
                        LD C,A
                        LD A,B
                        AND 24
                        ADD A,HIGH(SCREEN_ADDR)
                        LD B,A
                    ENDM


; Size = 17
; Time = 66
; Input:  BC  = y,x - char coords
;         D   = dy  - offset [0-7] in char
; Output: BC  = byte addr
;         IXH = HIGH(char addr), i.e. [IXH,C] - char addr
                    MACRO get_screen_byte_addr_inline
                        LD A,B
                        ADD A,A
                        ADD A,A
                        ADD A,A
                        ADD A,A
                        ADD A,A
                        ADD A,C
                        LD C,A
                        LD A,B
                        AND 24
                        ADD A,HIGH(SCREEN_ADDR)
                        LD IXH,A
                        ADD D
                        LD B,A
                    ENDM
