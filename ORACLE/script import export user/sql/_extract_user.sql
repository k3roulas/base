-- Comments and Script Documentation
-- Script Name   : extract_schema_ddl.sql
-- Purpose       : Extract schema ddl
-- Requirements  : User calling script must be logged in with DBA privs
--                 The directory the script is being called FROM must be writeable by Oracle
-- Parameters    : &1 - schema_owner - Username of the schema owner
-- Author        : Daniel W. Fink
-- Created Date  : July 12, 2004
-- Updates      
--               : 07/12/2004 dwf Original version
-- Comments      : This can be called standalone or as part of extract_schema_menu.sql 
--                 Compatible with Oracle9i/10g.
--                 Numerous workarounds are coded for bugs


DEFINE schema_owner = &1
-- WHENEVER SQLERROR EXIT FAILURE

SET LINESIZE 132 PAGESIZE 0 FEEDBACK off VERIFY off TRIMSPOOL on LONG 1000000
COLUMN ddl_string FORMAT A100 WORD_WRAP
COLUMN row_order FORMAT 999 NOPRINT

EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
EXECUTE DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'REF_CONSTRAINTS',false);

COLUMN rundate FORMAT A8 NEW_VALUE ddl_date NOPRINT
COLUMN dbname FORMAT A10 NEW_VALUE db_name NOPRINT
COLUMN spoolname FORMAT A50 NEW_VALUE spool_name NOPRINT
COLUMN maxtextlength FORMAT 9999 NEW_VALUE max_text_length NOPRINT
COLUMN schemaid NEW_VALUE schema_id NOPRINT

SELECT u.user# schemaid
FROM sys.user$ u
WHERE u.name = UPPER('&&schema_owner')
/

SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') rundate
FROM dual
/

SELECT UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')) dbname
FROM dual
/

SELECT 'schema_'||'&&db_name'||'_'||'&&schema_owner'||'_'||'&&ddl_date'||'_ddl.log' spoolname
FROM dual
/

SELECT MAX(LENGTH(s.source)) maxtextlength
FROM sys.obj$ o,
     sys.source$ s
WHERE o.owner# = &&schema_id
  AND o.obj# = s.obj#
/

SET LINESIZE &&max_text_length

-- SPOOL schema_&&db_name\_&&schema_owner\_&&ddl_date\_ddl.sql
SPOOL _schema_ddl.sql

PROMPT WHENEVER SQLERROR EXIT FAILURE
PROMPT WHENEVER OSERROR EXIT FAILURE
PROMPT SPOOL &&spool_name
PROMPT
PROMPT

SELECT 0 row_order, '-- Object Count' ddl_string
FROM dual
UNION 
SELECT 1 row_order, '-- '||DECODE(o.type#, 
                                  1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER', 4, 'VIEW', 5, 'SYNONYM', 
                                  6, 'SEQUENCE', 7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE', 
                                 10, 'NON-EXISTENT', 11, 'PACKAGE BODY', 12, 'TRIGGER', 13, 'TYPE', 
                                 14, 'TYPE BODY', 28, 'JAVA SOURCE', 29, 'JAVA CLASS', 42, 'MATERIALIZED VIEW', 
                                 43, 'DIMENSION', 56, 'JAVA DATA', 'UNDEFINED')||' -- '||COUNT(1)
FROM sys.obj$ o
WHERE o.owner# = &&schema_id
GROUP BY 1, o.type#
UNION
SELECT 2 row_order, CHR(10)||CHR(10)
FROM dual
/


PROMPT
PROMPT -- User Creation
PROMPT

SELECT TO_CHAR(DBMS_METADATA.GET_DDL('USER', '&&schema_owner')) ddl_string
FROM dual
/

PROMPT
PROMPT -- User Tablespace Quotas
PROMPT
-- This is failing with an error message, causing the script to terminate. No workaround yet.

PROMPT
PROMPT -- User Role
PROMPT

SELECT /*+ ordered */ 'GRANT "'||u.name||'" TO "'||upper('&&schema_owner')||'"'||
       CASE WHEN min(sa.option$) = 1 THEN ' WITH ADMIN OPTION;' ELSE ';' END ddl_string
FROM sys.sysauth$ sa,
     sys.user$ u
WHERE sa.grantee# = &&schema_id
  AND u.user# = sa.privilege#
  AND sa.grantee# != 1
GROUP BY u.name
/

PROMPT
PROMPT -- User System Privileges
PROMPT
-- If the dbms_metadata call for system grants does not find any for the schema owner
-- it fails with an error message, causing the script to terminate. The SELECT is used as a 
-- workaround. A TAR has been filed w/Oracle (response 'expected behaviour' - RFE filed)

SELECT CASE
           WHEN COUNT(1) != 0 THEN DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', '&&schema_owner')
           ELSE NULL
       END ddl_string
FROM sys.sysauth$ sa
WHERE sa.grantee# = &&schema_id
/

PROMPT
PROMPT -- User Object Privileges
PROMPT
-- If the dbms_metadata call for object grants does not find any for the schema owner
-- it fails with an error message, causing the script to terminate. The SELECT is used as a 
-- workaround. A TAR has been filed w/Oracle (response 'expected behaviour' - RFE filed)

SELECT CASE
           WHEN COUNT(1) != 0 THEN DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', '&&schema_owner')
           ELSE NULL
       END ddl_string
FROM sys.objauth$ oa
WHERE oa.grantee# = &&schema_id
/


PROMPT SET LINESIZE 132 PAGESIZE 45 FEEDBACK OFF
PROMPT COLUMN line FORMAT 9999 
PROMPT COLUMN text FORMAT A40 WORD_WRAP
PROMPT
PROMPT -- Checking for errors
PROMPT
PROMPT SELECT name, type, line, text
PROMPT FROM dba_errors
PROMPT WHERE owner = '&&schema_owner'
PROMPT /

PROMPT SPOOL OFF

SPOOL OFF

UNDEFINE schema_owner

-- EXIT
