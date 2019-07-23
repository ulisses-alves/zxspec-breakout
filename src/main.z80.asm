    org $8000
    di
    call ClearScreen
    ld b, 160
    ld c, 180
    ld de, BallSprite
    call DrawSprite
    jr InfLoop

InfLoop:
    jr InfLoop

; Draws a 8x8 sprite on coordinate.
; b: x, c: y, de: sprite-address
DrawSprite:
    ld a, 8
DrawSpriteRec:
    push af ; Store sprite line counter
        push bc ; Store coordinates
            push de ; Store sprite address
                call GetScreenPos
                ld c, a ; Store right-shift for later
                ld b, a
            pop de ; Restore sprite address
            ld a, (de) ; Load sprite
            call ShiftRight ; Apply right-shift to sprite
            ld (hl), a ; Draw
            inc c
            dec c
            jp z, DrawSpriteContinue ; Drew whole sprite?
            ld a, 8
            sub c ; Calc left shift for next x address
            ld b, a
            ld a, (de)
            call ShiftLeft
            inc l ; Next x screen addresss
            ld (hl), a ; Draw
DrawSpriteContinue:
            inc de
        pop bc ; Restore coordinates
        inc c ; Move to next Y coordinate
    pop af ; Restore sprite line counter
    dec a
    jp nz, DrawSpriteRec
    ret


BallSprite:
    defb %00111100
    defb %01000010
    defb %10010001
    defb %10100001
    defb %10000001
    defb %10000001
    defb %01000010
    defb %00111100


; * a
ClearScreen:
    xor a ; Pick border color (black)
    call $229b ; Set border color
    ld a, $0f ; Pick background color (black)
    ld ($5c8d), a
    call $0daf ; Set background
    ret


; b: x, c: y => hl: address, a: right-shift
; * a, b, c, d, e, h, l
GetScreenPos:
    push bc
        ld b, 0
        ld hl, ScreenMap
        add hl, bc
        add hl, bc
        ld a, (hl)
        inc l
        ld h, (hl)
        ld l, a
    pop bc
    ld a, b
    ld c, 8
    call DivWithMod ; a / c => a: mod, e: result
    ld d, 0
    add hl, de
    ret


; a % c => a: mod, e: result
; * a, b, d
DivWithMod:
    ld e, 0
    or a
DivWithModRec:
    cp c
    ret c
    sub c
    inc e
    jp DivWithModRec


; a: value, b: count => a: result
; * a, b
ShiftRight:
    inc b
    dec b
    ret z
ShiftRightRec:
    srl a
    djnz ShiftRightRec
    ret


; a: value, b: count => a: result
; * a, b
ShiftLeft:
    inc b
    dec b
    ret z
ShiftLeftRec:
    sla a
    djnz ShiftLeftRec
    ret


; Screen address

; H-register:
; | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  |
; | 0  | 1  | 0  | Y7 | Y6 | Y2 | Y1 | Y0 |

; L-register:
; | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  | 
; | Y5 | Y4 | Y3 | X4 | X3 | X2 | X1 | X0 |

; Eeach word is the memory address of the begining of a line
ScreenMap:
    align 2
    dw $4000, $4100, $4200, $4300, $4400, $4500, $4600, $4700
    dw $4020, $4120, $4220, $4320, $4420, $4520, $4620, $4720
    dw $4040, $4140, $4240, $4340, $4440, $4540, $4640, $4740
    dw $4060, $4160, $4260, $4360, $4460, $4560, $4660, $4760
    dw $4080, $4180, $4280, $4380, $4480, $4580, $4680, $4780
    dw $40A0, $41A0, $42A0, $43A0, $44A0, $45A0, $46A0, $47A0
    dw $40C0, $41C0, $42C0, $43C0, $44C0, $45C0, $46C0, $47C0
    dw $40E0, $41E0, $42E0, $43E0, $44E0, $45E0, $46E0, $47E0
    dw $4800, $4900, $4A00, $4B00, $4C00, $4D00, $4E00, $4F00
    dw $4820, $4920, $4A20, $4B20, $4C20, $4D20, $4E20, $4F20
    dw $4840, $4940, $4A40, $4B40, $4C40, $4D40, $4E40, $4F40
    dw $4860, $4960, $4A60, $4B60, $4C60, $4D60, $4E60, $4F60
    dw $4880, $4980, $4A80, $4B80, $4C80, $4D80, $4E80, $4F80
    dw $48A0, $49A0, $4AA0, $4BA0, $4CA0, $4DA0, $4EA0, $4FA0
    dw $48C0, $49C0, $4AC0, $4BC0, $4CC0, $4DC0, $4EC0, $4FC0
    dw $48E0, $49E0, $4AE0, $4BE0, $4CE0, $4DE0, $4EE0, $4FE0
    dw $5000, $5100, $5200, $5300, $5400, $5500, $5600, $5700
    dw $5020, $5120, $5220, $5320, $5420, $5520, $5620, $5720
    dw $5040, $5140, $5240, $5340, $5440, $5540, $5640, $5740
    dw $5060, $5160, $5260, $5360, $5460, $5560, $5660, $5760
    dw $5080, $5180, $5280, $5380, $5480, $5580, $5680, $5780
    dw $50A0, $51A0, $52A0, $53A0, $54A0, $55A0, $56A0, $57A0
    dw $50C0, $51C0, $52C0, $53C0, $54C0, $55C0, $56C0, $57C0
    dw $50E0, $51E0, $52E0, $53E0, $54E0, $55E0, $56E0, $57E0