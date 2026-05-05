/*  EX1
Create a program that displays the full name and salary of those employees whose salary is
higher than a given number. Use a parametric cursor for the implementation. */


DECLARE 
    CURSOR cur_sal (p_min_sal EMPLOYEES.SALARY%TYPE) IS 
        SELECT * FROM EMPLOYEES WHERE SALARY > p_min_sal;
    v_emp_rec EMPLOYEES%ROWTYPE; 
    v_min_sal EMPLOYEES.SALARY%TYPE := 10000;

BEGIN 
    OPEN cur_sal(v_min_sal);
    
    LOOP 
        FETCH cur_sal INTO v_emp_rec;
        EXIT WHEN cur_sal%NOTFOUND; 
        DBMS_OUTPUT.PUT_LINE('The salary of ' || v_emp_rec.FIRST_NAME || ' ' || 
                                v_emp_rec.LAST_NAME || ' is ' || v_emp_rec.SALARY);
    END LOOP;
    
    CLOSE cur_sal;

END;

/



/*   EX2
Modify the previous program to display the number of employees for the different salary
values. */



DECLARE 
    TYPE t_sal_num IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    CURSOR cur_sal (p_min_sal EMPLOYEES.SALARY%TYPE) IS 
        SELECT * FROM EMPLOYEES WHERE SALARY > p_min_sal;
    v_emp_rec EMPLOYEES%ROWTYPE; 
    v_min_sal EMPLOYEES.SALARY%TYPE := 10000;
    v_sal_num t_sal_num;
    idx PLS_INTEGER;

BEGIN 
    OPEN cur_sal(v_min_sal);
    
    LOOP 
        FETCH cur_sal INTO v_emp_rec;
        EXIT WHEN cur_sal%NOTFOUND; 
        DBMS_OUTPUT.PUT_LINE('The salary of ' || v_emp_rec.FIRST_NAME || ' ' || 
                                v_emp_rec.LAST_NAME || ' is ' || v_emp_rec.SALARY);
        BEGIN 
            v_sal_num(v_emp_rec.SALARY) := v_sal_num(v_emp_rec.SALARY) + 1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    v_sal_num(v_emp_rec.SALARY) := 1;
        END;
    END LOOP;
    
    CLOSE cur_sal;

    idx := v_sal_num.FIRST; 
    WHILE idx IS NOT NULL
    LOOP 
        DBMS_OUTPUT.PUT_LINE(idx ||' - '|| v_sal_num(idx));
        idx := v_sal_num.NEXT(idx);
    END LOOP; 
END;
/



/*    EX3
Create a table to store the first name, last name and salary of employees. Then create a
program that inserts a given number of rows into this table with randomly selected data from
the EMPLOYEES table. */

--using CTAS here:
CREATE TABLE EMP_TEMP AS SELECT FIRST_NAME, LAST_NAME, SALARY 
FROM EMPLOYEES WHERE 1=2;
/
SELECT * FROM EMP_TEMP;
/

DECLARE 
    TYPE t_emps IS TABLE OF EMP_TEMP%ROWTYPE;    
    TYPE t_ids  IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    v_emps t_emps := t_emps();                         
    v_ids  t_ids;
    v_rand NUMBER(3);
    v_num  NUMBER := 10;
BEGIN 
    SELECT FIRST_NAME, LAST_NAME, SALARY 
    BULK COLLECT INTO v_emps
    FROM EMPLOYEES;
    
    WHILE v_ids.COUNT < v_num
    LOOP 
        v_rand := TRUNC(DBMS_RANDOM.VALUE(v_emps.FIRST, v_emps.LAST + 1));
        v_ids(v_rand) := v_rand; 
    END LOOP; 
    
    FORALL i IN VALUES OF v_ids INSERT INTO EMP_TEMP VALUES v_emps(i);
END;