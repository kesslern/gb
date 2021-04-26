MovePaddle:
    ld a, [ramInput]

.left:
    ; Check if left button pressed.
    bit 5, a
    jr nz, .right

    ; Left is pressed. Ensure there's space to move left.
    ld hl, ramPADDLE_X
    ld a, [hl]
    cp a, PADDLE_X_MIN
    ret z

    ; Set new X location and update. 
    ld a, [hl]
    sub a, 2
    jr .update


.right:
    ; Check if right button pressed.
    bit 4, a
    ret nz

    ; Right is pressed. Ensure there's space to move right.
    ld hl, ramPADDLE_X
    ld a, PADDLE_X_MAX
    cp a, [hl]
    ret z

    ; Set new X location and update. 
    ld a, [hl]
    add a, 2

    ; Update the paddle sprite locations.
    ; a  - left sprite X location
    ; hl - left sprite X location in memory
.update
    ld [hl], a
    REPT 3
    inc l
    inc l
    inc l
    inc l
    add a, 8
    ld [hl], a
    ENDR

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