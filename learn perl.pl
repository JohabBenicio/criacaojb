Felizmente perl pode te ajudar a encontrar estes erros automaticamente. Para isso, você só precisa incluir a seguinte linha no início do seu programa:

 use strict;


##########################################################################################################################################################
TOP
http://sao-paulo.pm.org/pub/primeiros-passos-em-perl

##########################################################################################################################################################

erencias Web em Perl hoje são:

Catalyst
Site: http://www.catalystframework.org
PerlDoc: http://search.cpan.org/~bobtfish/Catalyst-Runtime-5.90019/lib/Catalyst.pm

Mojolicious
Site: http://mojolicio.us
PerlDoc: http://search.cpan.org/~sri/Mojolicious-3.65/lib/Mojolicious.pm

Dancer
Site: http://perldancer.org
PerlDoc: http://search.cpan.org/~xsawyerx/Dancer-1.3110/lib/Dancer.pm

E se você insistir em usar CGI, busque algum framework como o CGI::Application por exemplo.

CGI::Application
Site: http://www.cgi-app.org
PerlDoc: http://search.cpan.org/~markstos/CGI-Application-4.50/lib/CGI/Application.pm

Para se aprender bem a programar em perl a dica que eu dou é sempre ler a documentação da linguagem que
acompanha sua distribuição perl ou pode ser vista na web através do endereço http://perldoc.perl.org

Se o inglês for algo impeditivo temos boas referencias em portugues:

O site http://perl.org.br é uma boa escolha e apesar de desatualizado conta com varios artigos e
traduções dos docs oficiais do Perl.

Ja o http://sao-paulo.pm.org é o site da comunidade dos São Paulo Perl Mongers e conta com alguns artigos
escritos por alguns dos melhores desenvolvedores Perl do Brasil (contando com a galera do rio e de outras
comunidades) hehehe. ;-)

E se tiver alguma duvida sobre como fazer algo, assine a mail-list e a galera vai estar prota para lhe
ajudar e faze-lo amadurecer como um programador!

Qualquer coisa me mande um email que também posso lhe ajudar!

Grande abraço,


my $numArgs = $#ARGV + 1;
print "thanks, you gave me $numArgs command-line arguments.\n";

foreach my $argnum (0 .. $#ARGV) {

   print "$ARGV[$argnum]\n";

}


foreach my $argnum


                           Numeric Test      String Test
Equal                           ==                eq
Not equal                       !=                ne
Less than                       <                 lt
Greater than                    >                 gt
Less than or equal to           <=                le
Greater than or equal to        >=                ge




# Argumentos passados
print $ARGV[0];
print $ARGV[1];



# Para ve se o parametro esta nulo ou n
my $param = $ARGV[0];
if (defined $param) {
    print "arg: $param\n";
} else {
    print "No arg\n";
}


# TESTING...ONE, TWO...TESTING
if ($x == 7) {
    print '$x is equal to 7!';
    print "<br />";
}
if (($x == 7) || ($y == 7)) {
    print '$x or $y is equal to 7!';
    print "<br />";
}
if (($x == 7) && ($y == 7)) {
    print '$x and $y are equal to 7!';
    print "<br />";
}



$PARAMETER_FILE="/home/zabbix/etc/parameters.txt";
if (! -f $PARAMETER_FILE) {
    print "arg: $PARAMETER_FILE\n";
    print "Arquivo encontrado!!!\n\n\n";
} else {
    print "No arg\n";
    close
}
print "# FIM\n";


#############################################################################
# http://www.perlmonks.org/?node_id=98208
my $string = quotemeta 'string to search for';
my $slurp;
{
    local $/ = undef;
    open my $textfile, '<', 'searchfile.txt' or die $!;
    $slurp = <$textfile>;
    close $textfile;
}

while( $slurp =~ m/ ( .{0,25} $string.{0,25} )gisx / ) {
    print "Found $1\n";
}



sub subroutine_name{
   body of the subroutine
}



if exists teste {
    print "teste ok"
    print "<br />"
}

 if exists $hash{$key}


