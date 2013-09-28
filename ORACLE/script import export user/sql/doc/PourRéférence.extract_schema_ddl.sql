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
SPOOL schema_ddl.sql

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
PROMPT -- Profile Creation
PROMPT

SELECT DBMS_METADATA.GET_DDL('PROFILE', pr.name) ddl_string
FROM (SELECT DISTINCT pi.name 
      FROM sys.profname$ pi
      WHERE pi.name != 'DEFAULT') pr
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

/*
SELECT CASE
           WHEN COUNT(1) != 0 THEN DBMS_METADATA.GET_GRANTED_DDL('TABLESPACE_QUOTA', '&&schema_owner')
           ELSE NULL
       END ddl_string
FROM sys.ts$ ts,
     sys.tsq$ tq
WHERE tq.user# = &&schema_id
  AND ts.ts# = tq.ts# 
/
*/

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


PROMPT
PROMPT -- Schema Sequences
PROMPT

SELECT TO_CHAR(DBMS_METADATA.GET_DDL('SEQUENCE', o.name,'&&schema_owner')) ddl_string
FROM sys.seq$ s,
     sys.obj$ o
WHERE o.owner# = &&schema_id
  AND o.obj# = s.obj#
/


PROMPT
PROMPT -- Schema Database Links
PROMPT

SELECT TO_CHAR(DBMS_METADATA.GET_DDL('DB_LINK', l.name,'&&schema_owner')) ddl_string
FROM sys.link$ l
WHERE l.owner# = &&schema_id
/


PROMPT
PROMPT -- Schema Directories
PROMPT

SELECT DBMS_METADATA.GET_DDL('DIRECTORY', o.name, '&&schema_owner') ddl_string
FROM sys.obj$ o,
     sys.dir$ d
WHERE o.owner# = &&schema_id
  AND o.obj# = d.obj#
/

PROMPT
PROMPT -- Schema Tables
PROMPT

/* Add the BITAND(o.flags, 128) to exclude tables in the recyclebin */

SELECT     TO_CHAR(DBMS_METADATA.GET_DDL('TABLE', o.name,'&&schema_owner')) ddl_string
FROM       sys.obj$ o,
           sys.tab$ t
WHERE      o.owner# = &&schema_id
  AND      o.obj# = t.obj#
  AND      BITAND(o.flags, 128) = 0
/

PROMPT
PROMPT -- Schema Table RI Constraints
PROMPT

SELECT DBMS_METADATA.GET_DDL('REF_CONSTRAINT', oc.name, '&&schema_owner')||'/' ddl_string
FROM sys.con$ oc,
     sys.obj$ o,
     sys.cdef$ c
WHERE oc.owner# = &&schema_id
  AND oc.con# = c.con#
  AND c.obj# = o.obj#
  AND c.type# = 4
/

PROMPT
PROMPT -- Schema Indexes
PROMPT
--- This is used to exclude primary key and unique key indexes that have already been defined
--- as part of the table generation statement.

SELECT TO_CHAR(DBMS_METADATA.GET_DDL('INDEX', o.name,'&&schema_owner')) ddl_string
FROM sys.ind$ i,
     sys.obj$ o
WHERE o.owner# = &&schema_id
  AND o.obj# = i.obj#
  AND bitand(i.property,1) = 1
  AND i.type# != 8
/

PROMPT
PROMPT -- Schema Views
PROMPT
-- View extraction is not functioning properly in 9.2. Breaks occur in middle of words (column_names, clauses, etc). 
-- Bug has been accepted with Oracle. No response of when/if backport to 9.2.0.5 will be available

-- SELECT REPLACE(TO_CHAR(DBMS_METADATA.GET_DDL('VIEW', v.view_name,'&&schema_owner')), '","','", "') ddl_string
-- FROM dba_views v
-- WHERE v.owner = '&&schema_owner'
-- /

-- Here is a workaround version
COLUMN viewname NOPRINT

CREATE GLOBAL TEMPORARY TABLE parsed_view_text 
  (view_name VARCHAR2(30), 
   text_id NUMBER, 
   view_text VARCHAR2(4000)
  ) ON COMMIT PRESERVE ROWS;

DECLARE
    num_iter NUMBER := 0;
    whole_clob CLOB;
    parsed_string VARCHAR2(32767);
    start_pos NUMBER := 1;
    num_chars NUMBER := 3000;

    CURSOR view_text_cur IS 
       SELECT o.name view_name, v.text text, v.textlength text_length, v.cols view_columns
       FROM sys.obj$ o,
            sys.view$ v
       WHERE o.obj# = v.obj#
         AND o.owner# = &&schema_id;

    view_text_rec view_text_cur%ROWTYPE;

