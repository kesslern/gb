SECTION "Header", ROM0[$0100]
    di
    jp Start

; Space for header
REPT $0150 - $0104
    db 0
ENDR
