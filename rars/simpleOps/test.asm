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

	add t0, a0, a1 # 30
	slli t1, a1, 4 # xf0 = 240
	andi t2, a2, 5 # 15 & 5 = 5
	srli t3, a3, 22 # 1
	sub t4, zero, a3 # -2^23 = 0xffc00000
	and t5, a0, a5 # 15 & 1 = 1
	xor t6, a0, a5 # 15 ^ 1 = 14
	auipc a0, 2 # x00002000 + PC (PC = 3064 no rars, 64 no ModelSim)

	sw t0, 24(zero)
	sw t1, 28(zero)
	sw t2, 32(zero)
	sw t3, 36(zero)
	sw t4, 40(zero)
	sw t5, 44(zero)
	sw t6, 48(zero)
	sw a0, 52(zero)
	
	slt t0, t4, t0 	# -... < 30 (true)
	or t1, t6, t4 	# 0xe | 0xffc00000
	srai t2, t4, 21 # 0xfffffffe
	sltu t3, a2, t4 # 15 < uns(-... )(false)

	# a2 = 15
	sw t0, 41(a2)
	sw t1, 45(a2)
	sw t2, 49(a2)
	sw t3, 53(a2)
	
	
	
	
	

### Feitas as instru��es:
# ADDi, ORi, XORi, SLTi, SLTUi, ADD, SLLi, ANDi, SRLi, SUB, AND, XOR, SLT, OR, AUIPC, SRAi, SLTu

### Falta:
# , , , , , , , , , ,
# , , , , , , , ,
# JAL, JALR, BEQ, BNE, BLT, BGE, BGEU, BLTU