switch(argument){
   case 1            { print "number 1" }
   case "a"          { print "string a" }
   case [1..10,42]   { print "number in list" }
   case (\@array)    { print "number in list" }
   case /\w+/        { print "pattern" }
   case qr/\w+/      { print "pattern" }
   case (\%hash)     { print "entry in hash" }
   case (\&sub)      { print "arg to subroutine" }
   else              { print "previous case not true" }
}



https://br.perlmaven.com/como-ler-um-arquivo-csv-usando-perl




Este comando: perl -i.bak -p -e "s/\bJava\b/Perl/" resume.txt irá substituir todas as ocorrências da palavra Java pela palavra Perl em seu currículo, mantendo um backup do arquivo.

No Linux você pode até escrever perl -i.bak -p -e "s/\bJava\b/Perl/" *.txt para substituir Java por Perl em todos os seus arquivos de texto.

#########################################################################################################################################################

Comando index
Há também a função index. Esta função recebe dois textos e retorna a posição do segundo texto dentro do primeiro.

use strict;
use warnings;
use 5.010;

my $str = "O gato preto pulou da árvore verde";

say index $str, 'gato';            # 2
say index $str, 'cachorro';        # -1
say index $str, "O";               # 0
say index $str, "o";               # 5
say index $str, "árvore";          # 22

#########################################################################################################################################################

Comando substr

Eu acho que a função mais interessante neste artigo é a substr. Ela atua basicamente de forma oposta ao index(). Enquanto que o index() irá lhe dizer aonde está um determinado texto, substr irá lhe retornar uma parte do texto em uma determinada posição. Normalmente a função substr recebe três parâmetros, o primeiro é o texto, o segundo é a posição de início (também conhecida como offset) e o terceiro é o tamanho da parte ou fragmento do texto que deseja recuperar.

use strict;
use warnings;
use 5.010;

my $str = "O gato preto subiu na árvore verde";

say substr $str, 7, 5;                      # preto
A substr() inicia pela posição 0, portanto o caractere no offset 7 é a letra p.

say substr $str, 2, -12;                    # gato preto subiu na
O terceiro parâmetro (o tamanho) pode também ser um valor negativo. Neste caso ele nos retorna o número de caracteres a partir do lado direito do texto original que NÃO deverá ser incluído. Ou seja, conte 2 a partir da esquerda, 11 a partir da direita e retorne o que há no meio.

say substr $str, 13;                        # subiu na árvore verde
Você pode também ignorar o terceiro parâmetro, que significa: retorne todos os caracteres iniciando na quarta posição e seguindo até o final do texto.

say substr $str, -5;                        # verde
say substr $str, -5, 2;                     # ve
Nós podemos também utilizar um número negativo no offset, o que significa: Contar cinco a partir da direita e iniciar a partir dessa posição. É o equivalente a ter length($str)-4 no offset.


Substituindo parte de um texto
O último exemplo é um pouco mais estiloso. Até o momento, em todos os casos substr retornou uma parte do texto e deixou o texto original intacto. Neste exemplo, o valor de retorno da função continuará sendo o mesmo, porém a função substr também irá alterar o conteúdo do texto original!

O valor de retorno da substr é sempre determinado pelos três primeiros parâmetros, mas neste caso a função possuirá um quarto parâmetro. Esse novo elemento será um texto que irá substituir a região selecionada do texto original.

my $z = substr $str, 13, 5, "pulou";
say $z;                                                     # subiu
say $str;                  # O gato preto pulou na árvore verde
Portanto substr $str, 13, 5, "pulou na" retorna a palavra subiu, mas por causa do quarto parâmetro, o texto original foi alterado.


#########################################################################################################################################################
Comando split

Usando o split
A função split() geralmente recebe dois parâmetros. O primeiro é a faca e o segundo o que precisa ser cortado em pedaços.

A faca geralmente é uma expressão regular mas por enquanto vamos nos ater apenas a textos simples.

