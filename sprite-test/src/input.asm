SECTION "Input Code", ROM0

ReadInput:
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

CheckBallBounds:
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

CheckDeath:
    ret ; Temporary death removal
    ld a, [ramBALL_Y]
    cp a, BALL_Y_MAX
    jr nz, .done
    xor a, a
    ld [ramBALL_X_DIR], a
    ld [ramBALL_Y_DIR], a
.done
    ret

CheckPaddleCollision:
    ld a, [ramBALL_Y]
    cp a, PADDLE_Y+2
    ret nz

    ld a, [ramPADDLE_X]
    sub a, 5 ; compensate for sprite width
    ld hl, ramBALL_X
    cp a, [hl]
    ret nc

    add a, 5 + PADDLE_TILE_WIDTH * 8 + 5
    cp a, [hl]
    ret c

    ld a, -1
    ld [ramBALL_Y_DIR], a
    ret

MoveBall:
    ld hl, ramBALL_X
    ld a, [ramBALL_X_DIR]
    add a, [hl]
    ld [hl], a
    ld hl, ramBALL_Y
    ld a, [ramBALL_Y_DIR]
    add a, [hl]
    ld [hl], a
    ret
