/* ------------------------------------------------------------------- */
/*                   maximo Database Schema                               */
/* ------------------------------------------------------------------- */
/* Create the Data Tablesapce */
CREATE TABLESPACE MAXDATA LOGGING DATAFILE SIZE 400M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
ALTER TABLESPACE MAXDATA AUTOEXTEND ON MAXSIZE UNLIMITED;

CREATE TABLESPACE MAXINDEX LOGGING DATAFILE SIZE 400M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
ALTER TABLESPACE MAXINDEX AUTOEXTEND ON MAXSIZE UNLIMITED;



/* Create the schema User */
CREATE USER maximo PROFILE "DEFAULT" IDENTIFIED BY maximo DEFAULT TABLESPACE MAXDATA TEMPORARY TABLESPACE temp ACCOUNT UNLOCK;
ALTER USER maximo QUOTA UNLIMITED ON maxdata;
ALTER USER maximo QUOTA UNLIMITED ON maxindex;

/* Set the schema user permissions */
 grant connect to maximo;
 grant resource to maximo;
 grant create job to maximo;
 grant create trigger to maximo;
 grant create session to maximo;
 grant create sequence to maximo;
 grant create synonym to maximo;
 grant create table to maximo;
 grant create view to maximo;
 grant create procedure to maximo;
 grant alter session to maximo;
 grant execute on ctxsys.ctx_ddl to maximo;
 grant execute on DBMS_XA to maximo;
 grant select_catalog_role to maximo;


EXIT SQL.SQLCODE
