.data
.word 15 # A
.word 50 # B
# A + B

.text
	lw a0, (zero)
	lw a1, 4(zero)
	jal main
	nop
	nop
	nop
	nop
	nop
	# Código morto, não é atingido caso jal funcione
	add a0, a1, a0
funct:
	sw a0, 8(zero)
	sw ra, 12(zero)
	jalr t1, 0(ra)
	nop
	nop
	nop
	nop
	
	
main:
	add a0, a1, a0
	nop
	nop
	nop
	jal funct
	nop
	nop
	nop
	nop
	sw t1, 16(zero)
	
	
