13.10 Modo de permissão octal

Ao invés de utilizar os modos de permissão +r, -r, etc, pode ser usado o modo octal para se alterar a permissão de acesso a um arquivo. O modo octal é um conjunto de oito números onde cada número define um tipo de acesso diferente.

É mais flexível gerenciar permissões de acesso usando o modo octal ao invés do comum, pois você especifica diretamente a permissão do dono, grupo, outros ao invés de gerenciar as permissões de cada um separadamente. Abaixo a lista de permissões de acesso octal:

0 - Nenhuma permissão de acesso. Equivalente a -rwx.

1 - Permissão de execução (x).

2 - Permissão de gravação (w).

3 - Permissão de gravação e execução (wx). Equivalente a permissão 2+1

4 - Permissão de leitura (r).

5 - Permissão de leitura e execução (rx). Equivalente a permissão 4+1

6 - Permissão de leitura e gravação (rw). Equivalente a permissão 4+2

7 - Permissão de leitura, gravação e execução. Equivalente a +rwx (4+2+1).

O uso de um deste números define a permissão de acesso do dono, grupo ou outros usuários. Um modo fácil de entender como as permissões de acesso octais funcionam, é através da seguinte tabela:

     1 = Executar
     2 = Gravar
     4 = Ler
     
     * Para Dono e Grupo, multiplique as permissões acima por x100 e x10.
e para as permissões de acesso especiais:

     1000 = Salva imagem do texto no dispositivo de troca
     2000 = Ajusta o bit setgid na execução
     4000 = Ajusta o bit setuid na execução
Basta agora fazer o seguinte:

Somente permissão de execução, use 1.

Somente a permissão de leitura, use 4.

Somente permissão de gravação, use 2.

Permissão de leitura/gravação, use 6 (equivale a 2+4 / Gravar+Ler).

Permissão de leitura/execução, use 5 (equivale a 1+4 / Executar+Ler).

Permissão de execução/gravação, use 3 (equivale a 1+2 / Executar+Gravar).

Permissão de leitura/gravação/execução, use 7 (equivale a 1+2+4 / Executar+Gravar+Ler).

Salvar texto no dispositivo de troca, use 1000.

Ajustar bit setgid, use 2000.

Ajustar bip setuid, use 4000.

Salvar texto e ajustar bit setuid, use 5000 (equivale a 1000+4000 / Salvar texto + bit setuid).

Ajustar bit setuid e setgid, use 6000 (equivale a 4000+2000 / setuid + setgid).

Vamos a prática com alguns exemplos:

     "chmod 764 teste"
Os números são interpretados da direita para a esquerda como permissão de acesso aos outros usuários (4), grupo (6), e dono (7). O exemplo acima faz os outros usuários (4) terem acesso somente leitura (r) ao arquivo teste, o grupo (6) ter a permissão de leitura e gravação (w), e o dono (7) ter permissão de leitura, gravação e execução (rwx) ao arquivo teste.

Outro exemplo:

     "chmod 40 teste"
O exemplo acima define a permissão de acesso dos outros usuários (0) como nenhuma, e define a permissão de acesso do grupo (4) como somente leitura (r). Note usei somente dois números e então a permissão de acesso do dono do arquivo não é modificada (leia as permissões de acesso da direita para a esquerda!). Para detalhes veja a lista de permissões de acesso em modo octal no inicio desta seção.

     "chmod 751 teste"
O exemplo acima define a permissão de acesso dos outros usuários (1) para somente execução (x), o acesso do grupo (5) como leitura e execução (rx) e o acesso do dono (7) como leitura, gravação e execução (rwx).

     "chmod 4751 teste"
O exemplo acima define a permissão de acesso dos outros usuários (1) para somente execução (x), acesso do grupo (5) como leitura e execução (rx), o acesso do dono (7) como leitura, gravação e execução (rwx) e ajusta o bit setgid (4) para o arquivo teste.

