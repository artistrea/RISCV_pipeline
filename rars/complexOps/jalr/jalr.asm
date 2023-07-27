.data
.word 10 # LIMIT depth

.text
	jal main
	nop
	nop
	nop
	nop
funct1:
	addi a0, a0, 1
	addi a1, a1, 4
	nop
	nop
	nop
	nop
	nop
	sw a0, 0(a1)
	sw ra, 0(sp)
	addi sp, sp, -4
	bge a0, a2, stop_recursion
	nop
	nop
	nop
	nop
	nop
	jal funct1
	nop
	nop
	nop
	nop
	nop
	nop
	stop_recursion:
		addi sp, sp, 4
		addi a0, a0, -1
		nop
		nop
		nop
		nop
		nop
		lw ra, 0(sp)
		sw a0, 0(a1)
		addi a1, a1, 4
		nop
		nop
		nop
		nop
		nop
		jalr zero, 0(ra)
		nop
		nop
		nop
		nop
		nop
	
	
main:
	nop
	nop
	lw a2, (zero)
	nop
	nop
	nop
	jal funct1
	nop
	nop
	nop
	nop
	nop
	
	