# Projeto RISCV Pipeline

Esse projeto foi feito para a disciplina de Organização e Arquitetura de Computadores, do curso de Engenharia de Computação da Universidade de Brasília (UnB). Está disponibilizado no [github](https://github.com/artistrea/RISCV_pipeline).

## Objetivo

Montar um processador RISCV de 5 estágios com pipeline usando o ModelSim. Gerar arquivos em hexadecimal usando o Rars para poder realizar os testes.

Conforme especificado no enunciado, o processador deve ser capaz de executar as seguintes instruções:

ADDi, ORi, XORi, SLTi, SLTUi, ADD, SUB, AND, ANDi, SLT, OR, XOR, SLLi, SRLi, SRAi, SLTU, AUIPC, JAL, JALR, BEQ, BNE, BLT, BGE, BGEU, BLTU

## Organização

O projeto está organizado da seguinte forma:

- `modelsim/`: contém os arquivos do projeto do ModelSim
- `public/`: contém imagens usadas no README
- `rars/`: contém os arquivos do Rars
- `helpers/`: contém scripts auxiliares para gerar os arquivos de teste

## Como rodar

Tenha o ModelSim configurado corretamente, abra o projeto e rode o testbench desejado.

### Configurando o ModelSim

Adicione todos os arquivos modelsim/\*.vhd no projeto modelsim. Abra as propriedades de todos eles:
![properties](public/properties.png)

E use a opção de compilação `1076-2008`:

![Compile options](public/compile_opts.png)

### Rodando o testbench

Usando o modelsim, inicie uma simulação de algum dos testbenchs feitos para o processador, como o `tb_simple_ops`.

Perceba que os testbenchs fazem vários asserts, e que se algum deles falhar, a simulação irá escrever `Erro: ...` nos seus logs de simulação.

### Gerando arquivos de teste

#### Configurando o RARS

Configura a memória para ter memória de dados iniciando em 0:
![Alt text](public/rars_mem_config.png)

#### Assembly

Crie uma nova pasta em `rars/` para colocar os arquivos relacionados a esse teste. Crie o código assembly que gostaria de testar, e então faça o dump das memórias do .text e do .data em hexadecimal usando o Rars:
![Rars dump](public/rars_dump.png)

Depois, use o script `helpers/convert_hex.py` para converter o dump do Rars em um arquivo que não dê erro ao ser usado pelo ModelSim (da maneira que foi feita).

#### Testbench

Altere o arquivo de testbench que deseja usar para que ele use o arquivo de teste que você gerou. Por exemplo, no `tb_complex_ops.vhd`, troque a linha:

```vhdl
constant TEST_FILE : string := "rars/complex_ops/data_mem.txt";
```

Para:

```vhdl
constant TEST_FILE : string := "rars/<caminho da pasta do teste>/data_mem.txt";
```
