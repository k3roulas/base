begin

  for i in (select sid,serial# from v$session where username in ('NAME'))

  loop

    execute immediate 'alter system kill session '||''''||i.sid||','||i.serial#||''' immediate';

  end loop;

end;

/
drop user NAME cascade;
