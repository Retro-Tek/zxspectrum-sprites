; * = width                                    |   BC      |  D  |     HL      |  IXL   | IXH  | Preserves   
;----------------------------------------------+-----------+-----+-------------+--------+------+------------
; draw_tile[_with_mask]_*                      |  cy,cx    |     | sprite_addr | height |      | IXH,IY,ALL'
; draw_tile[_with_mask]_*_at_addr              | dst_addr  |     | sprite_addr | height | B&~7 | IXH,IY,ALL'
; draw_preshifted_sprite[_with_mask]_*         |  cy,cx    | dy  | sprite_addr | height |      |   IY,ALL'
; draw_preshifted_sprite[_with_mask]_*_at_addr | dst_addr  | dy  | sprite_addr | height | B&~7 |   IY,ALL'
;----------------------------------------------+-----------+-----+-------------+--------+------+------------
; where (cx,cy) - character coords and dy - offset inside character (0-7).

; * = width                                  | code size             | data size | time (+[dT + [dT]] - time to cross screen 1/3 and 2/3)
;--------------------------------------------+-----------------------+-----------+-------------------------------------------------------
; draw_tile_*_at_addr                        | 36 + 20*width         |           | 61 + 36*height + 128*width*height + [29 + [29]]
; draw_tile_*                                | +14                   |           | +54
; draw_tile_with_mask_*_at_addr              | 36 + 48*width         |           | 61 + 36*height + 288*width*height + [29 + [29]]
; draw_tile_with_mask_*                      | +14                   |           | +54
; draw_preshifted_sprite_*_at_addr           | 65 + 20*width +       |    16     | 250 + 70*height + 128*width*height + [39 + [39]] +
;                                            | + {16 once for all} + |           | + [(5 + height) if width > 5]
;                                            | + [2 if width > 5]    |           |
; draw_preshifted_sprite_*                   | +17                   |           | +66
; draw_preshifted_sprite_with_mask_*_at_addr | 50 + 48*width +       |    16     | 205 + 51*height + 288*width*height + [43 + [43]]
;                                            | + {18 once for all}   |           |
; draw_preshifted_sprite_with_mask_*         | +17                   |           | +66


; Size = 5
; Time = 32
                    MACRO _init_tile_read
                        LD E,(HL)
                        INC HL
                        LD D,(HL)
                        INC HL

                        LD SP,HL
                    ENDM


; Size = 2.5*width - 1 + [+/-0.5]
; Time = 16*width - 4 + [+/-5]
                    MACRO _draw_line_into_HL WIDTH, DIR
.i                      = 0
                        DUP WIDTH
                            IF (.i%2) == ((DIR<0) & (WIDTH%2))
                                POP DE
                                LD (HL),E
                            ELSE
                                LD (HL),D
                            ENDIF

                            IF .i != (WIDTH-1)
                                if_then_else DIR>0, INC L, DEC L
                            ENDIF

.i                          = .i+1
                        EDUP
                    ENDM


; Size = 6*width - 1
; Time = 36*width - 4
                    MACRO _draw_line_with_mask_into_BC WIDTH, DIR
.i                      = 0
                        DUP WIDTH
                            POP DE
                            LD A,(BC)
                            AND D
                            OR E
                            LD (BC),A

                            IF .i != (WIDTH-1)
                                if_then_else DIR>0, INC C, DEC C
                            ENDIF

.i                          = .i+1
                        EDUP
                    ENDM


; Size = 36 + 20*width
; Time = 61 + 36*height + 128*width*height + [29 + [29]]
                    MACRO _draw_tile WIDTH
                        LD (.old_sp),SP
                        _init_tile_read

                        LD H,B
                        LD L,C

                        LD C,IXL

                        CP 0
                        ORG $-1
.loop
                        _draw_line_into_HL WIDTH, +1
                        INC H
                        _draw_line_into_HL WIDTH, -1
                        INC H
                        _draw_line_into_HL WIDTH, +1
                        INC H
                        _draw_line_into_HL WIDTH, -1
                        INC H
                        _draw_line_into_HL WIDTH, +1
                        INC H
                        _draw_line_into_HL WIDTH, -1
                        INC H
                        _draw_line_into_HL WIDTH, +1
                        INC H
                        _draw_line_into_HL WIDTH, -1

                        DEC C
                        JR Z,.break

                        ; H -= 7
                        ; L += 32
                        LD H,B
                        LD A,L
                        ADD 32
                        LD L,A
                        JP NC,.loop

                        ; H += 8
                        LD A,H
                        ADD 8
                        LD H,A
                        LD B,H
                        JP .loop
