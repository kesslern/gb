INCLUDE "hardware.inc"
INCLUDE "macros.asm"

SECTION "Header", ROM0[$0100]
    di
    jp start

; Space for header
REPT $150 - $104
    db 0
ENDR

SECTION "vBlank", ROM0[$0040]
    call Draw
    reti

SECTION "Game code", ROM0
start:
    call StopLCD

    ; Load font
    ld hl, _VRAM9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
    call memcpy

    ; Init palette
    ld a, %11100100
    ld [rBGP], a

    ; Init scroll registers
    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

    ; Enable vblank interrupt
    ld a, [rIE]
    or a, IEF_VBLANK
    ld [rIE], a

    call StartLCD
    ei

MainLoop:
    call readInput
    halt
    jp MainLoop

Draw:
    m_displayInput 0, AButtonStr,      _SCRN0 + $20 * 4
    m_displayInput 1, BButtonStr,      _SCRN0 + $20 * 5
    m_displayInput 2, StartButtonStr,  _SCRN0 + $20 * 6
    m_displayInput 3, SelectButtonStr, _SCRN0 + $20 * 7
    m_displayInput 4, RightButtonStr,  _SCRN0 + $20 * 3
    m_displayInput 5, LeftButtonStr,   _SCRN0 + $20 * 2
    m_displayInput 6, UpButtonStr,     _SCRN0 + $20 * 0
    m_displayInput 7, DownButtonStr,   _SCRN0 + $20 * 1
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
    ld [_RAM], a     ; Store input in $C000 work ram
    ret

; Copy a chunk of memory of known size.
; @param bc - Number of bytes to copy 
; @param de - Source address
; @param hl - Destination address
memcpy:
    ld a, [de]  ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de      ; Increment source address
    dec bc      ; Decrement count
    ld a, b     ; Check if count is 0
    or c
    jr nz, memcpy
    ret

; Copy a 0-terminated string to VRAM
; @param de - Source addressppp
; @param hl - Destination address
strcpy:
    ld a, [de]  ; Grab 1 byte from source address
    ld [hli], a ; Write to memory & increment destination addr
    inc de      ; Increment source addr
    and a       ; Check if the byte we just copied is zero
    jr nz, strcpy
    ret

StopLCD:
    ld a, [rLCDC]
    rlca
    ret nc ; In this case, the LCD is already off

    waitVBlank
    ld  a, [rLCDC] ; Reset bit 7 of LCDC to turn LCD off
    res 7, a
    ld  [rLCDC], a
    ret

StartLCD:
    ld a, LCDCF_ON|LCDCF_BGON
    ld [rLCDC], a
    ret

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "strings", ROM0

LeftButtonStr:
    db "Left", 0
RightButtonStr:
    db "Right", 0
UpButtonStr:
    db "Up", 0
DownButtonStr:
    db "Down", 0
StartButtonStr:
    db "Start", 0
SelectButtonStr:
    db "Select", 0
AButtonStr:
    db "A", 0
BButtonStr:
    db "B", 0
ClearStr:
    db "      ", 0

