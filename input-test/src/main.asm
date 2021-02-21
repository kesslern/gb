INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    di
    jp Start

; Space for header
REPT $150 - $104
    db 0
ENDR

; Wait for VRAM to be safe to write to
waitVRAM: MACRO
    ld  a,[rSTAT]
    and STATF_BUSY
    jr  nz,@-4
ENDM

SECTION "Game code", ROM0
Start:
    call StopLCD

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

    ld a, %00100000
    ld [$FF00], a

    call StartLCD

MainLoop:
    ld a, [rP1]
    and P1F_0
    jr z, .rightButtonPressed

    ld a, [rP1]
    and P1F_1
    jr z, .leftButtonPressed

    ld a, [rP1]
    and P1F_2
    jr z, .upButtonPressed

    ld a, [rP1]
    and P1F_3
    jr z, .downButtonPressed

.noButtonPressed
    ; No button is pressed
    ld de, NoButtonsStr
    jr .endMainLoop

.leftButtonPressed:
    ld de, LeftButtonStr
    jr .endMainLoop

.rightButtonPressed:
    ld de, RightButtonStr
    jr .endMainLoop

.upButtonPressed:
    ld de, UpButtonStr
    jr .endMainLoop

.downButtonPressed:
    ld de, DownButtonStr
    jr .endMainLoop

.endMainLoop
    ld hl, $9800
    call strcpy
    jr MainLoop

wait:
    ld a, $FF
.start_loop:
    ld b, a
    ld a, $FF
.loop:
    dec a
    jr nz, .loop
    ld a, b
    dec a
    jr nz, .start_loop
    ret

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

; Copy a NULL-terminated string to VRAM
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
    ld a,[rLY]
    cp 145
    jr nz, .wait

    ld  a, [rLCDC]
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

NoButtonsStr:
    db "No button is pressed", 0
LeftButtonStr:
    db "Left is pressed     ", 0
RightButtonStr:
    db "Right is pressed    ", 0
UpButtonStr:
    db "Up is pressed       ", 0
DownButtonStr:
    db "Down is pressed     ", 0

