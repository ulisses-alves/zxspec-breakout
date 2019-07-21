    org $8000
    di
    call ClearScreen
    ld b, 80
    ld c, 50
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
                ld c, e ; Store right-shift
            pop de ; Restore sprite address
            ld a, (de) ; Load sprite
            ld b, c ; Set shift
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


; b: x, c: y => hl: address, e: right-shift
; * a, b, e, h, l
GetScreenPos:
    push bc
        ld c, 8
        call DivWithMod
        ld e, b ; store right-shift
    pop bc
    ld b, d
    ld a, c
    rlca
    rlca
    and %11100000
    or b
    ld l, a
    ld a, c
    rrca
    rrca
    rrca
    and %00011000
    or %01000000
    ld b, a
    ld a, c
    and %00000111
    or b
    ld h, a
    ret

    
GetNextLineUpdateH:
    inc h
    ret


; b: numerator, c: denominator => b: modulus, d: result
; * a, b, d
DivWithMod:
    ld d, 0
DivWithModRec:
    ld a, b
    sub c
    ret c
    ld b, a
    inc d
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


ScreenStart equ $4000 
ScreenEnd equ $57ff

; Screen address

; H-register:
; | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  |
; | 0  | 1  | 0  | Y7 | Y6 | Y2 | Y1 | Y0 |

; L-register:
; | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  | 
; | Y5 | Y4 | Y3 | X4 | X3 | X2 | X1 | X0 |