BEGIN

   FOR view_text_rec IN view_text_cur
   LOOP
      whole_clob := TO_CLOB(view_text_rec.text);
 
      DBMS_OUTPUT.PUT_LINE('View Name: '||view_text_rec.view_name||' Text Length :'|| view_text_rec.text_length);
      LOOP
         IF (view_text_rec.text_length - start_pos) < 3000
         THEN
              parsed_string := SUBSTR(whole_clob, start_pos);
              INSERT INTO parsed_view_text VALUES (view_text_rec.view_name, (view_text_rec.view_columns + num_iter), parsed_string||CHR(10)||'/');
            EXIT;
         END if;
         parsed_string := SUBSTR(whole_clob, start_pos, 3000);
         num_chars := GREATEST(INSTR(parsed_string, ', ', -1, 1), INSTR(parsed_string, ',"', -1, 1),
                               (INSTR(parsed_string, '),', -1, 1)+1), INSTR(parsed_string, ')', -1, 1));
         parsed_string := SUBSTR(whole_clob, start_pos, num_chars);
         INSERT INTO parsed_view_text VALUES (view_text_rec.view_name, (view_text_rec.view_columns + num_iter), parsed_string);
         start_pos := start_pos + num_chars;
         num_iter := num_iter + 1;
      END LOOP;
      COMMIT;
      start_pos := 1;
      num_chars := 3000;
      num_iter := 1;
   END LOOP;
END;
/

SELECT 0 row_order,
       o.name viewname, 
       'CREATE OR REPLACE FORCE VIEW "'||'&&schema_owner'||'"."'||o.name||'"' ddl_string
FROM sys.obj$ o,
     sys.view$ v
WHERE o.obj# = v.obj#
  AND o.owner# = &&schema_iD
UNION
SELECT decode(c.col#, 0, to_number(null), c.col#) row_order, 
       o.name viewname,
       CASE WHEN decode(c.col#, 0, to_number(null), c.col#) = 1 THEN '("'||c.name||'",'
            WHEN decode(c.col#, 0, to_number(null), c.col#) = v.cols THEN ' "'||c.name||'") AS '
            ELSE ' "'||c.name||'",'
       END ddl_string
FROM sys.col$ c,
     sys.obj$ o,
     sys.view$ v
WHERE o.obj# = c.obj#
  AND o.owner# = &&schema_id
  AND o.obj# = v.obj#
UNION
SELECT pv.text_id row_order,
       pv.view_name viewname,
       REPLACE(TO_CHAR(pv.view_text), '","', '", "') ddl_string
FROM parsed_view_text pv 
ORDER BY viewname, row_order
/

TRUNCATE TABLE parsed_view_text;
DROP TABLE parsed_view_text;

SET LINESIZE 4005
COLUMN ddl_string FORMAT A4000

PROMPT
PROMPT -- Schema Functions
PROMPT

SELECT DBMS_METADATA.GET_DDL('FUNCTION', o.name,'&&schema_owner') ddl_string
FROM sys.obj$ o
WHERE o.owner# = &&schema_id
  AND o.type# = 8
/

PROMPT
PROMPT -- Schema Packages (specs and body)
PROMPT

SELECT DBMS_METADATA.GET_DDL('PACKAGE', o.name,'&&schema_owner') ddl_string
FROM sys.obj$ o
WHERE o.owner# = &&schema_id
  AND o.type# = 9
/

PROMPT
PROMPT -- Schema Procedures
PROMPT

SELECT DBMS_METADATA.GET_DDL('PROCEDURE', o.name,'&&schema_owner') ddl_string
FROM sys.obj$ o
WHERE o.owner# = &&schema_id
  AND o.type# = 7
/

COLUMN ddl_string FORMAT A125
SET LINESIZE 132

PROMPT
PROMPT -- Schema Synonyms
PROMPT

SELECT 'CREATE SYNONYM "&&schema_owner"."'||o.name||'" FOR "'||s.owner||'"."'||s.name||NVL2(s.node, '@'||s.node||'";', '";') ddl_string
FROM sys.syn$ s,
     sys.obj$ o
WHERE o.owner# = &&schema_id
  AND o.obj# = s.obj#
  AND o.type# = 5
/

PROMPT
PROMPT -- End of ddl
PROMPT 

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
