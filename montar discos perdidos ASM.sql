*.asm_diskgroups='DGHOMO'
#+asm.asm_diskgroups='dgdata','DGHOMO'#Manual Mount
#*.asm_diskstring='ORCL:*'
*.asm_diskstring='/dev/mapper/asm*'
*.asm_power_limit=2
*.audit_file_dest='/u01/app/oracle/admin/+asm/adump'
*.background_core_dump='full'
*.background_dump_dest='/u01/app/oracle/admin/+asm/bdump'
*.compatible='10.2.0.4'
*.core_dump_dest='/u01/app/oracle/admin/+asm/cdump'
*.db_cache_size=32M
*.instance_name='+asm'
*.instance_type='asm'
*.large_pool_size=16M
*.processes=200
*.sessions=100
*.shared_pool_size=96M
*.user_dump_dest='/u01/app/oracle/admin/+asm/udump'
