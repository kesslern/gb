SECTION "LCD Code", ROM0

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

InitLCD:
    ; Init palette
    ld a, %11011000
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a

    ; Init scroll registers
    xor a
    ld [rSCY], a
    ld [rSCX], a

    ; Enable vblank interrupt
    ld a, [rIE]
    set 0, a
    ld [rIE], a

    ; Zero out Nintendo logo VRAM space
    ld hl, _VRAM8000
    ld bc, $81A0 - _VRAM8000
    call zero

    ; Add gbtest tile test
    ld hl, _VRAM8000 + 32
    ld de, GBT_Tile
    ld bc, 3 * 32
    call memcpy

    ; Zero out memory to copy to OAM
    ld hl, ramOAM
    ld bc, $100
    call zero
    ret

InitSprites:
    ld a, PADDLE_Y
    ld [ramPADDLE_Y + 0 * 4], a
    ld [ramPADDLE_Y + 1 * 4], a
    ld [ramPADDLE_Y + 2 * 4], a
    ld [ramPADDLE_Y + 3 * 4], a

    ld a, 8 * (0+1)
    ld [ramPADDLE_X + 0 * 4], a
    ld a, 8 * (1+1)
    ld [ramPADDLE_X + 1 * 4], a
    ld a, 8 * (2+1)
    ld [ramPADDLE_X + 2 * 4], a
    ld a, 8 * (3+1)
    ld [ramPADDLE_X + 3 * 4], a
    
    ld a, $02
    ld [ramPADDLE_TILE + 0 * 4], a
    ld [ramPADDLE_TILE + 3 * 4], a
    ld a, %00100000 ; flip X
    ld [ramPADDLE_ATTR + 3 * 4], a
    ld a, $03
    ld [ramPADDLE_TILE + 1 * 4], a
    ld [ramPADDLE_TILE + 2 * 4], a

    ld a, 50
    ld [ramBALL_X], a
    ld a, 50
    ld [ramBALL_Y], a
    ld a, $04
    ld [ramBALL_TILE], a

    ld a, 1
    ld [ramBALL_X_DIR], a
    ld [ramBALL_Y_DIR], a
    ret

StartLCD:
    ld a, LCDCF_ON|LCDCF_BGON|LCDCF_BG8000|LCDCF_OBJ8|LCDCF_OBJON
    ld [rLCDC], a
    ret

SECTION "DMA Code", ROM0
init_dma:
    ; Copy DMA code into HRAM
    ld hl, _HRAM
    ld de, run_dma
    ld bc, dma_end - run_dma
    call memcpy
    ret

run_dma:
    ld a, $C100 / $100
    ldh  [$FF46], a ;start DMA transfer (starts right after instruction)
    ld  a ,$28      ;delay...
.wait:           ;total 4x40 cycles, approx 160 μs
    dec a          ;1 cycle
    jr  nz, .wait    ;3 cycles
    ret
dma_end:

