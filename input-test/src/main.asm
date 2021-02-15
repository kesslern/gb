INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
EntryPoint: ; This is where execution begins
    nop
    jp Start

; Space for header
REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0
Start:
    ; Turn off the LCD
    call waitVBlank

    xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.

    ; Load font
    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
    call memcpy

    ; Init display registers
    ld a, %11100100
    ld [rBGP], a

    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

.restart
    ld hl, $9800
    ld de, StartingStr
    call strcpy

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a

REPT 10
    call wait
ENDR
    call waitVBlank

    ; Turn screen off
    xor a
    ld [rLCDC], a

;; Change strings
    ld hl, $9800 ; This will print the string at the top-left corner of the screen
    ld de, NoButtonsStr
    call strcpy

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a

REPT 10
    call wait
ENDR
    call waitVBlank

    ; Turn screen off
    xor a
    ld [rLCDC], a

    jr .restart

wait:
    ld a, $FF
.start_loop
    ld b, a
    ld a, $FF
.loop
    dec a
    jr nz, .loop
    ld a, b
    dec a
    jr nz, .start_loop
    ret

waitVBlank:
    ld a, [rLY]
    cp 144 ; Check if the LCD is past VBlank
    jr c, waitVBlank
    ret

; @param bc - Number of bytes to copy 
; @param de - Source address
; @param hl - Destination address
memcpy:
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de ; Move to next byte
    dec bc ; Decrement count
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, memcpy
    ret

; @param de - Source address
; @param hl - Destination address
strcpy:
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de ; Move to next byte
    and a ; Check if the byte we just copied is zero
    jr nz, strcpy ; Continue if it's not
    ret


SECTION "Vblank", ROM0[$0040]
    reti
SECTION "LCDC", ROM0[$0048]
    reti
SECTION "Timer_Overflow", ROM0[$0050]
    reti
SECTION "Serial", ROM0[$0058]
    reti
SECTION "p1thru4", ROM0[$0060]
    reti

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "strings", ROM0

StartingStr:
    db "Starting...", 0
NoButtonsStr:
    db "No buttons!", 0
LeftStr:
    db "Left!", 0
RightStr:
    db "Right!", 0
