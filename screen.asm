; Size = 15
; Time = 64
; Input:  BC = y,x - char coords
; Output: BC = char addr
get_screen_char_addr
                    IFUSED
                    get_screen_char_addr_inline
                    RET
                    ENDIF


; Size = 18
; Time = 76
; Input:  BC  = y,x - char coords
;         D   = dy  - offset [0-7] in char
; Output: BC  = byte addr
;         IXH = HIGH(char addr), i.e. [IXH,C] - char addr
get_screen_byte_addr
                    IFUSED
                    get_screen_byte_addr_inline
                    RET
                    ENDIF
