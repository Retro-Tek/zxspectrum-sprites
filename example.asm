                    DEVICE ZXSPECTRUM128

                    ORG #8000


                    INCLUDE "macros.inc"
                    INCLUDE "screen.inc"


main                DI

                    XOR A
                    OUT (#FE),A

                    LD DE,SCREEN_ADDR
                    LD HL,background
                    LD BC,6912
                    LDIR

                    LD BC,(1<<8)|1
                    LD HL,sprite
                    LD IXL,6
                    CALL draw_tile_3

                    LD BC,(0<<8)|5
                    LD D,4
                    LD HL,sprite
                    LD IXL,6
                    CALL draw_preshifted_sprite_3

                    LD BC,(8<<8)|1
                    LD HL,sprite.with_mask
                    LD IXL,6
                    CALL draw_tile_with_mask_3

                    LD BC,(7<<8)|5
                    LD D,4
                    LD HL,sprite.with_mask
                    LD IXL,6
                    CALL draw_preshifted_sprite_with_mask_3

                    HALT


background          INCBIN "background.scr"
sprite              INCBIN "sprite.3x6.sp1"
.with_mask          INCBIN "sprite.3x6.sp2"


                    INCLUDE "sprites.asm"
                    INCLUDE "sprites_tables.asm"


                    SAVESNA "example.sna", main
                    LABELSLIST "user.l"
