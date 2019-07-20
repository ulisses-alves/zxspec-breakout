    org $8000
    di
    call ClearScreen
    ld bc, $0100
    call GetScreenPos
    ld a, $ff
    ld b, e
    call ShiftRight
    ld (hl), a
    jr InfLoop


InfLoop:
    jr InfLoop


; * a
ClearScreen:
    xor a ; Pick border color (black)
    call $229b ; Set border color
    ld a, $0f
    ld ($5c8d), a ; Pick background color (black)
    call $0daf ; Set background
    ret


; b: x, c: y => hl: address, e: x-shift
; * a, b, e, h, l
GetScreenPos:
    push bc
        ld c, 8
        call DivWithMod
        ld e, b ; store x-shift
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


ScreenStart equ $4000 
ScreenEnd equ $57ff

; Screen address

; H-register:
; | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  |
; | 0  | 1  | 0  | Y7 | Y6 | Y2 | Y1 | Y0 |

; L-register:
; | 7  | 6  | 5  | 4  | 3  | 2  | 1  | 0  | 
; | Y5 | Y4 | Y3 | X4 | X3 | X2 | X1 | X0 |