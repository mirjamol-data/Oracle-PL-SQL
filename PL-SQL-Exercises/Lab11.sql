/*   EX1
Create a local function:
- Parameters: a department ID (p_dept_id) and a salary value (p_sal)
- Returns: a nested table that contains the IDs of those employees who earn more than p_sal
in the department with the ID p_dept_id.
Create a program that display the full names of those employees who earn more than 10000
at the department "Shipping" (using the function above).
Expected output:
Matthew Weiss
Adam Fripp
Payam Kaufling
Shanta Vollman
Kevin Mourgos */


DECLARE
    TYPE t_emp_ids IS TABLE OF EMPLOYEES.EMPLOYEE_ID%TYPE;
    v_dept_id EMPLOYEES.DEPARTMENT_ID%TYPE;
    v_emp_nt t_emp_ids;
    v_full_name VARCHAR(100);
    
    
    FUNCTION f_higher_paid_emps (p_dept_id EMPLOYEES.DEPARTMENT_ID%TYPE, p_sal EMPLOYEES.SALARY%TYPE) 
    RETURN t_emp_ids IS 
        v_emp_ids t_emp_ids;
    BEGIN 
        SELECT EMPLOYEE_ID BULK COLLECT INTO v_emp_ids
        FROM EMPLOYEES 
        WHERE DEPARTMENT_ID = p_dept_id AND SALARY > p_sal;
        
        RETURN v_emp_ids;
    END f_higher_paid_emps;
    

BEGIN 
    SELECT DEPARTMENT_ID INTO v_dept_id 
    FROM DEPARTMENTS 
    WHERE DEPARTMENT_NAME = 'Shipping';
    
    v_emp_nt := f_higher_paid_emps(v_dept_id, 10000);
    
    FOR i IN 1..v_emp_nt.COUNT
    LOOP
        SELECT FIRST_NAME ||' '|| LAST_NAME INTO v_full_name FROM EMPLOYEES WHERE EMPLOYEE_ID = v_emp_nt(i);
        DBMS_OUTPUT.PUT_LINE(v_full_name);
    END LOOP; 

END;
/


/*    EX2
Create a program that displays the following statistics for each job title that is present at a
department (e.g., "Sales"):
- number of employees,
- average salary (rounded),
- average work experience (in days, rounded).
Expected output:
Sales Manager
5 employee(s), avg. sal.: 12200, avg. exp.: 6272 days
Sales Representative
29 employee(s), avg. sal. 8397, avg. exp.: 6206 days */



DECLARE
    v_dept_id DEPARTMENTS.DEPARTMENT_ID%TYPE;

BEGIN 
    SELECT DEPARTMENT_ID INTO v_dept_id FROM DEPARTMENTS WHERE DEPARTMENT_NAME = 'Sales';
    
    FOR r IN (SELECT JOB_TITLE, COUNT(EMPLOYEE_ID) C, ROUND(AVG(SALARY)) S, ROUND(AVG(SYSDATE-HIRE_DATE)) E
                FROM EMPLOYEES LEFT JOIN JOBS USING(JOB_ID) 
                WHERE DEPARTMENT_ID = v_dept_id
                GROUP BY JOB_TITLE)
    LOOP 
        DBMS_OUTPUT.PUT_LINE(r.JOB_TITLE);
        DBMS_OUTPUT.PUT_LINE(r.C || ' employee(s), AVG salary: ' || r.S || ', AVG experience(in days): '|| r.E); 
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;

END;
/


/*   EX3
Create a local function:
- Parameters: an employee ID (p_id)
- Returns: the number of employees who have the same job title, but less work experience
as the employee with the ID p_id
Create a program that displays the full names of employees who have the same job title but
more work experience as at least 25 other employees (using the function above).
Expected output:
Allan McEwen
Ellen Abel
Janette King
Patrick Sully
Peter Tucker */

DECLARE 
    
    FUNCTION f_num_less_exp(p_emp_id EMPLOYEES.EMPLOYEE_ID%TYPE) RETURN NUMBER IS 
        v_exp NUMBER;
        v_count NUMBER;
        v_job_id VARCHAR(20);
    BEGIN 
        SELECT SYSDATE - HIRE_DATE, JOB_ID INTO v_exp, v_job_id
        FROM EMPLOYEES WHERE EMPLOYEE_ID = p_emp_id;
        
        SELECT COUNT(*) INTO v_count
        FROM EMPLOYEES 
        WHERE (SYSDATE - HIRE_DATE) < v_exp AND JOB_ID = v_job_id; 
        
        RETURN v_count;
        
    END f_num_less_exp;
    
BEGIN 
    FOR c IN (SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME FROM EMPLOYEES)
    LOOP
        IF f_num_less_exp(c.EMPLOYEE_ID) >= 25 THEN
            DBMS_OUTPUT.PUT_LINE(c.FIRST_NAME ||' '|| c.LAST_NAME);
        END IF;
    END LOOP; 
END;
/
