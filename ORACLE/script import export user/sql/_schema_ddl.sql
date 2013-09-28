WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
SPOOL schema_BADOA_badoajournal_20100119_ddl.log


-- Object Count


-- User Creation

SELECT TO_CHAR(DBMS_METADATA.GET_DDL('USER', 'badoajournal')) ddl_string
               *
ERROR at line 1:
ORA-31603: object "badoajournal" of type USER not found in schema "SYSTEM"
ORA-06512: at "SYS.DBMS_SYS_ERROR", line 105
ORA-06512: at "SYS.DBMS_METADATA", line 628
ORA-06512: at "SYS.DBMS_METADATA", line 1221
ORA-06512: at line 1



-- User Tablespace Quotas


-- User Role


-- User System Privileges

ERROR:
ORA-31608: specified object of type SYSTEM_GRANT not found
ORA-06512: at "SYS.DBMS_SYS_ERROR", line 86
ORA-06512: at "SYS.DBMS_METADATA", line 631
ORA-06512: at "SYS.DBMS_METADATA", line 1339
ORA-06512: at line 1



-- User Object Privileges


SET LINESIZE 132 PAGESIZE 45 FEEDBACK OFF
COLUMN line FORMAT 9999
COLUMN text FORMAT A40 WORD_WRAP

-- Checking for errors

SELECT name, type, line, text
FROM dba_errors
WHERE owner = 'badoajournal'
/
SPOOL OFF
