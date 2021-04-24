SECTION "Memory functions", ROM0

; Copy a chunk of memory of known size.
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

; src -> dest
m_strcpy: MACRO
    ld de, \1
    ld hl, \2
    call strcpy
ENDM

; Zero a chunk of memory.
; @param bc - Number of bytes to zero
; @param hl - Start address
zero:
    xor a, a
    ld [hli], a ; Place it at the destination, incrementing hl
    dec bc      ; Decrement count
    ld a, b     ; Check if count is 0
    or c
    jr nz, zero
    ret

; Copy a 0-terminated string to VRAM
; @param de - Source addressppp
; @param hl - Destination address
strcpy:
    ld a, [de]  ; Grab 1 byte from source address
    ld [hli], a ; Write to memory & increment destination addr
    inc de      ; Increment source addr
    and a       ; Check if the byte we just copied is zero
    jr nz, strcpy
    ret