se eu tenho um texto do tipo $str = "Tudor:Vidor:10:Hapci" eu posso chamar @fields = split(":" , $str);. O array @fields será preenchido com 4 elementos: "Tudor", "Vidor", "10" and "Hapci". Se eu fizer print $fields[2] irei ver o número 10 na tela, pois o índex do array inicia em zero.

No nosso caso o separador de campo é o caractere vírgula , e não o caractere de dois pontos : então a nossa função para split ficará assim: @fields = split("," , $str); sem que seja necessário mexer nos parênteses.

Nós podemos escrever o nosso script da seguinte maneira:

#!/usr/bin/perl
use strict;
use warnings;

my $file = $ARGV[0] or die "Need to get CSV file on the command line\n";

my $sum = 0;
open(my $data, '<', $file) or die "Could not open $file $!\n";

while (my $line = <$data>) {
  chomp $line;

  my @fields = split "," , $line;
  $sum += $fields[2];
}
print "$sum\n";
Se você salvar isso como csv.pl então poderá rodar o script passando o arquivo csv de entrada pela linha de comando perl csv.pl data.csv.

#########################################################################################################################################################
comando for

Laço "foreach"
Digite o seguinte programa e salve-o como "foreach.pl":

 use strict;

 for my $i (1..10) {
   print "$i\n";
 }

Opa! De onde surgiu essa variável "$_"???

A variável $_ é a chamada "variável padrão", que surge magicamente dentro de um loop, quando não especificamos uma variável.

Você também pode inverter a ordem da expressão:

 print "$_\n" for (1..10);


#########################################################################################################################################################

Comando while

use strict;
use warnings;
use 5.010;

my $contador = 10;

while ($contador > 0) {
  say $contador;
  $contador -= 2;
}
say 'pronto';


Laços infinitos
No código exemplo acima nós sempre reduzimos o valor da variável, dessa forma garantimos que em algum momento a condicional seria falsa. Se por algum motivo a condicional nunca se tornar falsa você terá um laço infinito. O seu programa ficará preso em um pequeno bloco de execução e nunca conseguirá escapá-lo.

Isso aconteceria se nós por exempĺo, estivéssemos esquecido de reduzir o valor da variável $contador, ou se nós estivéssemos aumentando o seu valor.

Se nesse caso fosse um acidente, então nós teríamos um bug.

Por outro lado, em alguns casos o uso proposital de laços infinitos pode deixar o seu programa mais simples de escrever e fácil de ser lido. E nós adoramos código fácil de ser lido! Se nós fossemos utilizar um laço infinito, poderíamos utilizar uma condição que sempre seja verdadeira.

Então podemos escrever:

while (42) {
  # faça algo aqui
}
É claro que pessoas que não possuam as referências culturais adequadas irão se perguntar o porque de usar 42, então podemos utilizar o sempre entediante número 1 em laços infinitos.

#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
while (1) {
  # faça algo aqui
}

#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+

Naturalmente, observando que a execução do código não possui escapatória do laço, você se perguntaria como pode então o programa encerrar a sua execução, talvez sendo interrompido externamente?

Para isso, existem diferentes resoluções:

Uma das soluções é utilizar a declaração last dentro do laço. Dessa forma, a execução irá ignorar o resto do bloco e não irá realizar mais as avaliações da condicional. Efetivamente terminando a execução do laço. As pessoas normalmente utilizam essa declaração dentro de alguma condicional.


#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
use strict;
use warnings;
use 5.010;

while (1) {
  print "Qual linguagem de programação você está aprendendo agora? ";
  my $nome = <STDIN>;
  chomp ($nome);
  if ($nome eq 'Perl')
  { last; }
  say 'Errado! Tente novamente!';
}

say 'pronto';

#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
while (1) {
  # faça algo aqui
}

#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
Neste exemplo nós fazemos uma pergunta ao usuário e esperamos que seja capaz de responder com a resposta correta. Caso não responda 'Perl', ficará preso no laço eternamente.

Então a conversa poderá seguir da seguinte forma:

