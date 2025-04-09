-- desc user_tables;
-- select TABLE_NAME from user_tables;
-- select * from EMPLOYEES;
--  describe EMPLOYEES;
-- DESCRIBE JOBS;
-- select * from EMPLOYEES;
-- set SERVEROUTPUT on;
/*
 A)-Ecrire un programme PLSQL qui permet d’afficher les informations suivantes sur les
employés et sous cette forme : ajuster exactement les rubriques 
*/
DECLARE
CURSOR c_emp is SELECT E.FIRST_NAME, J.JOB_TITLE,J.MAX_SALARY
FROM EMPLOYEES E
JOIN JOBS J ON E.JOB_ID = J.JOB_ID;
v_emp_rec c_emp %rowtype;

BEGIN
  OPEN c_emp;
  LOOP
   FETCH c_emp into v_emp_rec;
   exit when c_emp %notfound;

   DBMS_OUTPUT.put_line(v_emp_rec.first_name|| ' est un ' || v_emp_rec.JOB_TITLE|| ' il touch u salaire  de ******' ||v_emp_rec.MAX_SALARY);
   END LOOP;
   CLOSE c_emp;

  END;
  /



