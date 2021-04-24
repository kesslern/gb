INCLUDE "hardware.inc"
INCLUDE "constants.inc"

INCLUDE "data.asm"
INCLUDE "dma.asm"
INCLUDE "header.asm"
INCLUDE "lcd.asm"
INCLUDE "memfns.asm"

; Display a string if an input mask matches the most recent
; input read at $C000.
; 1 - Input mask (or then nz compare)
; 2 - String to display if or result is nz
; 3 - Destination address to display the string
m_displayInput: MACRO
    ld a, [ramInput]
    and a, \1
    jr z, .pressed\@
    m_strcpy ClearStr, \3
    jr .done\@
.pressed\@:
    m_strcpy \2, \3
.done\@
ENDM

SECTION "vBlank interrupt handler", ROM0[$0040]
    call Draw
    reti

SECTION "Game code", ROM0
Start:
    call StopLCD
    call init_dma

    ; Load font
    ld hl, _VRAM8000 + $0210
    ld de, FontTiles + $0210
    ld bc, FontTilesEnd - FontTiles - $0210
    call memcpy

    ; Init palette
    ld a, %11100100
    ld [rBGP], a
    ld a, %11111100
    ld [rOBP0], a
    ld [rOBP1], a

    ; Init scroll registers
    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

    ; Enable vblank interrupt
    ld a, [rIE]
    set 0, a
    ld [rIE], a

    ; Zero out Nintendo logo VRAM space
    ld hl, _VRAM8000
    ld bc, $81A0 - _VRAM8000
    call zero

    ; Zero out memory to copy to OAM
    ld hl, ramOAM
    ld bc, $100
    call zero

    ld a, 16
    ld [ramTILE1_Y], a
    ld a, 8
    ld [ramTILE1_X], a
    ld a, $5F
    ld [ramTILE1_TILE], a

    call StartLCD

     ei
    jp Loop

Loop:
    call readInput

.left:
    ld a, [ramInput]
    bit 5, a
    jr nz, .right

    ld hl, ramTILE1_X
    ld a, [hl]
    cp a, PADDLE_X_MIN
    jr z, .up
    dec [hl]

.right:
    ld a, [ramInput]
    bit 4, a
    jr nz, .up

    ld hl, ramTILE1_X
    ld a, PADDLE_X_MAX
    cp a, [hl]
    jr z, .up
    inc [hl]

.up:
    ld a, [ramInput]
    bit 6, a
    jr nz, .down

    ld hl, ramTILE1_Y
    ld a, [hl]
    cp a, PADDLE_Y_MIN
    jr z, .down
    dec [hl]

.down:
    ld a, [ramInput]
    bit 7, a
    jr nz, .done

    ld hl, ramTILE1_Y
    ld a, [hl]
    cp a, PADDLE_Y_MAX
    jr z, .done
    inc [hl]

.done
    halt
    jp Loop

Draw:
    call $FF80
    m_displayInput %00000001, AButtonStr, $9880
    m_displayInput %00000010, BButtonStr, $98A0
    m_displayInput %00000100, StartButtonStr, $98C0
    m_displayInput %00001000, SelectButtonStr, $98E0
    m_displayInput %00010000, RightButtonStr, $9860
    m_displayInput %00100000, LeftButtonStr, $9840
    m_displayInput %01000000, UpButtonStr, $9800
    m_displayInput %10000000, DownButtonStr, $9820
    ret

readInput:
    ld a, %00100000  ; Select direction buttons
    ld [rP1], a
    rept 5           ; Read input 5x to stabilize
    ld a, [rP1]
    endr
    and a, $0F       ; Clear upper 4 bits
    rla              ; Move lower 4 bits over to the upper 4 bits
    rla
    rla
    rla
    ld b, a          ; Store upper 4 bits in register b
    ld a, %00010000  ; Select actions buttons
    ld [rP1], a
    rept 5           ; Read input 5x to stabilize
    ld a, [rP1]
    endr
    and a, $0F       ; Clear upper bits
    or a, b          ; Combine with stored upper bits in register b
    ld [ramInput], a    ; Store input in $C000 work ram
    ret
