.data
.word 100 # write this number on mem

.text
	lw a0, 0(zero)
	addi t0, zero, 0
	addi t1, zero, 4
	nop
	nop
	nop
START_LOOP:
	addi t0, t0, 4
	nop
	nop
	nop
	sw a0, (t0)
	beq t0, t1, START_LOOP
	nop
	nop
	nop
	
	
