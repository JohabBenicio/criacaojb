-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- Descrição       : Preparar valores para o parametro NLS_LANG.
-- Data de criação : 21/07/2014
-- -----------------------------------------------------------------------------------

col NLS_LANG for a60

select 'export NLS_LANG=' || a.NLS_LANGUAGE || '_' || b.NLS_TERRITORY || '.' || c.NLS_CHARACTERSET NLS_LANG from
(SELECT VALUE$ NLS_LANGUAGE FROM SYS.PROPS$ WHERE NAME = 'NLS_LANGUAGE') a,
(SELECT VALUE$ NLS_TERRITORY FROM SYS.PROPS$ WHERE NAME = 'NLS_TERRITORY') b,
(SELECT VALUE$ NLS_CHARACTERSET FROM SYS.PROPS$ WHERE NAME = 'NLS_CHARACTERSET') c;



