/*   EX1
Create a program that displays the full name of the manager of a given employee id of 142 and the
name of the department where the manager works. */

DECLARE
    v_emp_id EMPLOYEES.EMPLOYEE_ID%TYPE := 142;
    v_man_id EMPLOYEES.MANAGER_ID%TYPE;
    v_first_name EMPLOYEES.FIRST_NAME%TYPE;
    v_last_name EMPLOYEES.FIRST_NAME%TYPE;
    v_dept_id EMPLOYEES.DEPARTMENT_ID%TYPE;
    v_dept_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;

BEGIN 
    SELECT MANAGER_ID INTO v_man_id 
    FROM EMPLOYEES 
    WHERE EMPLOYEE_ID = v_emp_id;
    
    
    SELECT FIRST_NAME, LAST_NAME, DEPARTMENT_ID
        INTO v_first_name, v_last_name, v_dept_id
    FROM EMPLOYEES 
    WHERE EMPLOYEE_ID = v_man_id;
    
    SELECT DEPARTMENT_NAME INTO v_dept_name
    FROM DEPARTMENTS
    WHERE DEPARTMENT_ID = v_dept_id;
    
    DBMS_OUTPUT.PUT_LINE('Full Name of the Manager: ' || v_first_name ||' '|| v_last_name);
    DBMS_OUTPUT.PUT_LINE('Department Name: ' || v_dept_name);
END;
/



/*   EX2
Create a program that checks whether the employee with the ID 160 or 162 has higher salary,
and sets the lower salary to the value of the higher one. */

DECLARE 
    v_emp_id_a EMPLOYEES.EMPLOYEE_ID%TYPE := 160;
    v_emp_id_b EMPLOYEES.EMPLOYEE_ID%TYPE := 162;
    v_salary_a EMPLOYEES.SALARY%TYPE;
    v_salary_b EMPLOYEES.SALARY%TYPE; 
    
BEGIN 
    SELECT SALARY INTO v_salary_a FROM EMPLOYEES WHERE EMPLOYEE_ID = v_emp_id_a;
    SELECT SALARY INTO v_salary_b FROM EMPLOYEES WHERE EMPLOYEE_ID = v_emp_id_b;
    
    IF v_salary_a > v_salary_b THEN 
        UPDATE EMPLOYEES 
        SET SALARY = v_salary_a 
        WHERE EMPLOYEE_ID = v_emp_id_b;
    ELSE 
        UPDATE EMPLOYEES 
        SET SALARY = v_salary_b 
        WHERE EMPLOYEE_ID = v_emp_id_a;
    END IF;
    
END;
/
SELECT EMPLOYEE_ID, SALARY 
FROM EMPLOYEES 
WHERE EMPLOYEE_ID IN (160,162);



/*   EX3
Create a program that calculates the years of experience for a given employee (based on
his/her employee ID of 124), and raises his/her salary as follows: experience > 15: +25%; 15 >=
experience > 10: +15%; 10 >= experience > 5: +5%; else: +2%.*/

DECLARE 
    v_emp_id EMPLOYEES.EMPLOYEE_ID%TYPE := 124;
    v_experience NUMBER;
    v_raise NUMBER(3,2); -- 3 total digits, of which 2 are after the decimal point.

BEGIN 
    SELECT (SYSDATE - HIRE_DATE)/365  -- date subtraction returns difference in days, so /365 -> years 
             INTO v_experience
    FROM EMPLOYEES 
    WHERE EMPLOYEE_ID = v_emp_id;

    CASE 
        WHEN v_experience > 15 THEN 
            v_raise := 1.25;  -- 25% increase 
        WHEN v_experience > 10 THEN 
            v_raise := 1.15;
        WHEN v_experience > 5 THEN 
            v_raise := 1.05;
        ELSE 
            v_raise := 1.02;
    END CASE;
    
    UPDATE EMPLOYEES 
    SET SALARY = SALARY * v_raise 
    WHERE EMPLOYEE_ID = v_emp_id;

END;
/
SELECT EMPLOYEE_ID, TRUNC((SYSDATE - HIRE_DATE)/365) AS EXPERIENCE,  SALARY 
FROM EMPLOYEES 
WHERE EMPLOYEE_ID = 124;
/




/*   EX4
Create a program that checks whether the employee IDs are continuous or not in the
EMPLOYEES table (i.e., whether there are missing IDs). */

DECLARE 
    v_id_min EMPLOYEES.EMPLOYEE_ID%TYPE;
    v_id_max EMPLOYEES.EMPLOYEE_ID%TYPE;
    v_count NUMBER;
    v_flag BOOLEAN := TRUE; 


BEGIN 
    SELECT MIN(EMPLOYEE_ID), MAX(EMPLOYEE_ID) INTO v_id_min, v_id_max 
    FROM EMPLOYEES;
    
    FOR i IN v_id_min .. v_id_max
    LOOP 
        SELECT COUNT(*) INTO v_count
        FROM EMPLOYEES 
        WHERE EMPLOYEE_ID = i;
        
        IF v_count = 0 THEN 
            v_flag := FALSE;
            EXIT;
        END IF;
    END LOOP;
    
    IF v_flag THEN 
        DBMS_OUTPUT.PUT_LINE('Employee IDs are continuous');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Employee IDs are NOT continuous');
    END IF;
    
END;
/




/*   EX5
Create a program that displays the number of hired employees for each month in a given year
(e.g., 2005). */


DECLARE 
    v_year NUMBER := 2005;
    v_count NUMBER;
BEGIN 
    FOR i IN 1 .. 12 
    LOOP 
        SELECT COUNT(*) INTO v_count
        FROM EMPLOYEES 
        WHERE EXTRACT(year FROM HIRE_DATE) = v_year 
            AND EXTRACT(month FROM HIRE_DATE) = i;
        
        DBMS_OUTPUT.PUT_LINE('In Month #' || TO_CHAR(i) || ': ' || TO_CHAR(v_count) || ' employees were hired');
    END LOOP;

END;
/
SELECT EXTRACT(month FROM HIRE_DATE) AS MONTH_NUM, COUNT(*)
FROM EMPLOYEES
WHERE EXTRACT(year FROM HIRE_DATE) = 2005
GROUP BY EXTRACT(month FROM HIRE_DATE)
ORDER BY 1;

