SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "strings", ROM0

LeftButtonStr:
    db "Left", 0
RightButtonStr:
    db "Right", 0
UpButtonStr:
    db "Up", 0
DownButtonStr:
    db "Down", 0
StartButtonStr:
    db "Start", 0
SelectButtonStr:
    db "Select", 0
AButtonStr:
    db "A", 0
BButtonStr:
    db "B", 0
ClearStr:
    db "      ", 0