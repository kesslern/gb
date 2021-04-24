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

StartLCD:
    ld a, LCDCF_ON|LCDCF_BGON|LCDCF_BG8000|LCDCF_OBJ8|LCDCF_OBJON
    ld [rLCDC], a
    ret