Qual linguagem de programação você está aprendendo agora?
>  Java
Errado! Tente novamente!
Qual linguagem de programação você está aprendendo agora?
>  PHP
Errado! Tente novamente!
Qual linguagem de programação você está aprendendo agora?
>  Perl
pronto
Como pode observar, uma vez o usuário digitando a resposta correta, a declaração last é invocada e o resto do bloco iincluindo say 'Errado! Tente novamente!'; é ignorado e a execução segue adiante após o laço while.



#########################################################################################################################################################
Comando join

#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
use strict;

 @lista = <>;
 print join (",",@lista);
#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+


Ao executá-lo, o programa ficará esperando que você digite alguma coisa. Digite uma palavra e pressione ENTER. Nada aconteceu?

Na verdade o programa ficará esperando que você digite várias palavras, para colocá-las em uma lista (a variável @lista). Digite mais algumas palavras e pressione Ctrl+D para indicar o término. A lista de palavras será impressa, só que separada por vírgulas.

Isto é feito pelo comando join, que serve para unir os itens de uma lista utilizando um determinado separador. Neste exemplo, os itens são separados por uma vírgula (",").

Mas por que tivemos que digitar Ctrl+D?

Como a variável @lista esperava uma lista de itens separados por ENTER, o Ctrl+D foi usado para indicar quando a lista termina. No Linux, nós podemos gerar um sinal de fim de arquivo (também conhecido como "EOF", ou end of file) através da combinação Ctrl+D. (No MS-DOS e no Windows, você usaria Ctrl+Z.)







$SO=substr("$^O",0,5);
if ($SO eq "MSWin"){
$BAR="\\";
$LOG_OUT='C:\zabbix\out_zabbix.txt';
print $SO;
} else {
$BAR="/";
$LOG_OUT='/home/zabbix/tmp/out_zabbix.txt';
}
$PARAMETER_FILE='/home/zabbix/etc/parameters.txt';




#########################################################################################################################################################
#########################################################################################################################################################
#########################################################################################################################################################
#########################################################################################################################################################
#########################################################################################################################################################
#########################################################################################################################################################
#use warnings;
#use strict;
#$PARAMETER_FILE="/home/zabbix/etc/parameters.txt";
#$PARAMETER_FILE='C:\zabbix\parameters.txt';




$SO=substr("$^O",0,5);
if ($SO eq "MSWin"){
 $BAR="\\";
 $LOG_OUT='C:\zabbix\out_zabbix.txt';
} else {
  $BAR="/";
  $LOG_OUT='/tmp/out_zabbix.txt';
}


$PARAMETER_FILE='/home/zabbix/etc/parameters.txt';
$ERR_FLAG="0";

$TO_DO="$ARGV[0]";

if (! -f  $PARAMETER_FILE){
  print qq(Arquivo de parametros "$PARAMETER_FILE" não encontrado\n);
  close;
}

