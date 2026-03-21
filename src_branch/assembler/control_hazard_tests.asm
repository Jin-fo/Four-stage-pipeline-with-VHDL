////////////////////////////////////////////////////////////
// BRANCH PREDICTION AND CONTROL HAZARD TEST
////////////////////////////////////////////////////////////

start:
LDI r2, 0, 1			;pc = 0
LDI r3, 0, 0x0002		;pc = 1
LDI r4, 0, 0x0100		;pc = 2
LDI r5, 0, 0x4000		;pc = 3
LDI r7, 0, 0x00			;pc = 4

shift_left:
BGT r4, r5, wait_left	;pc = 5
MLHU r4, r3, r4			;pc = 6
JMP shift_left			;pc = 7

wait_left:
AHS r7, r2, r7			;pc = 8
BNEQ r7, r3, shift_left	;pc = 9

LDI r7, 0, 0x00			;pc = 10

shift_right:
BLT r4, r3, wait_right	;pc = 11
SHRHI 1, r4, r4			;pc = 12
JMP shift_right			;pc = 13

wait_right:	
AHS r7, r2, r7			;pc = 14
BNEQ r7, r3, shift_right;pc = 15
jmp end					;pc = 16					
	
end:
nop						;pc = 17 //delay required :C
jmp start				;pc = 18


; Expected PC per cycle (sequential execution, no pipeline effects)
; 0 1 2 3 4
; 5 6 7 5 6 7 5 6 7 5 6 7 5 6 7 5 6 7 5 6 7 5 8
; 8 9 5 8 9 10
; 11 12 13 11 12 13 11 12 13 11 12 13 11 12 13
; 11 12 13 11 12 13 11 12 13 11 12 13 11 12 13
; 11 12 13 11 12 13 11 12 13 11 12 13 11 14
; 14 15 11 14 15 16
; 16 17 18 0