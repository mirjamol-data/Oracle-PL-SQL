/*  EX1
Create a program that displays the city and the state of the US locations of the company. Use
a nested table for the implementation. */


DECLARE
    TYPE t_loc_nt IS TABLE OF LOCATIONS%ROWTYPE;
    v_loc_nt t_loc_nt;
    v_cid COUNTRIES.COUNTRY_ID%TYPE;

BEGIN 
    SELECT COUNTRY_ID INTO v_cid
    FROM COUNTRIES 
    WHERE COUNTRY_NAME = 'United States of America';
    
    SELECT * BULK COLLECT INTO v_loc_nt
    FROM LOCATIONS 
    WHERE COUNTRY_ID = v_cid;
    
    FOR i IN 1..v_loc_nt.COUNT 
    LOOP 
        DBMS_OUTPUT.PUT_LINE(v_loc_nt(i).CITY || ' is in ' || v_loc_nt(i).STATE_PROVINCE || '.');
    END LOOP;
    
END;

--OUTPUT:
--Southlake is in Texas.
--South San Francisco is in California.
--South Brunswick is in New Jersey.
--Seattle is in Washington.
/





/*EX2
Create a table called EMPLOYEES_SEN with the same structure as the EMPLOYEES table.
Then create a program that copies the data of those employees to it who were hired the
earliest in their respective departments, and raises their salary by 25%. Use an associative
array for the implementation.*/

DROP TABLE EMPLOYEES_SEN;
CREATE TABLE EMPLOYEES_SEN AS SELECT * FROM EMPLOYEES 
WHERE 1=2; --Copies the structure(columns) of the table, but not records.

SELECT * FROM EMPLOYEES_SEN;
/

DECLARE
    TYPE t_emp IS TABLE OF EMPLOYEES%ROWTYPE 
                    INDEX BY PLS_INTEGER; --every value is parked at a specific integer address
    v_emp t_emp; --no Initialization needed.
    v_dept_emp t_emp;
    TYPE t_dept_ids IS TABLE OF EMPLOYEES.DEPARTMENT_ID%TYPE;
    v_dept_ids t_dept_ids;
    idx PLS_INTEGER; --faster than NUMBER
    
BEGIN 
    SELECT DISTINCT DEPARTMENT_ID BULK COLLECT INTO v_dept_ids 
    FROM EMPLOYEES 
    WHERE DEPARTMENT_ID IS NOT NULL;

    
    FOR i IN 1..v_dept_ids.COUNT
    LOOP 
        SELECT * BULK COLLECT INTO v_emp FROM EMPLOYEES 
        WHERE DEPARTMENT_ID = v_dept_ids(i) AND HIRE_DATE IS NOT NULL
        ORDER BY HIRE_DATE ASC; 
        
        v_dept_emp(v_dept_ids(i)) := v_emp(1);
    END LOOP; 
    
    idx := v_dept_emp.FIRST; 
    WHILE idx IS NOT NULL 
    LOOP 
        v_dept_emp(idx).SALARY := v_dept_emp(idx).SALARY * 1.25;
        INSERT INTO EMPLOYEES_SEN VALUES v_dept_emp(idx);
        idx := v_dept_emp.NEXT(idx); 
    END LOOP;
END;
/

-- Run the query below to see the original SALARY value of the employees. 
-- employees who were hired the earliest in their respective departments. 
SELECT *
FROM (
    SELECT 
        EMPLOYEE_ID, 
        HIRE_DATE, 
        DEPARTMENT_ID, 
        SALARY,
        ROW_NUMBER() OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE) AS RANK_FOR_EARLIEST 
    FROM EMPLOYEES
    WHERE HIRE_DATE IS NOT NULL AND DEPARTMENT_ID IS NOT NULL
    ) 
WHERE RANK_FOR_EARLIEST = 1;
/




/*   EX3
Create a program that collects the IDs, salaries and hire dates of the employees into an
associative array, then displays the full name and department of the employee whose
salary/experience ratio is the highest.*/

