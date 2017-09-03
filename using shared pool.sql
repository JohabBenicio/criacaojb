select * from ( select name, bytes/1024/1024/1024 from v$sgastat where pool ='shared pool' order by 2 desc ) where rownum <11;


alter system flush shared_pool;


