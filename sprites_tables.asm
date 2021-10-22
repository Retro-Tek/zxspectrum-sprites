                    MACRO _define_draw_preshifted_sprite_table PROC_NAME
                        IFUSED _PROC_NAME_table
_PROC_NAME_table            DW 0
                            DW _PROC_NAME_patch_7
                            DW _PROC_NAME_patch_6
                            DW _PROC_NAME_patch_5
                            DW _PROC_NAME_patch_4
                            DW _PROC_NAME_patch_3
                            DW _PROC_NAME_patch_2
                            DW _PROC_NAME_patch_1
                        ENDIF
                    ENDM


                    ALIGN 16
_i                  = 1
                    DUP 32
                        _define_draw_preshifted_sprite_table draw_preshifted_sprite_NUMBERS[_i]
                        _define_draw_preshifted_sprite_table draw_preshifted_sprite_with_mask_NUMBERS[_i]
_i                  = _i + 1
                    EDUP