DECLARE
    -- Defining the Record type for the three specific columns
    TYPE t_emp_rec IS RECORD (
        emp_id    employees.employee_id%TYPE,
        salary    employees.salary%TYPE,
        hire_date employees.hire_date%TYPE
    );

    -- Defining the Associative Array (Index by PLS_INTEGER)
    TYPE t_emp_assoc_arr IS TABLE OF t_emp_rec INDEX BY PLS_INTEGER;
    
    v_emps t_emp_assoc_arr;
    v_max_ratio NUMBER := -1;
    v_curr_ratio NUMBER;
    v_winner_id employees.employee_id%TYPE;
    
    -- Variables for final display
    v_full_name VARCHAR2(100);
    v_dept_name departments.department_name%TYPE;
    
BEGIN
    SELECT EMPLOYEE_ID, SALARY, HIRE_DATE 
    BULK COLLECT INTO v_emps
    FROM EMPLOYEES;

    -- Looping through the array to find the highest salary/experience ratio  
    FOR i IN 1 .. v_emps.COUNT 
    LOOP
        v_curr_ratio := v_emps(i).salary / (SYSDATE - v_emps(i).hire_date);

        IF v_curr_ratio > v_max_ratio THEN
            v_max_ratio := v_curr_ratio;
            v_winner_id := v_emps(i).emp_id;
        END IF;
    END LOOP;

    SELECT e.FIRST_NAME || ' ' || e.LAST_NAME, d.DEPARTMENT_NAME
        INTO v_full_name, v_dept_name
    FROM EMPLOYEES e
    LEFT JOIN DEPARTMENTS d USING(DEPARTMENT_ID)
    WHERE e.EMPLOYEE_ID = v_winner_id;

    DBMS_OUTPUT.PUT_LINE('Employee with Highest Salary/Experience Ratio: ' || v_full_name);
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_dept_name);
    DBMS_OUTPUT.PUT_LINE('Ratio Value: ' || ROUND(v_max_ratio, 4));
END;
--OUTPUT: 
--Employee with Highest Salary/Experience Ratio: Steven King
--Department: Executive
--Ratio Value: 2.877
/



/*    EX4
Create a program that generates 10 random employee IDs (10 integers between 100 and
206), then stores these and the corresponding salary values selected from the employees
table in a variable-size array, and finally displays the stored data.*/

DECLARE
   TYPE t_emp_rec IS RECORD (
      emp_id employees.employee_id%TYPE,
      salary employees.salary%TYPE);
   TYPE t_emp_arr IS VARRAY(10) OF t_emp_rec;

   v_emp_list t_emp_arr := t_emp_arr();
   v_temp_id  NUMBER;
   v_temp_sal employees.salary%TYPE;
   
BEGIN

    FOR i IN 1..10 
    LOOP
        v_temp_id := TRUNC(DBMS_RANDOM.VALUE(100, 207));

        SELECT SALARY INTO v_temp_sal 
        FROM EMPLOYEES 
        WHERE EMPLOYEE_ID = v_temp_id;

        v_emp_list.EXTEND;
        v_emp_list(v_emp_list.LAST).emp_id := v_temp_id;
        v_emp_list(v_emp_list.LAST).salary := v_temp_sal;
    END LOOP;
    
    FOR i IN 1..v_emp_list.COUNT 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Employee ID ' || v_emp_list(i).emp_id ||
                            ' has salary of '|| v_emp_list(i).salary);
    END LOOP;   
END;

--ONE OUTPUT:
/* Employee ID 119 has salary of 2500
Employee ID 163 has salary of 9500
Employee ID 197 has salary of 3000
Employee ID 139 has salary of 2700
Employee ID 123 has salary of 6500
Employee ID 100 has salary of 24000
Employee ID 194 has salary of 3200
Employee ID 169 has salary of 10000
Employee ID 140 has salary of 2500
Employee ID 181 has salary of 3100 */


