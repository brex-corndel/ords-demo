--
-- Oracle scripts for the preparation of the API on Oracle
-- Use Sql Developer and Advanc and Rest Client

-- DROP USER APIUSER CASCADE;
CREATE USER APIUSER IDENTIFIED BY l3tm3in
  DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
  
GRANT CREATE SESSION, CREATE TABLE, CREATE TYPE, CREATE PROCEDURE TO APIUSER;

--
-- Setup the test environment
--

ALTER SESSION SET CURRENT_SCHEMA=APIUSER;

CREATE TABLE EMP (
  EMPNO NUMBER(4,0), 
  ENAME VARCHAR2(10 BYTE), 
  JOB VARCHAR2(9 BYTE), 
  MGR NUMBER(4,0), 
  HIREDATE DATE, 
  SAL NUMBER(7,2), 
  COMM NUMBER(7,2), 
  DEPTNO NUMBER(2,0), 
  CONSTRAINT PK_EMP PRIMARY KEY (EMPNO)
  );
  
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7369,'SMITH','CLERK',7902,to_date('17-DEC-80','DD-MON-RR'),800,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7499,'ALLEN','SALESMAN',7698,to_date('20-FEB-81','DD-MON-RR'),1600,300,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7521,'WARD','SALESMAN',7698,to_date('22-FEB-81','DD-MON-RR'),1250,500,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7566,'JONES','MANAGER',7839,to_date('02-APR-81','DD-MON-RR'),2975,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7654,'MARTIN','SALESMAN',7698,to_date('28-SEP-81','DD-MON-RR'),1250,1400,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7698,'BLAKE','MANAGER',7839,to_date('01-MAY-81','DD-MON-RR'),2850,null,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7782,'CLARK','MANAGER',7839,to_date('09-JUN-81','DD-MON-RR'),2450,null,10);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7788,'SCOTT','ANALYST',7566,to_date('19-APR-87','DD-MON-RR'),3000,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7839,'KING','PRESIDENT',null,to_date('17-NOV-81','DD-MON-RR'),5000,null,10);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7844,'TURNER','SALESMAN',7698,to_date('08-SEP-81','DD-MON-RR'),1500,0,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7876,'ADAMS','CLERK',7788,to_date('23-MAY-87','DD-MON-RR'),1100,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7900,'JAMES','CLERK',7698,to_date('03-DEC-81','DD-MON-RR'),950,null,30);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7902,'FORD','ANALYST',7566,to_date('03-DEC-81','DD-MON-RR'),3000,null,20);
insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7934,'MILLER','CLERK',7782,to_date('23-JAN-82','DD-MON-RR'),1300,null,10);
commit;

--
-- Enable REST Data Services
--

BEGIN
  ORDS.enable_schema(
    p_enabled             => TRUE,
    p_schema              => 'APIUSER',
    p_url_mapping_type    => 'BASE_PATH',
    p_url_mapping_pattern => 'hr',
    p_auto_rest_auth      => FALSE
  );
    
  COMMIT;
END;
/

--
--  ORDS available at :- §http://localhost:8181/ords/hr/
--

--
-- Add a GET RESTful Service
-- http://localhost:8181/ords/hr/rest-v1/employees/
--

BEGIN
  ORDS.define_service(
    p_module_name    => 'rest-v1',
    p_base_path      => 'rest-v1/',
    p_pattern        => 'employees/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT * FROM emp',
    p_items_per_page => 0);

  COMMIT;
END;
/

SELECT id, name, uri_prefix FROM user_ords_modules ORDER BY name;
SELECT id, module_id, uri_template FROM user_ords_templates ORDER BY module_id;
SELECT id, template_id, source_type, method, source FROM user_ords_handlers ORDER BY id;

-- Extend to allow multiple values
-- http://localhost:8181/ords/hr/rest-v3c/employees/7876,7934,7782
--

CREATE OR REPLACE TYPE t_in_list_tab AS TABLE OF VARCHAR2 (4000);
/

CREATE OR REPLACE FUNCTION in_list (p_in_list  IN  VARCHAR2)
  RETURN t_in_list_tab PIPELINED
AS
  l_text  VARCHAR2(32767) := p_in_list || ',';
  l_idx   NUMBER;
BEGIN
  LOOP
    l_idx := INSTR(l_text, ',');
    EXIT WHEN NVL(l_idx, 0) = 0;
    PIPE ROW (TRIM(SUBSTR(l_text, 1, l_idx - 1)));
    l_text := SUBSTR(l_text, l_idx + 1);
  END LOOP;

  RETURN;
END;
/

BEGIN
  ORDS.define_module(
    p_module_name    => 'rest-v3c',
    p_base_path      => 'rest-v3c/',
    p_items_per_page => 0);
  
  ORDS.define_template(
   p_module_name    => 'rest-v3c',
   p_pattern        => 'employees/:empno');

  ORDS.define_handler(
    p_module_name    => 'rest-v3c',
    p_pattern        => 'employees/:empno',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT *
                         FROM   emp
                         WHERE  empno IN (SELECT * FROM TABLE(in_list(:empno)))
                         ORDER BY ename',
    p_items_per_page => 0);
    
  COMMIT;
END;
/

-- Add to a Proceduew
-- http://localhost:8181/ords/hr/rest-v4/employees/7499
--

CREATE OR REPLACE PROCEDURE get_emp_json (p_empno IN emp.empno%TYPE DEFAULT NULL) AS
  l_cursor SYS_REFCURSOR;
BEGIN
  
  OPEN l_cursor FOR
    SELECT e.empno AS "empno",
           e.ename AS "employee_name",
           e.job AS "job",
           e.mgr AS "mgr",
           TO_CHAR(e.hiredate,'YYYY-MM-DD') AS "hiredate",
           e.sal AS "sal",
           e.comm  AS "comm",
           e.deptno AS "deptno"
    FROM   emp e
    WHERE  e.empno = DECODE(p_empno, NULL, e.empno, p_empno);

  APEX_JSON.open_object;
  APEX_JSON.write('employees', l_cursor);
  APEX_JSON.close_object;
END;

BEGIN
  ORDS.define_module(
    p_module_name    => 'rest-v4',
    p_base_path      => 'rest-v4/',
    p_items_per_page => 0);
  
  ORDS.define_template(
   p_module_name    => 'rest-v4',
   p_pattern        => 'employees/');

  ORDS.define_handler(
    p_module_name    => 'rest-v4',
    p_pattern        => 'employees/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN get_emp_json; END;',
    p_items_per_page => 0);
    
  ORDS.define_template(
   p_module_name    => 'rest-v4',
   p_pattern        => 'employees/:empno');

  ORDS.define_handler(
    p_module_name    => 'rest-v4',
    p_pattern        => 'employees/:empno',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN get_emp_json(:empno); END;',
    p_items_per_page => 0);
    
  COMMIT;
END;
/

--
-- Extend to PUT RESTful Operation
-- Find it with http://localhost:8181/ords/hr/rest-v4/employees/9999

CREATE OR REPLACE PROCEDURE create_employee (
  p_empno     IN  emp.empno%TYPE,
  p_ename     IN  emp.ename%TYPE,
  p_job       IN  emp.job%TYPE,
  p_mgr       IN  emp.mgr%TYPE,
  p_hiredate  IN  VARCHAR2,
  p_sal       IN  emp.sal%TYPE,
  p_comm      IN  emp.comm%TYPE,
  p_deptno    IN  emp.deptno%TYPE
)
AS
BEGIN
  INSERT INTO emp (empno, ename, job, mgr, hiredate, sal, comm, deptno)
  VALUES (p_empno, p_ename, p_job, p_mgr, TO_DATE(p_hiredate, 'YYYY-MM-DD'), p_sal, p_comm, p_deptno);
EXCEPTION
  WHEN OTHERS THEN
    HTP.print(SQLERRM);
END;
/

BEGIN
  ORDS.define_module(
    p_module_name    => 'rest-v6',
    p_base_path      => 'rest-v6/',
    p_items_per_page => 0);
  
  ORDS.define_template(
   p_module_name    => 'rest-v6',
   p_pattern        => 'employees/');

  ORDS.define_handler(
    p_module_name    => 'rest-v6',
    p_pattern        => 'employees/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           create_employee(p_empno    => :empno,
                                           p_ename    => :ename,
                                           p_job      => :job,
                                           p_mgr      => :mgr,
                                           p_hiredate => :hiredate,
                                           p_sal      => :sal,
                                           p_comm     => :comm,
                                           p_deptno   => :deptno);
                         END;',
    p_items_per_page => 0);

  COMMIT;
END;
/

curl -i -X POST --data-binary @insert-payload.json -H "Content-Type: application/json" http://localhost:8181/ords/hr/rest-v6/employees/

{ "empno": 9999, "ename": "BREX", "job": "DEVOPS", "mgr": 7782, "hiredate": "2022-01-01", "sal": 1000, "comm": null, "deptno": 10 }

--
-- Complete Example
--

BEGIN
  ORDS.define_module(
    p_module_name    => 'rest-v9',
    p_base_path      => 'rest-v9/',
    p_items_per_page => 0);
  
  ORDS.define_template(
   p_module_name    => 'rest-v9',
   p_pattern        => 'employees/');

  -- READ : All records.
  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT * FROM emp',
    p_items_per_page => 0);

  -- INSERT
  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/',
    p_method         => 'POST',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           create_employee (p_empno    => :empno,
                                            p_ename    => :ename,
                                            p_job      => :job,
                                            p_mgr      => :mgr,
                                            p_hiredate => :hiredate,
                                            p_sal      => :sal,
                                            p_comm     => :comm,
                                            p_deptno   => :deptno);
                         END;',
    p_items_per_page => 0);

  -- UPDATE
  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/',
    p_method         => 'PUT',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           amend_employee(p_empno    => :empno,
                                          p_ename    => :ename,
                                          p_job      => :job,
                                          p_mgr      => :mgr,
                                          p_hiredate => :hiredate,
                                          p_sal      => :sal,
                                          p_comm     => :comm,
                                          p_deptno   => :deptno);
                         END;',
    p_items_per_page => 0);

  -- DELETE
  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/',
    p_method         => 'DELETE',
    p_source_type    => ORDS.source_type_plsql,
    p_source         => 'BEGIN
                           remove_employee(p_empno => :empno);
                         END;',
    p_items_per_page => 0);

  -- READ : One Record
  ORDS.define_template(
   p_module_name    => 'rest-v9',
   p_pattern        => 'employees/:empno');

  ORDS.define_handler(
    p_module_name    => 'rest-v9',
    p_pattern        => 'employees/:empno',
    p_method         => 'GET',
    p_source_type    => ORDS.source_type_collection_feed,
    p_source         => 'SELECT * FROM emp WHERE empno = :empno',
    p_items_per_page => 0);

  COMMIT;
END;
/

--
-- Validate below with http://localhost:8181/ords/hr/rest-v4/employees/9999
--

curl -i -X PUT --data-binary @update-payload.json -H "Content-Type: application/json" http://localhost:8181/ords/hr/rest-v9/employees/

curl -i -X DELETE --data-binary @delete-payload.json -H "Content-Type: application/json" http://localhost:8181/ords/hr/rest-v9/employees/

curl -i -X POST --data-binary @insert-payload.json -H "Content-Type: application/json" http://localhost:8181/ords/hr/rest-v6/employees/
