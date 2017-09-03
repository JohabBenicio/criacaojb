MEMORY_TARGET = SGA_TARGET + GREATEST(PGA_AGGREGATE_TARGET, "maximum PGA allocated")


The following queries show you how to display the relevant information and how to combine it in a single statement to calculate the required value.

-- Individual values.
COLUMN name FORMAT A30
COLUMN value FORMAT A16

SELECT name, value
FROM   v$parameter
WHERE  name IN ('pga_aggregate_target', 'sga_target')
UNION
SELECT 'maximum PGA allocated' AS name, TO_CHAR(value) AS value
FROM   v$pgastat
WHERE  name = 'maximum PGA allocated';

-- Calculate MEMORY_TARGET


col memory_target for 9999999999999999999
SELECT sga.value + GREATEST(pga.value, max_pga.value) AS memory_target
FROM (SELECT TO_NUMBER(value) AS value FROM v$parameter WHERE name = 'sga_target') sga,
     (SELECT TO_NUMBER(value) AS value FROM v$parameter WHERE name = 'pga_aggregate_target') pga,
     (SELECT value FROM v$pgastat WHERE name = 'maximum PGA allocated') max_pga;

