EXEMPLO DE MINI-REDE NO MININET

Topologia de rede no Mininet configurada em Python com Switch BMv2 (utilizando linguagem P4)

----------------------------------------------------------------------------------------------

REQUISITOS PARA EXECUCAO

SISTEMA UBUNTU 20.04

Dependencias necessarias: P4C, BMv2, Mininet

---------------------------------------------------------------------------------------------

Ao ter todas as dependencias instaladas, basta abrir o terminal do Ubuntu no diretorio onde estao esses dois arquivos ('basic.p4', 'topologia.py') e executar os comandos:

```bash
p4c --target bmv2 --arch v1model -o basic.json basic.p4 
```
responsavel por compilar o arquvio .p4 para .json

```bash
sudo python3 topo.py
```
responsavel por iniciar a rede definida
