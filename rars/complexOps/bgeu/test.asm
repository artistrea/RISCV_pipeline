.data
.word 10
.word 4

.text
	lw a0, 0(zero)
	lw a1, 4(zero)
	addi t0, zero, 1
	addi t1, zero, 0
	nop
	nop
	nop
START_LOOP:
	add t1, t1, a1
	addi t0, t0, 1
	nop
	nop
	nop
	sw t1, 0(t1)
	bgeu a0, t0, START_LOOP
	nop
	nop
	nop