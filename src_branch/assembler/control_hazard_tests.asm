; -------------------------
; Ping-Pong Loop test
; -------------------------

start:
LDI r2, 0, 1
LDI r3, 0, 0x0002
LDI r4, 0, 0x0100
LDI r5, 0, 0x4000
LDI r7, 0, 0x00

go_left:
BGT r4, r5, wait_left; pc = 5
MLHU r4, r3, r4
JMP go_left

wait_left:
AHS r7, r2, r7 
BNEQ r7, r3, go_left

LDI r7, 0, 0x00

go_right:
BLT r4, r3, wait_right
SHRHI 1, r4, r4
JMP go_right

wait_right:
AHS r7, r2, r7
BNEQ r7, r3, go_right
jmp end:
end:
jmp start
