INCLUDE "hardware.inc"
INCLUDE "constants.inc"

INCLUDE "data.asm"
INCLUDE "header.asm"
INCLUDE "graphics.asm"
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
    call readInput
    call moveBall
    call checkBallBounds
    call checkPaddleCollision
    call checkDeath

.left:
    ld a, [ramInput]
    bit 5, a
    jr nz, .right

    ld hl, ramPADDLE_X
    ld a, [hl]
    cp a, PADDLE_X_MIN
    jr z, .done
    dec [hl]
    dec [hl]
    REPT 3
    inc l
    inc l
    inc l
    inc l
    dec [hl]
    dec [hl]
    ENDR


.right:
    ld a, [ramInput]
    bit 4, a
    jr nz, .done

    ld hl, ramPADDLE_X
    ld a, PADDLE_X_MAX
    cp a, [hl]
    jr z, .done
    inc [hl]
    inc [hl]
    REPT 3
    inc l
    inc l
    inc l
    inc l
    inc [hl]
    inc [hl]
    ENDR

.done
    halt
    jp Loop

Draw:
    call _HRAM
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
    ld [ramInput], a ; Store input in $C000 work ram
    ret

moveBall:
    ld hl, ramBALL_X
    ld a, [ramBALL_X_DIR]
    add a, [hl]
    ld [hl], a
    ld hl, ramBALL_Y
    ld a, [ramBALL_Y_DIR]
    add a, [hl]
    ld [hl], a
    ret

checkBallBounds:
    ld a, [ramBALL_X]
    cp a, BALL_X_MIN
    jr nz, .next1
    ld a, 1
    ld [ramBALL_X_DIR], a
.next1
    ld a, [ramBALL_X]
    cp a, BALL_X_MAX
    jr nz, .next2
    ld a, -1
    ld [ramBALL_X_DIR], a
.next2
    ld a, [ramBALL_Y]
    cp a, BALL_Y_MIN
    jr nz, .next3
    ld a, 1
    ld [ramBALL_Y_DIR], a
.next3
    ; This can be removed when death is added
    ld a, [ramBALL_Y]
    cp a, BALL_Y_MAX
    jr nz, .next4
    ld a, -1
    ld [ramBALL_Y_DIR], a
.next4
    ret

checkDeath:
    ret ; Temporary death removal
    ld a, [ramBALL_Y]
    cp a, BALL_Y_MAX
    jr nz, .done
    xor a, a
    ld [ramBALL_X_DIR], a
    ld [ramBALL_Y_DIR], a
.done
    ret

checkPaddleCollision:
    ld a, [ramBALL_Y]
    cp a, PADDLE_Y+2
    jr nz, .done

    ld a, [ramPADDLE_X]
    sub a, 5 ; compensate for sprite width
    ld hl, ramBALL_X
    cp a, [hl]
    jr nc, .done

    add a, 5 + PADDLE_TILE_WIDTH * 8 + 5
    cp a, [hl]
    jr c, .done

    ld a, -1
    ld [ramBALL_Y_DIR], a
.done
    ret