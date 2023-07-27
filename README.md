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

#### Assembly

Crie uma nova pasta em `rars/` para colocar os arquivos relacionados a esse teste. Crie o código assembly que gostaria de testar, e então faça o dump das memórias do .text e do .data em hexadecimal usando o Rars:
![Rars dump](public/rars_dump.png)

Depois, use o script `helpers/convert_hex.py` para converter o dump do Rars em um arquivo que não dê erro ao ser usado pelo ModelSim (da maneira que foi feita).

#### Testbench

Copie o arquivo `tb_simple_ops.vhd` para a pasta do seu teste, e então altere a linha que contém `../rars/simpleOps/instr_dump.txt` para o caminho do seu arquivo de teste.

Copie o setup do testbench, e altere somente a quantidade de ciclos que o processador roda e os asserts logo após.