.break
                        LD  SP,0
.old_sp                 EQU $-2
                        RET
                    ENDM


; Size = 36 + 48*width
; Time = 61 + 36*height + 288*width*height + [29 + [29]]
                    MACRO _draw_tile_with_mask WIDTH
                        LD (.old_sp),SP
                        _init_tile_read

                        LD H,B

                        LD A,IXL
                        LD L,A

                        CP 0
                        ORG $-1
.loop
                        _draw_line_with_mask_into_BC WIDTH, +1
                        INC B
                        _draw_line_with_mask_into_BC WIDTH, -1
                        INC B
                        _draw_line_with_mask_into_BC WIDTH, +1
                        INC B
                        _draw_line_with_mask_into_BC WIDTH, -1
                        INC B
                        _draw_line_with_mask_into_BC WIDTH, +1
                        INC B
                        _draw_line_with_mask_into_BC WIDTH, -1
                        INC B
                        _draw_line_with_mask_into_BC WIDTH, +1
                        INC B
                        _draw_line_with_mask_into_BC WIDTH, -1

                        DEC L
                        JR Z,.break

                        ; B -= 7
                        ; C += 32
                        LD B,H
                        LD A,C
                        ADD 32
                        LD C,A
                        JP NC,.loop

                        ; B += 8
                        LD A,B
                        ADD 8
                        LD B,A
                        LD H,B
                        JP .loop
.break
                        LD  SP,0
.old_sp                 EQU $-2
                        RET
                    ENDM


; Size = 16
; Time = 29 + [39]
_draw_sprite_HL_next_char
                    IFUSED
                        ; H -= 7
                        ; L += 32
                        LD H,C
                        LD A,L
                        ADD 32
                        LD L,A
.exit                   JP NC,0
.ret_addr               EQU $-2
                        ; H += 8
                        LD A,H
                        ADD 8
                        LD H,A
                        LD C,H
                        JP .exit
                    ENDIF


; Size = 18
; Time = 33 + [43]
_draw_sprite_BC_next_char
                    IFUSED
                        ; B -= 7
                        ; C += 32
                        LD B,IXH
                        LD A,C
                        ADD 32
                        LD C,A
.exit                   JP NC,0
.ret_addr               EQU $-2
                        ; B += 8
                        LD A,B
                        ADD 8
                        LD B,A
                        LD IXH,B
                        JP .exit
                    ENDIF


; Size = 65 + 20*width + [2 if width > 5] + {16 for patch table} + {16 once for all}
; Time = 250 + 70*height + 128*width*height + [(5 + height) if width > 5] + [39 + [39]]
                    MACRO _draw_preshifted_sprite WIDTH
                        DEFINE PROC_NAME! draw_preshifted_sprite_WIDTH

                        LD A,D
                        ADD A
                        JP Z,draw_tile_WIDTH_at_addr

                        LD (.old_sp),SP
                        _init_tile_read

                        LD HL,_PROC_NAME!_table ; defined separately
                        ADD L
                        LD L,A

                        LD A,(HL)
                        INC L
                        LD H,(HL)
                        LD L,A

                        LD (.restore_addr),HL
                        LD (HL),#DD ; IX prefix
                        INC HL
                        LD (HL),#E9 ; JP (IX)
                        INC HL
                        LD (_draw_sprite_HL_next_char.ret_addr),HL

                        LD H,B
                        LD L,C
                        LD B,IXL
                        LD C,IXH

                        LD IX,_draw_sprite_HL_next_char

                        CP 0
                        ORG $-1
.loop
                        _draw_line_into_HL WIDTH, +1
_PROC_NAME!_patch_1     INC H : NOP
                        _draw_line_into_HL WIDTH, -1
_PROC_NAME!_patch_2     INC H : NOP
                        _draw_line_into_HL WIDTH, +1
_PROC_NAME!_patch_3     INC H : NOP
                        _draw_line_into_HL WIDTH, -1
_PROC_NAME!_patch_4     INC H : NOP
                        _draw_line_into_HL WIDTH, +1
