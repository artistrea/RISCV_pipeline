.text
	addi t1, zero, 15 # 15
	ori t2, zero, 15  # 15
	xori t3, zero, 15 # 15
	lui t4, 1024  	  # 2^10 * 2^13
	slti t5, zero, -1 # 0
	sltiu t0, zero, -1# 1

	sw t1, (zero)
	sw t2, 4(zero)
	sw t3, 8(zero)
	sw t4, 12(zero)
	sw t5, 16(zero)
	sw t0, 20(zero)

	lw a0, (zero)
	lw a1, 4(zero)
	lw a2, 8(zero)
	lw a3, 12(zero)
	lw a4, 16(zero)
	lw a5, 20(zero)
	
	add a6, a0, a1 # 30
	nop
	nop
	nop
	nop
	sw a6, 24(zero)
	
	
	

### Feitas as instruções:
# ADDi, ORi, XORi, SLTi, SLTUi, ADD

### Falta:
# , , SUB, AND, ANDi, , SLT, OR, , XOR,
# , SLLi, SRLi, SRAi, , SLTu, , AUIPC,
# JAL, JALR, BEQ, BNE, BLT, BGE, BGEU, BLTU