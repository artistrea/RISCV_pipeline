[Read in english](./README.md)

# Projeto RISCV Pipeline

Este projeto foi feito para a disciplina de Organização e Arquitetura de Computadores, do curso de Engenharia de Computação da Universidade de Brasília (UnB). Está disponibilizado no [github](https://github.com/artistrea/RISCV_pipeline).

## Objetivo

Montar um **processador RISCV** de 5 estágios com **pipeline** usando o **ModelSim**. Gerar arquivos em hexadecimal usando o Rars para poder realizar os testes.

Conforme especificado no enunciado, o processador deve ser capaz de executar as seguintes instruções:

ADDi, ORi, XORi, SLTi, SLTUi, ADD, SUB, AND, ANDi, SLT, OR, XOR, SLLi, SRLi, SRAi, SLTU, AUIPC, JAL, JALR, BEQ, BNE, BLT, BGE, BGEU, BLTU

Como adicional, podem ser feitos mecanismos para lidar com _Hazard_, mas o resultado mínimo é um **simulador de processador** que consegue **executar um programa que evite os _hazards_**.

## Organização

O projeto está organizado da seguinte forma:

- `modelsim/`: contém os arquivos do projeto do ModelSim
- `public/`: contém imagens usadas no README
- `rars/`: contém os arquivos do Rars
- `helpers/`: contém scripts auxiliares para gerar os arquivos de teste

## Como rodar

Abra o projeto, configure o ModelSim corretamente e rode o testbench desejado.

### Configurando o ModelSim

Adicione todos os arquivos modelsim/\*.vhd no projeto modelsim. Abra as propriedades de todos eles:
![properties](public/properties.png)

E use a opção de compilação `1076-2008`:

![Compile options](public/compile_opts.png)

### Rodando o testbench

Dois testbenchs principais foram feitos. O das operações lógico-aritméticas e de memória são testadas em `tb_simple_ops.vhd`, e o das operações de desvio estão em `tb_complex_ops.vhd`. O primeiro testbench não deve ser alterado, pois o teste para cada operação foi feito na mão.

O testbench `tb_complex_ops.vhd` **pode ser alterado** para **testar outros programas**. Para isso, altere a linha:

```vhdl
file text_file : text open read_mode is "../rars/complexOps/jalr/instr_dump.txt";
file data_file : text open read_mode is "../rars/complexOps/jalr/data_dump.txt";
file data_after_file : text open read_mode is "../rars/complexOps/jalr/data_after_dump.txt";
```

Para:

```vhdl
file text_file : text open read_mode is "../rars/complexOps/<nome-do-teste-desejado>/instr_dump.txt";
file data_file : text open read_mode is "../rars/complexOps/<nome-do-teste-desejado>/data_dump.txt";
file data_after_file : text open read_mode is "../rars/complexOps/<nome-do-teste-desejado>/data_after_dump.txt";
```

Veja a pasta `rars/complexOps/` para considerar as opções de testes já criados. Após alterar essas linhas para selecionar o teste desejado, recompile e rode o testbench.

Perceba que, caso ocorra alguma discrepância entre o resultado esperado e o resultado obtido, o testbench irá escrever uma mensagem de erro no console do ModelSim.

### Gerando arquivos de teste

Esta seção existe para caso queira criar seus próprios arquivos de teste.

#### Configurando o RARS

Configura a memória para ter memória de dados iniciando em 0:
![Alt text](public/rars_mem_config.png)

#### Assembly

Crie uma nova pasta em `rars/` para colocar os arquivos relacionados a esse teste. Crie o código assembly que gostaria de testar, e então faça o dump das memórias do .text e do .data em hexadecimal usando o Rars:
![Rars dump](public/rars_dump.png)

Para poder rodar seu teste no testbench _complexOps_, você deve fazer dump para 3 arquivos:

- `instr_dump.txt` deve conter o dump do `.text`;
- `data_dump.txt` deve conter o dump do `.data` **antes** de rodar o programa;
- `data_after_dump.txt` deve conter dump do `.data` **depois** de rodar o programa (no próprio Rars).

Depois, use o script `helpers/convert_hex.py` para converter o dump do Rars em um arquivo que não dê erro ao ser usado pelo ModelSim (da maneira que foi feita).

Então pode seguir os passos para [rodar testbench normalmente](#rodando-o-testbench)

## Conclusão

Ao fim do projeto, as seguintes operações do processador foram implementadas corretamente:

ADDi, ORi, XORi, SLTi, SLTUi, ADD, SUB, AND, ANDi, SLT, OR, XOR, SLLi, SRLi, SRAi, SLTU, AUIPC, JAL, BEQ, BNE, BLT, BGE, BGEU, BLTU

E a única instrução que apresentou problemas ao ser utilizada foi JALR.

Não foram feitos soluções de _Hazard_ em nível de processador, então os conflitos devem ser evitados pelo software/compilador (assembly).

Foi utilizado arquitetura Harvard ao construir o processador.
