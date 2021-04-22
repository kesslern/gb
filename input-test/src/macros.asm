; Wait for VBlank
waitVBlank: MACRO
    ld  a, [rSTAT]
    and STATF_BUSY
    jr  nz, @-4
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
    bit \1, a
    jr z, .pressed\@
    m_strcpy ClearStr, \3
    jr .done\@
.pressed\@:
    m_strcpy \2, \3
.done\@
ENDM