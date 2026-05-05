
/* 
1. Create a PL/SQL program that identifies the manager with the most direct reports
(employees who report directly to a manager), collects the employee IDs and full
names of the employees reporting to that manager into an associative array, with
the employee ID as the key, and then displays the employee ID and full name of
each employee 
*/

DECLARE
    TYPE t_emp_arr IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
    v_employee_names t_emp_arr; 
    v_manager_id HR.EMPLOYEES.MANAGER_ID%TYPE;
    v_manager_rec HR.EMPLOYEES%ROWTYPE; 
    
BEGIN
    -- Find the manager with the most direct reports
    SELECT MANAGER_ID INTO v_manager_id
    FROM EMPLOYEES
    GROUP BY MANAGER_ID
    ORDER BY COUNT(*) DESC
    FETCH FIRST 1 ROWS ONLY;
    
    SELECT * INTO v_manager_rec
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = v_manager_id;
    
    DBMS_OUTPUT.PUT_LINE('Manager with the most direct reports: ' 
    || v_manager_rec.first_name || ' ' || v_manager_rec.last_name);


    FOR emp IN (SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME
                FROM EMPLOYEES
                WHERE manager_id = v_manager_id) 
    LOOP
        -- Storing employees's full names in the array using their employee_id as a key
        v_employee_names(emp.EMPLOYEE_ID) := emp.FIRST_NAME || ' ' || emp.LAST_NAME;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Employees reporting to this manager:');
    
    
    FOR emp_id IN (SELECT EMPLOYEE_ID
                   FROM EMPLOYEES
                   WHERE MANAGER_ID = v_manager_id) 
    LOOP
        -- Using the employee_id to fetch the name from the associative array
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || emp_id.EMPLOYEE_ID || ' - ' || 
                                        v_employee_names(emp_id.EMPLOYEE_ID));
    END LOOP;

END;
/







/*
2. Create a PL/SQL program that identifies the department with the highest number
of employees. Collect the full names (first name and last name) of the employees
belonging to that department into a nested table and sort the names in
alphabetical order. Finally, display the department name and the full names of all
employees in the sorted order.
*/


DECLARE
    TYPE t_emp_names IS TABLE OF VARCHAR2(100);
    v_emp_names t_emp_names := t_emp_names(); --initialized
    
    v_idx PLS_INTEGER;
    v_dept_id EMPLOYEES.DEPARTMENT_ID%TYPE;
    v_dept_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
    
BEGIN 
    SELECT DEPARTMENT_ID INTO v_dept_id
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID IS NOT NULL
    GROUP BY DEPARTMENT_ID
    ORDER BY COUNT(*) DESC
    FETCH FIRST 1 ROWS ONLY;
    
    SELECT DEPARTMENT_NAME INTO v_dept_name
    FROM DEPARTMENTS 
    WHERE DEPARTMENT_ID = v_dept_id;
    
    DBMS_OUTPUT.PUT_LINE('Department with most employees: ' || v_dept_name);
    
    
    SELECT FIRST_NAME ||' '|| LAST_NAME BULK COLLECT INTO v_emp_names
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = v_dept_id;
      
    FOR i IN 1..v_emp_names.COUNT
    LOOP 
        DBMS_OUTPUT.PUT_LINE(v_emp_names(i));
    END LOOP;
    
END;
/
    
    
    
    
    
    
    
    
/*    
3. Write a PL/SQL function that checks whether a given manager has at least one employee who
earns more than the manager. The function should take the manager's EMPLOYEE_ID as input
and return TRUE if any of the manager’s subordinates have a higher salary, and FALSE
otherwise.
*/


CREATE OR REPLACE FUNCTION has_higher_paid_employee(p_manager_id IN HR.EMPLOYEES.EMPLOYEE_ID%TYPE) 
RETURN BOOLEAN IS
    v_manager_salary HR.EMPLOYEES.SALARY%TYPE;
    v_employee_salary HR.EMPLOYEES.SALARY%TYPE;
BEGIN
    SELECT SALARY INTO v_manager_salary
    FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID = p_manager_id;


    FOR emp IN (SELECT EMPLOYEE_ID, SALARY 
                FROM HR.EMPLOYEES 
                WHERE MANAGER_ID = p_manager_id) LOOP
        v_employee_salary := emp.SALARY;
        IF v_employee_salary > v_manager_salary THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE; 
END has_higher_paid_employee;
/

DECLARE
    v_result BOOLEAN;
BEGIN
    -- Testing the function for different managers
    v_result := has_higher_paid_employee(114);  
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Manager 114 has a higher-paid subordinate.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Manager 114 does not have a higher-paid subordinate.');
    END IF;

    v_result := has_higher_paid_employee(103);
    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Manager 103 has a higher-paid subordinate.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Manager 103 does not have a higher-paid subordinate.');
    END IF;

END;
/





/* 
4.  Create a local function that takes a department ID as a parameter and returns 
a nested table with the job IDs of the employees of the department (each job ID should be listed only once)!
The function should not display anything.
Create a program that displays the names of those departments where 
the number of different jobs is at least 2 (using the above function).
Use a cursor FOR loop for the implementation.

Expected result:
Accounting (2)
Executive (2)
Finance (2)
Marketing (2)
Purchasing (2)
Sales (2)
Shipping (3)
*/

DECLARE
    TYPE t_job_ids IS TABLE OF JOBS.JOB_ID%TYPE;
    v_job_ids t_job_ids;
    
    FUNCTION f_jobs_in_dept(p_dept_id EMPLOYEES.DEPARTMENT_ID%TYPE) RETURN t_job_ids IS   
    r_job_ids t_job_ids;
    BEGIN 
        SELECT DISTINCT JOB_ID BULK COLLECT INTO r_job_ids
        FROM EMPLOYEES
        WHERE DEPARTMENT_ID = p_dept_id;
        
        RETURN r_job_ids;
    END f_jobs_in_dept;
    
BEGIN 
    FOR c in (SELECT DEPARTMENT_ID, DEPARTMENT_NAME FROM DEPARTMENTS)
    LOOP 
        v_job_ids := f_jobs_in_dept(c.DEPARTMENT_ID);
        IF v_job_ids.COUNT >=2 THEN 
            DBMS_OUTPUT.PUT_LINE(c.DEPARTMENT_NAME || ' (' || v_job_ids.COUNT || ')');
        END IF;
    END LOOP;
    
END;