sub get_parameter{

  my $FIRST_P="$ARGV[1]";
  my $DB="$ARGV[2]";
  my $PARAM="$ARGV[3]";

  chomp ($FIRST_P);
  chomp ($DB);
  chomp ($PARAM);



  if ($FIRST_P eq "-d"){
    $BYOBJ=0;

    if ($DB eq ""){
      print "Informe o nome do BANCO DE DADOS\n";
      close;
    }
  }
  elsif ($FIRST_P eq "-i"){
    $BYOBJ=1;

    if ($DB eq ""){
      print "Informe o nome da INSTANCIA\n";
      close;
    }
  }
  else {
    print "Opção $FIRST_P desconhecida\nDigite -i ou -d\n\n\n";
    close;
  }

  if (! defined $DB) {
    print "Nome do banco/instancia nao informado\n";
    close;
  }

if    ($PARAM eq "-db"     )  { $F="0" }
elsif ($PARAM eq "-i"      )  { $F="1" }
elsif ($PARAM eq "-al"     )  { $F="2" }
elsif ($PARAM eq "-oh"     )  { $F="3" }
elsif ($PARAM eq "-tnss"   )  { $F="4" }
elsif ($PARAM eq "-syspwd" )  { $F="5" }
elsif ($PARAM eq "-physcr" )  { $F="6" }
elsif ($PARAM eq "-logscr" )  { $F="7" }
elsif ($PARAM eq "-zabus"  )  { $F="8" }
elsif ($PARAM eq "-zabps"  )  { $F="9" }
else  {
    print "Parametro solicitado não é conhecido.
      Utilize:
      -db     <DATABASE NAME>
      -i      <INSTANCE NAME>
      -al     <ALERT.LOG>
      -oh     <ORACLE_HOME>
      -tnss   <TNS STANDBY>
      -syspwd <SENHA STANDBY>
      -physcr <SCRIPT BKP FISICO>
      -logscr <SCRIPT BKP LOGICO>
      -zabus  <USERNAME ZABBIX>
      -zabps  <PASSWORD ZABBIX>\n";
      close;
}

open(my $DATA, '<', $PARAMETER_FILE) or die "Could not open $PARAMETER_FILE $!\n";

while (my $line = <$DATA>) {
  my $VALID = substr $line,0,1;
  my @parameters = split (";" , $line);

  my $VALID_DB="0";

  if ($VALID ne "#" && @parameters[$BYOBJ] eq $DB){
    if ($parameters[1] ne "" && defined $parameters[1]){

      $VALID_PRAMETER="$parameters[9]";

      if ($VALID_PRAMETER eq ""){
        print "Esta faltando parametros para esse banco de dados.\nFavor verificar!\n\n$line\n";
        close;
      } else {
        print "$parameters[$F]";
        my $VALID_DB="1";
        close;
      }
    }
  }
}

if ($VALID_DB == 0) {
  print qq(Não foi encontrada uma entrada para o banco de dados -> "$DB".\n);
  close;
}

close($DATA);

}


sub get_instance_list {

open(my $DATA, '<', $PARAMETER_FILE) or die "Could not open $PARAMETER_FILE $!\n";

while (my $line = <$DATA>) {
  my $VALID = substr $line,0,1;
  my @parameters = split (";" , $line);
  $INSTANCE=@parameters[1];
  chomp $INSTANCE;
  if ($VALID ne "#" && $INSTANCE ne "+ASM" && $INSTANCE ne "+asm" && $INSTANCE ne ""){
        print "$INSTANCE;";
  }

}

close($DATA);

}




sub get_database_list {

open(my $DATA, '<', $PARAMETER_FILE) or die "Could not open $PARAMETER_FILE $!\n";

while (my $line = <$DATA>) {
  my $VALID = substr $line,0,1;
  my @parameters = split (";" , $line);
  $DB=@parameters[0];
  chomp $DB;
  if ($VALID ne "#" && $DB ne "ASM" && $DB ne "asm" && $DB ne ""){
        print "$DB;";
  }

}

close($DATA);
}





