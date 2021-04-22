INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    di
    jp Start

; Space for header
REPT $150 - $104
    db 0
ENDR

; Wait for VRAM to be safe to write to
; Busy wait - should change to use interrupt
waitVRAM: MACRO
    ld  a,[rSTAT]
    and STATF_BUSY
    jr  nz,@-4
ENDM

; src -> dest
m_strcpy: MACRO
    ld de, \1
    ld hl, \2
    call strcpy
ENDM

; Display a string if an input mask matches the most recent
; input read at $C000.
; 1 - Input mask (or then nz compare)
; 2 - String to display if or result is nz
; 3 - Destination address to display the string
m_displayInput: MACRO
    ld a, [$C000]
    and a, \1
    jr z, .pressed\@
    m_strcpy ClearStr, \3
    jr .done\@
.pressed\@:
    m_strcpy \2, \3
.done\@
ENDM

SECTION "vBlank", ROM0[$0040]
    call Draw
    reti

SECTION "Game code", ROM0
Start:
    call StopLCD

    ; Load font
    ld hl, $8210
    ld de, FontTiles + $0210
    ld bc, FontTilesEnd - FontTiles - $0210
    call memcpy

    ; Load font
    ld hl, $9000
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

    call StartLCD

    ; Enable vblank interrupt
    ld a, [$FFFF]
    set 0, a
    ld [$FFFF], a

    ei

Loop:
    call readInput
    halt
    jp Loop

Draw:
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
    ld [$C000], a    ; Store input in $C000 work ram
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
    waitVRAM
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

.wait:
    ld a, [rLY]
    cp 145
    jr nz, .wait

    ld  a, [rLCDC]
    res 7, a
    ld  [rLCDC], a

    ret

StartLCD:
    ; ld a, LCDCF_ON|LCDCF_BGON
    ; ld [rLCDC], a
    ld  a, [rLCDC]
    set 7, a
    ; res 4, a
    set 0, a
    ld  [rLCDC], a
    ret

WaitVBlank:
    ld   hl, rSTAT   ; LCD Status Register
.wait1:           ;
    bit  1, [hl]       ; Wait until Mode is -NOT- 0 or 1
    jr   z, .wait1    ;
.wait2:           ;
    bit  1, [hl]       ; Wait until Mode 0 or 1 -BEGINS- (but we know that Mode 0 is what will begin)
    jr   nz, .wait2   ;
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

