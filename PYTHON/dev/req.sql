set head off;
set feed off;
set trimspool on;
set linesize 1000; 
set pagesize 0;
set echo off;
set termout off;
spool data/region.csv;
select FIELD1
|| ';' || FIELD2
|| ';' || FIELD3
from TABLE;
spool off;
exit;