@BINH=("bin","sqlplus","rman","tnsping");
sub check_consistency {

  open(my $DATA, '<', $PARAMETER_FILE) or die "Could not open $PARAMETER_FILE $!\n";

  $VALID=0;
  while (my $line = <$DATA>) {
    if ($line ne "") {
      $VALID=1;
    }
  }

  if ($VALID == 0) {
    print "Arquivo de parametro vazio!\n";
    close;
  }

  open(my $DATA, '<', $PARAMETER_FILE) or die "Could not open $PARAMETER_FILE $!\n";

  while (my $line = <$DATA>) {
    my $VALID = substr $line,0,1;
    my @parameters = split (";" , $line);

    if ($VALID ne "#" && $VALID ne "" ){
      if ($parameters[1] ne "" && defined $parameters[1]){

        $DB    =$parameters[0];
        $INST  =$parameters[1];
        $AL    =$parameters[2];
        $OH    =$parameters[3];
        $TS    =$parameters[4];
        $SPW   =$parameters[5];
        $SBF   =$parameters[6];
        $SBL   =$parameters[7];
        $ZABUS =$parameters[8];
        $ZABPS =$parameters[9];

        $PARAM_VALID1=$parameters[10];
        $PARAM_VALID2=$parameters[11];
        $PARAM_VALID3=$parameters[12];
        chomp $PARAM_VALID1;
        chomp $PARAM_VALID2;
        chomp $PARAM_VALID3;

        print "Checando entrada $DB...\n";
        if (($PARAM_VALID1 ne "") || ($PARAM_VALID2 ne "") || ($PARAM_VALID3 ne "")){
          print "    ERRO: Quantidade de parametros incorreto\n";
        } elsif ($ZABPS eq ""){
          print "    ERRO: Esta faltando parametros para esse banco de dados.\n";
          $ERR_FLAG=1;
        } else {
=pod
  Checa o status da instancia + alert.log + ORACLE_HOME
=cut
          if ("$INST" ne ""){

            if (! -f  $AL){
              print qq(    ERRO: alert log inválido ou inacessível por falta de privilégios\n);
              $ERR_FLAG=1;
            }

            if ( -d $OH) {
              $SQLPLUS="$OH$BAR$BINH[0]$BAR$BINH[1]";
              $RMAN="$OH$BAR$BINH[0]$BAR$BINH[2]";
              if ((! -f "$SQLPLUS") || (! -f "$RMAN")) {
                  print "    ERRO: programas importantes nao encontrados no ORACLE_HOME \n $SQLPLUS \n $RMAN \n";
                  $ERR_FLAG=1;
              }
            } else {
              print "    ERRO: ORACLE_HOME nao aponta para um diretorio valido ou acessivel\n";
              $ERR_FLAG=1;
            }
          } else {
            print "    ERRO: nome da instancia nao especificado\n";
            $ERR_FLAG=1;
          }
=pop
 Valida o script do backup fisico
=cut

          if ($SBF ne ""){
            if ( ! -d $SBF && ! -f $SBF){
              print "    ERRO: script/diretorio do backup fisico especificado e invalido ou inacessivel\n";
              $ERR_FLAG=1;
            }
          } else {
            print "    AVISO: script de backup físico não especificado\n";
          }


=pop
 Valida o script do backup logico
=cut

          if ($SBL ne "") {
            if (! -f $SBL ){
              print "    ERRO: script de backup fisico especificado invalido\n";
              $ERR_FLAG=1;
            }
          } else {
            print "    AVISO: script de backup logico nao especificado\n";
          }

=pop
 Usuario e senha do usuario Zabbix no banco de dados.
=cut

          if ($ZABUS eq ""){
            print "    ERRO: informe o nome do usuario do ZABBIX <Database>\n";
            $ERR_FLAG=1;
          }

          if ($ZABPS eq ""){
            print "    ERRO: informe a senha do usuario do Zabbix <Database>\n";
            $ERR_FLAG=1;
          }
      }

=pop
 Fim das validacoes dos parametros
=cut

      if ($ERR_FLAG == 0){
        print "     [OK]\n\n";
      } else {
        $ERR_FLAG=2;
        print "\n";
      }

    }

  }

}

if ($ERR_FLAG == 2){
  print "Erros de consistencia encontrados no arquivo\n\n";
} else {
  print "Arquivo passou no teste de consistência.\n\n";
}

close($DATA);

}



if    ($TO_DO eq "getpar")       { get_parameter; }
elsif ($TO_DO eq "instancelist") { get_instance_list; }
elsif ($TO_DO eq "databaselist") { get_database_list; }
elsif ($TO_DO eq "check")        { check_consistency; }
elsif ($TO_DO eq "asmlist")      { get_asm_list; }
else  {
print "
Informe $0 [OPCAO]
Valores para [OPCAO]

   getpar,         . Trazer dados de parametros;
   instancelist,   . Lista as instancias no parameter.txt;
   databaselist,   . Lista os databases no parameter.txt;
   check,          . Valida os parametros informados no parameter.txt.\n\n";
   close;
}





