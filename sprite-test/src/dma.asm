    ; Copy DMA code into HRAM
    ld hl, _HRAM
    ld de, run_dma
    ld bc, dma_end - run_dma
    call memcpy
    jp dma_end

run_dma:
    ld a, $C100 / $100
    ldh  [$FF46], a ;start DMA transfer (starts right after instruction)
    ld  a ,$28      ;delay...
.wait:           ;total 4x40 cycles, approx 160 μs
    dec a          ;1 cycle
    jr  nz, .wait    ;3 cycles
    ret
dma_end: