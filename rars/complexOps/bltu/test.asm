.data
.word 10 # number of times it loops
.word 4  # step

.text
	lw a0, 0(zero)
	lw a1, 4(zero)
	addi t0, zero, 1
	addi t1, zero, 0
	nop
	nop
	nop
	sw t1, 0(zero)
START_LOOP:
	add t1, t1, a1
	addi t0, t0, 1
	nop
	nop
	nop
	sw t1, 0(t1)
	bltu t0, a0, START_LOOP
	nop
	nop
	nop

