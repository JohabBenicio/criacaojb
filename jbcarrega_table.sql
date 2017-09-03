
create table teste (id number,cliente varchar2(90),endereco varchar2(90),cidade varchar2(90),estado varchar2(90));
create table teste1 (id number,cliente varchar2(90),endereco varchar2(90),cidade varchar2(90),estado varchar2(90));
create table teste2 (id number,cliente varchar2(90),endereco varchar2(90),cidade varchar2(90),estado varchar2(90));


set serveroutput on

declare

	v1 varchar2(40):=&qtd_insert;
	vcont varchar2(40):=0;

begin

for x in 1..v1 loop

	insert into teste values (x,'Cliente'||x,'Endereco'||x,'Cidade'||x,'Estado'||x);
	insert into teste1 values (x,'Cliente'||x,'Endereco'||x,'Cidade'||x,'Estado'||x);
	insert into teste2 values (x,'Cliente'||x,'Endereco'||x,'Cidade'||x,'Estado'||x);
	vcont:=vcont+1;


	if vcont=1000 then
		commit;
		vcont:=0;
	end if;


end loop;

commit;

end;
/
