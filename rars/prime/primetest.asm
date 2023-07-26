.data
prime1:		.word	2
prime2:		.word	3
prime3:		.word	5
prime4:		.word	7

.text
	lw t1, prime4
	la t3, prime4
	addi t2, t1, 4 #11
	sw t2, 4(t3)
	addi t1, t2, 2 #13
	sw t1, 8(t3)
	addi t2, t1, 4 #17
	sw t1, 12(t3)
	addi t1, t2, 2 #19
	sw t1, 16(t3)
	addi t2, t1, 4 #23
	sw t1, 20(t3)
	addi t1, t2, 6 #29
	sw t1, 24(t3)
	addi t2, t1, 2 #31
	sw t1, 28(t3)
	addi t1, t2, 6 #37
	sw t1, 32(t3)
	addi t2, t1, 4 #41
	sw t1, 36(t3)
	addi t1, t2, 2 #43
	sw t1, 40(t3)
	addi t2, t1, 4 #47
	sw t1, 44(t3)
	addi t1, t2, 6 #53
	sw t1, 48(t3)
	addi t2, t1, 6 #59
	sw t1, 52(t3)
	addi t1, t2, 2 #61
	sw t1, 56(t3)
	addi t2, t1, 6 #67
	sw t1, 60(t3)
	addi t1, t2, 4 #71
	sw t1, 64(t3)