_PROC_NAME!_patch_5     INC H : NOP
                        _draw_line_into_HL WIDTH, -1
_PROC_NAME!_patch_6     INC H : NOP
                        _draw_line_into_HL WIDTH, +1
_PROC_NAME!_patch_7     INC H : NOP
                        _draw_line_into_HL WIDTH, -1
                        INC H

                        IF WIDTH <= 5
                            DJNZ .loop
                        ELSE
                            DEC B
                            JP NZ,.loop
                        ENDIF
.break
                        LD HL,#0024 ; INC H : NOP
                        LD (0),HL
.restore_addr           EQU $-2
                        LD  SP,0
.old_sp                 EQU $-2
                        RET

                        UNDEFINE PROC_NAME!
                    ENDM


; Size = 50 + 48*width + {16 for patch table} + {18 once for all}
; Time = 205 + 51*height + 288*width*height + [43 + [43]]
                    MACRO _draw_preshifted_sprite_with_mask WIDTH
                        DEFINE PROC_NAME! draw_preshifted_sprite_with_mask_WIDTH

                        LD A,D
                        ADD A
                        JP Z,draw_tile_with_mask_WIDTH_at_addr

                        LD (.old_sp),SP
                        _init_tile_read

                        LD HL,_PROC_NAME!_table ; defined separately
                        ADD L
                        LD L,A

                        LD A,(HL)
                        INC L
                        LD H,(HL)
                        LD L,A

                        LD (.restore_addr),HL
                        LD (HL),#E9 ; JP (HL)
                        INC HL
                        LD (_draw_sprite_BC_next_char.ret_addr),HL
                        LD HL,_draw_sprite_BC_next_char

                        CP 0
                        ORG $-1
.loop
                        _draw_line_with_mask_into_BC WIDTH, +1
_PROC_NAME!_patch_1     INC B
                        _draw_line_with_mask_into_BC WIDTH, -1
_PROC_NAME!_patch_2     INC B
                        _draw_line_with_mask_into_BC WIDTH, +1
_PROC_NAME!_patch_3     INC B
                        _draw_line_with_mask_into_BC WIDTH, -1
_PROC_NAME!_patch_4     INC B
                        _draw_line_with_mask_into_BC WIDTH, +1
_PROC_NAME!_patch_5     INC B
                        _draw_line_with_mask_into_BC WIDTH, -1
_PROC_NAME!_patch_6     INC B
                        _draw_line_with_mask_into_BC WIDTH, +1
_PROC_NAME!_patch_7     INC B
                        _draw_line_with_mask_into_BC WIDTH, -1
                        INC B

                        DEC IXL
                        JP NZ,.loop
.break
                        LD A,#04 ; INC B
                        LD (0),A
.restore_addr           EQU $-2
                        LD  SP,0
.old_sp                 EQU $-2
                        RET

                        UNDEFINE PROC_NAME!
                    ENDM


                    MACRO _define_draw_proc TYPE, WIDTH
                        DEFINE DRAW_PROC_NAME! draw_TYPE_WIDTH

                        IFUSED DRAW_PROC_NAME!
DRAW_PROC_NAME!             _get_TYPE_screen_addr
                             ; fake call to mark label as used
                            JP DRAW_PROC_NAME!_at_addr
                            ORG $-3
                        ENDIF

                        IFUSED DRAW_PROC_NAME!_at_addr
DRAW_PROC_NAME!_at_addr     _draw_TYPE WIDTH
                        ENDIF

                        UNDEFINE DRAW_PROC_NAME!
                    ENDM


                    DEFINE _get_tile_screen_addr                        get_screen_char_addr_inline
                    DEFINE _get_tile_with_mask_screen_addr              get_screen_char_addr_inline
                    DEFINE _get_preshifted_sprite_screen_addr           get_screen_byte_addr_inline
                    DEFINE _get_preshifted_sprite_with_mask_screen_addr get_screen_byte_addr_inline


_i                  = 1
                    DUP 32
                        _define_draw_proc tile,                        NUMBERS[_i]
                        _define_draw_proc tile_with_mask,              NUMBERS[_i]
                        _define_draw_proc preshifted_sprite,           NUMBERS[_i]
                        _define_draw_proc preshifted_sprite_with_mask, NUMBERS[_i]
_i                      = _i + 1
                    EDUP
