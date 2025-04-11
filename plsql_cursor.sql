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


--  ## autre method  d’afficher les informations suivantes sur les
-- employés et sous cette forme 
DECLARE
CURSOR c_emp is SELECT E.FIRST_NAME, J.JOB_TITLE,J.MAX_SALARY
FROM EMPLOYEES E
JOIN JOBS J ON E.JOB_ID = J.JOB_ID;


BEGIN

  FOR v_emp_rec in c_emp loop
   DBMS_OUTPUT.put_line(v_emp_rec.first_name|| ' est un ' || v_emp_rec.JOB_TITLE|| ' il touch u salaire  de ****' ||v_emp_rec.MAX_SALARY);
   END LOOP;

  END;
  /

/*

b) Ecrire une fonction New_SAL (old_sal, pct) qui retourne le nouveau salaire de la façon
suivante : New_salary = old_sal * (1+ pct)
o Traiter dans cette fonction le cas ou pct est null comme une exception, et g
*/
CREATE OR REPLACE FUNCTION new_sal (
   old_sal IN NUMBER,
   pct     IN NUMBER
) RETURN NUMBER 
AS
   new_salary EMPLOYEES.salary%TYPE;
   pct_null_exc EXCEPTION;
BEGIN
   IF pct IS NOT NULL THEN
      new_salary := old_sal * (1 + pct);
      RETURN new_salary;
   ELSE
      RAISE pct_null_exc;
   END IF;

EXCEPTION
   WHEN pct_null_exc THEN
      DBMS_OUTPUT.PUT_LINE('La valeur de pct de l''employé est NULL');
      RETURN NULL;  
END;
/


DECLARE
v_new_sal EMPLOYEES.salary %type;
old_sal  EMPLOYEES.salary %type;
pct EMPLOYEES.COMMISSION_PCT %type;
BEGIN
select salary, commission_pct  into old_sal,pct from EMPLOYEES
where EMPLOYEE_ID=400;

v_new_sal :=new_sal(old_sal,pct);
IF v_new_sal IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Le nouveau salaire est : ' || v_new_sal);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Aucun employe trouve avec cet ID');

  END;
  /

/*
c) Ajouter l’attribut new_salary de type number à la table EMPLOYEES
*/

ALTER TABLE EMPLOYEES ADD new_salary  NUMBER(8,2);
/*
d) Ecrire un une procédure fait appel à cette fonction pour maitre à jour le champ new_salary
dans la table EMPLOYEES de la façon suivante :
New_salary = Salary * (1+commission_pct)

*/

CREATE OR REPLACE PROCEDURE new_salary AS 
  CURSOR emp_cursor IS
    SELECT employee_id, salary, commission_pct
    FROM EMPLOYEES;
    

  new_sal_value EMPLOYEES.salary%TYPE;

BEGIN
  
  FOR i IN emp_cursor LOOP
    new_sal_value := new_sal(i.salary, i.commission_pct);
    UPDATE EMPLOYEES
    SET new_salary = new_sal_value
    WHERE employee_id = i.employee_id;
  END LOOP;

  COMMIT; 
END;
/



-- Afficher les informations sur les old et new salary sous cette forme 
DECLARE
CURSOR c_emp is SELECT E.FIRST_NAME,E.SALARY,E.NEW_SALARY
FROM EMPLOYEES E;
v_emp_rec c_emp %rowtype;

BEGIN
  OPEN c_emp;
  LOOP
   FETCH c_emp into v_emp_rec;
   exit when c_emp %notfound;

   DBMS_OUTPUT.put_line(v_emp_rec.first_name|| '      ,ancien salaire *****' || v_emp_rec.SALARY|| '       nouveau salaire  ******' ||v_emp_rec.NEW_SALARY);
   END LOOP;
   CLOSE c_emp;

  END;
  /

/*

g) Ecrire un programme PLSQL qui utilise un curseur pour afficher les informations
suivantes :
o Nom_employer
o Son job
o Date_debut d’emploi
o Expérience exprimée en nombre de jours (afficher un chiffre arrondi sans virgule)
o Expérience exprimée en nombre de mois (afficher un chiffre arrondi sans virgule)
*/

DESCRIBE EMPLOYEES;
DESCRIBE jobs;
DESCRIBE JOB_HISTORY;


DECLARE 
CURSOR c_employe IS SELECT E.FIRST_NAME,J.JOB_TITLE,JH.START_DATE,JH.END_DATE
FROM EMPLOYEES E
JOIN JOBS J ON j.JOB_ID=E.JOB_ID
JOIN JOB_HISTORY JH ON JH.JOB_ID=J.JOB_ID;

v_nom EMPLOYEES.FIRST_NAME %type;
v_job_title JOBS.JOB_TITLE %type;
v_start_date JOB_HISTORY.START_DATE%type;
v_end_date JOB_HISTORY.END_DATE%type;
v_experience_jours NUMBER;
v_experience_mois  NUMBER;
v_emp_rec c_employe%rowtype;

BEGIN
  OPEN c_employe;
  LOOP
    FETCH c_employe into v_emp_rec;
    exit when c_employe%notfound;
    v_nom :=v_emp_rec.FIRST_NAME;
    v_job_title :=v_emp_rec.JOB_TITLE;
    v_start_date :=v_emp_rec.START_DATE;
    v_end_date := v_emp_rec.END_DATE;
  v_experience_jours := TRUNC(v_end_date - v_start_date);
  v_experience_mois  := ROUND(MONTHS_BETWEEN(v_end_date, v_start_date));
    dbms_output.PUT_LINE('Nom_employer '|| v_nom|| '| Son job '||v_job_title|| '| Date_debut d’emploi ' 
    ||v_start_date||'| Expérience en jours '||v_experience_jours ||' Jours'|| '| Expérience en mois '|| v_experience_mois || ' mois');
    end loop;
    CLOSE c_employe;


END;
/

ALTER TABLE EMPLOYEES ADD prochain_promo DATE;



DECLARE
  CURSOR c_employe IS
    SELECT E.EMPLOYEE_ID,
           E.FIRST_NAME,
           NVL(MAX(JH.START_DATE), E.HIRE_DATE) AS START_DATE
    FROM EMPLOYEES E
    LEFT JOIN JOB_HISTORY JH ON JH.EMPLOYEE_ID = E.EMPLOYEE_ID
    GROUP BY E.EMPLOYEE_ID, E.FIRST_NAME, E.HIRE_DATE;

BEGIN
  FOR emp IN c_employe LOOP
    DECLARE
      v_months_worked   NUMBER;
      v_next_centaine   NUMBER;
      v_next_promo_date DATE;
    BEGIN
      v_months_worked := MONTHS_BETWEEN(SYSDATE, emp.START_DATE);
      v_next_centaine := (FLOOR(v_months_worked / 100) + 1) * 100;
      v_next_promo_date := ADD_MONTHS(emp.START_DATE, v_next_centaine);

      UPDATE EMPLOYEES
      SET PROCHAIN_PROMO = v_next_promo_date
      WHERE EMPLOYEE_ID = emp.EMPLOYEE_ID;

      DBMS_OUTPUT.PUT_LINE(
        'Employé ' || emp.EMPLOYEE_ID || 
        ' (' || emp.FIRST_NAME || ')' ||
        ' Ancienneté: ' || TRUNC(v_months_worked) || ' mois de travail à cette date ' ||
        ' '|| SYSDATE ||
        ' sa prochaine date de promo sera le: ' || TO_CHAR(v_next_promo_date, 'DD/MM/YYYY')
      );
    END;
  END LOOP;
  
  COMMIT;
END;
/
