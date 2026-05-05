/*  EX1
Create a procedure that takes an employee ID as parameter, and increases the employee's
salary according to the years of experience in the following way: experience > 15: +25%; 15
>= experience > 10: +15%; 10 >= experience > 5: +5%; else: +2%.
Store the employee IDs of the department with ID 50 in a nested table
and call the procedure for these.
Handle the possible exceptions. */

DECLARE 
    TYPE t_emp_id IS TABLE OF EMPLOYEES.EMPLOYEE_ID%TYPE;
    v_emp_ids t_emp_id; 
    
    PROCEDURE raise_sal (p_emp_id EMPLOYEES.EMPLOYEE_ID%TYPE) IS 
        v_experience NUMBER(3);
        v_raise NUMBER(3,2);
    BEGIN 
        SELECT FLOOR((SYSDATE-HIRE_DATE)/365) INTO v_experience
        FROM EMPLOYEES 
        WHERE EMPLOYEE_ID = p_emp_id; 
        
        CASE 
            WHEN v_experience > 15 THEN 
                v_raise := 1.25;
            WHEN v_experience > 10 THEN 
                v_raise := 1.15;
            WHEN v_experience > 5 THEN 
                v_raise := 1.05;
            ELSE 
                v_raise := 1.02;
        END CASE;
            
        UPDATE EMPLOYEES 
        SET SALARY = SALARY * v_raise
        WHERE EMPLOYEE_ID = p_emp_id;
        
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                DBMS_OUTPUT.PUT_LINE('Employee ' || p_emp_id || ' not found.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error updating employee ' || p_emp_id);
        END raise_sal;   
BEGIN 
    SELECT EMPLOYEE_ID BULK COLLECT INTO v_emp_ids
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = 50;
    
    FOR i IN 1..v_emp_ids.COUNT
    LOOP 
        raise_sal(v_emp_ids(i));
    END LOOP;
END;
/
SELECT * 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID = 50;
/



/*  EX2
Create a function that takes an employee ID as parameter and returns the number of
previous jobs for this employee ID. Create a program that displays the full name of those
employees who had previous jobs at the company. */

DECLARE 
    v_num_prev_jobs NUMBER;

    FUNCTION job_count(p_emp_id EMPLOYEES.EMPLOYEE_ID%TYPE) 
    RETURN NUMBER IS 
        v_count NUMBER;
    BEGIN 
        SELECT COUNT(*) INTO v_count
        FROM JOB_HISTORY
        WHERE EMPLOYEE_ID = p_emp_id;
    
        RETURN v_count;
    END;
    
BEGIN 
    FOR c IN (SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME FROM EMPLOYEES)
    LOOP
        v_num_prev_jobs := job_count(c.EMPLOYEE_ID);
        IF v_num_prev_jobs > 0 THEN 
            DBMS_OUTPUT.PUT_LINE(c.EMPLOYEE_ID ||' '|| c.FIRST_NAME ||' '|| c.LAST_NAME 
                        ||' had '|| v_num_prev_jobs || ' jobs.');
        END IF;
    END LOOP;
END;

--OUTPUT:
--101 Neena Kochhar had 2 jobs.
--102 Lex De Haan had 1 jobs.
--114 Den Raphaely had 1 jobs.
--122 Payam Kaufling had 1 jobs.
--176 Jonathon Taylor had 2 jobs.
--200 Jennifer Whalen had 2 jobs.
--201 Michael Hartstein had 1 jobs.
/

/* EX3
Create a stored function from the above function, then create an SQL query that displays the
full names of the employees of the company and the number of their previous jobs. */


CREATE OR REPLACE FUNCTION prev_job_count(p_emp_id EMPLOYEES.EMPLOYEE_ID%TYPE) 
RETURN NUMBER IS 
    v_count NUMBER;
BEGIN 
    SELECT COUNT(*) INTO v_count
    FROM JOB_HISTORY
    WHERE EMPLOYEE_ID = p_emp_id;

    RETURN v_count;
END;
/
SELECT FIRST_NAME ||' '|| LAST_NAME, prev_job_count(EMPLOYEE_ID) 
FROM EMPLOYEES;
/
DROP FUNCTION prev_job_count;


