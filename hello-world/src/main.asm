INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
EntryPoint:
    di
    jp start

; Space reserved for header
REPT $150 - $104
    db 0
ENDR

SECTION "Game code", ROM0
start:
.waitVBlank
    ld a, [rLY]
    cp 144 ; Check if the LCD is past VBlank
    jr c, .waitVBlank

    ; Turn off LCD
    xor a
    ld [rLCDC], a

    ; Load font data
    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyFont
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de ; Move to next byte
    dec bc ; Decrement count
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, .copyFont

    ; Copy HelloWorldStr to $9800 (top left of screen)
    ld hl, $9800
    ld de, HelloWorldStr
.copyString
    ld a, [de]         ; Copy [de] into [hl] and increment hl
    ld [hli], a
    inc de             ; Next source byte
    and a              ; Check if the byte we just copied is zero
    jr nz, .copyString ; Continue if it's not

    ; Init display pallette
    ld a, %11100100
    ld [rBGP], a

    ; Init scroll registers to 0
    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

    ; Turn screen on & display background
    ld a, %10000001
    ld [rLCDC], a

    halt

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "Hello World string", ROM0

HelloWorldStr:
    db "Hello World!", 0