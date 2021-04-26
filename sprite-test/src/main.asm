INCLUDE "hardware.inc"
INCLUDE "constants.inc"

INCLUDE "data.asm"
INCLUDE "game_logic.asm"
INCLUDE "graphics.asm"
INCLUDE "header.asm"
INCLUDE "input.asm"
INCLUDE "memfns.asm"

SECTION "vBlank interrupt handler", ROM0[$0040]
    call Draw
    reti

SECTION "Game code", ROM0
Start:
    call InitLCD

    ; Shut sound down
    ld [rNR52], a

    ei
    jp Loop

Loop:
    call ReadInput
    call MoveBall
    call MovePaddle
    call CheckBallBounds
    call CheckPaddleCollision
    call CheckDeath
    halt
    jp Loop

Draw:
    call _HRAM
    ret
