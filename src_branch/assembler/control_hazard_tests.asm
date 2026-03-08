// ============================================================
// SIMPLIFIED CONTROL HAZARD TEST CASES FOR MMU ISA (8 TESTS)
// ============================================================

// Test 1: BRANCH taken (conditional)
// Expected: Flush IF/ID when condition resolves
TEST0:
    LDI r1, 0, 1			  // PC = 0x00
    LDI r2, 0, 1
    BEQ r2, r1, branch_taken  // r2 == r1, taken
    AU r3, r4, r5             // Dead code (flushed)
branch_taken:
    AU r10, r11, r12
    JMP TEST1				   // PC = 0x05

// Test 1: BRANCH not taken (conditional)
// Expected: No flush, sequential execution
TEST1: 
    LDI r1, 0, 5			  // PC = 0x06
    LDI r2, 0, 3
    BEQ r2, r1, branch_skip  // r2 != r1, not taken
    AU r10, r11, r12         // Executes normally
    AU r13, r14, r15         // Executes normally
    JMP TEST2
branch_skip:
    NOP						 // PC = 0x0C | 0d12

// Test 2: JUMP (unconditional)
// Expected: PC jumps immediately, IF/ID flushed
TEST2:
    JMP loop0				// PC = 0x0D | 0d13
    AU r1, r2, r3          // Dead code (flushed)
    AU r4, r5, r6          // Dead code (flushed)
loop0:
    AU r10, r11, r12
    JMP TEST3				// PC = 0d17

// Test 3: Back-to-back branches
// Expected: First branch flushes second branch
TEST3:
br_target2:
    LDI r1, 0, 7			// PC = 0d18
    LDI r2, 0, 7
    BEQ r2, r1, br_target1   // First branch taken
    BEQ r2, r1, br_target2   // Dead code (flushed)
br_target1:
    AU r10, r11, r12
    JMP TEST4				// PC = 0d23

// Test 4: BTB write and read (forwarding)
// Expected: Write-forward path provides target
TEST4:
    LDI r1, 0, 10			// // PC = 0d24
    LDI r2, 0, 10
    BEQ r2, r1, btb_entry    // Write target to BTB
    AU r3, r4, r5
    LDI r3, 0, 11
    LDI r4, 0, 11
    BEQ r4, r3, btb_entry    // Read from BTB (same index)
btb_entry:
    AU r10, r11, r12
    JMP TEST5				// PC = 0d32

// Test 5: Loop (branch to self)
// Expected: Branch repeatedly to same location
TEST5:
    LDI r1, 0, 3             // Loop counter
    LDI r2, 0, 0
	LDI r3, 0, 1
loop_count:
    AU r02, r03, r02		 // PC = 0d36
    BGT r1, r2, loop_count   // Branch to self
    JMP TEST6				 // PC = 0d38

// Test 6: Nested jump-branch
// Expected: JMP immediate, BRANCH resolves in EX
TEST6:
    JMP nested_jump
    AU r1, r2, r3            // Dead code
nested_jump:
    LDI r1, 0, 7
    LDI r2, 0, 7
    BEQ r2, r1, nested_target
    NOP
nested_target:
    AU r10, r11, r12
    JMP TEST7

// Test 7: Branch with data dependency
// Expected: Stall until AU result available
TEST7:
    LDI r1, 0, 5
    AU r1, r2, r3            // Write to r1
    LDI r2, 0, 5
    BEQ r2, r1, data_target  // RAW hazard: waits for r1
    NOP
data_target:
    AU r10, r11, r12
    NOP                      // End of tests