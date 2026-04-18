/* EX1
Create a program that generates 100 random integers between 1 and 5 and then calculates
the histogram of the values. Store the histogram in a variable-size array. */

DECLARE 
    TYPE t_hist IS VARRAY(5) OF NUMBER; 
    v_hist t_hist := t_hist(0,0,0,0,0);
    v_rand_num NUMBER(1);

BEGIN 
    FOR i IN 1..100
    LOOP 
        v_rand_num := TRUNC(DBMS_RANDOM.VALUE(1,6));
        v_hist(v_rand_num) := v_hist(v_rand_num) + 1;
    END LOOP;
    
    FOR i IN 1..v_hist.COUNT  -- number of current elements in the array 
    LOOP 
        DBMS_OUTPUT.PUT_LINE(i || ' - ' || v_hist(i));
    END LOOP;

END;
/* one output: 
1 - 20
2 - 19
3 - 21
4 - 19
5 - 21 */
/



/* EX2
Create a program that stores the data of an employee with a given first name in a record and
then displays its full name and hire date (format: YYYY-MM-DD). Handle the possible
exceptions.*/


DECLARE 
    v_emp_rec EMPLOYEES%ROWTYPE;
    v_first_name EMPLOYEES.FIRST_NAME%TYPE := 'Jack'; --&v_first_name

BEGIN 
    SELECT * INTO v_emp_rec 
    FROM EMPLOYEES 
    WHERE FIRST_NAME = v_first_name; 
    
    DBMS_OUTPUT.PUT_LINE(v_emp_rec.FIRST_NAME ||' '|| v_emp_rec.LAST_NAME || ' - ' 
                        || TO_CHAR(v_emp_rec.HIRE_DATE, 'YYYY-MM-DD'));
                        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            DBMS_OUTPUT.PUT_LINE('There is no employee called ' || v_first_name);
        WHEN TOO_MANY_ROWS THEN 
            DBMS_OUTPUT.PUT_LINE('There are more than one employee called ' || v_first_name);
            
END;
/* outputs: 
Jack Livingston - 2006-04-23

When v_first_name:= 'John' -> There are more than one employee called John

When v_first_name:= 'Mirjamol' -> There is no employee called Mirjamol
*/
/




/* EX3
Create a program that generates 10 random employee IDs (10 integers between 100 and
206), then stores these and the corresponding salary values selected from the employees
table in a variable-size array, and finally displays the stored data. */


DECLARE 
    TYPE t_sal_rec IS RECORD (
            emp_id EMPLOYEES.EMPLOYEE_ID%TYPE, 
            salary EMPLOYEES.SALARY%TYPE);
    TYPE t_sal_arr IS VARRAY(10) OF t_sal_rec;
    v_sal_arr t_sal_arr := t_sal_arr(); 

BEGIN 
    FOR i IN 1.. v_sal_arr.LIMIT
    LOOP 
        v_sal_arr.EXTEND();
        v_sal_arr(i).emp_id := TRUNC(DBMS_RANDOM.VALUE(100,207));
        SELECT SALARY INTO v_sal_arr(i).salary 
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = v_sal_arr(i).emp_id;
    END LOOP;
    
    FOR i in 1..v_sal_arr.COUNT 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Employee ID ' || TO_CHAR(v_sal_arr(i).emp_id) || 
                            ' has salary of ' || TO_CHAR(v_sal_arr(i).salary));
    END LOOP;
    
END;

/* One output:
Employee ID 177 has salary of 8400
Employee ID 196 has salary of 3100
Employee ID 136 has salary of 2200
Employee ID 115 has salary of 3100
Employee ID 147 has salary of 12000
Employee ID 159 has salary of 8000
Employee ID 172 has salary of 7300
Employee ID 105 has salary of 4800
Employee ID 197 has salary of 3000
Employee ID 116 has salary of 2900
*/










