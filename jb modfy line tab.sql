SQL> desc dba_tab_modifications
 Name                                Null?    Type
 ----------------------------------- -------- ------------------------
 TABLE_OWNER                                  VARCHAR2(30)
 TABLE_NAME                                   VARCHAR2(30)
 PARTITION_NAME                               VARCHAR2(30)
 SUBPARTITION_NAME                            VARCHAR2(30)
 INSERTS                                      NUMBER
 UPDATES                                      NUMBER
 DELETES                                      NUMBER
 TIMESTAMP                                    DATE
 TRUNCATED                                    VARCHAR2(3)
 DROP_SEGMENTS                                NUMBER
