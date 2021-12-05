; Size = 15
; Time = 64
; Input:  BC = y,x - char coords
; Output: BC = char addr
; Preserves DE, HL, ALL', IX, IY.
get_screen_char_addr
                    IFUSED
                        get_screen_char_addr_inline
                        RET
                    ENDIF


; Size = 18
; Time = 76
; Input:  BC      = y,x - char coords
;         D       = dy  - offset [0-7] in char
; Output: BC      = byte addr
;         IXH|IYH = HIGH(char addr), i.e. [IXH|IYH,C] - char addr
; Preserves DE, HL, ALL', (IXL, IY)|(IX, IYL).
get_screen_byte_addr
                    IFUSED
                        get_screen_byte_addr_inline
                        RET
                    ENDIF
