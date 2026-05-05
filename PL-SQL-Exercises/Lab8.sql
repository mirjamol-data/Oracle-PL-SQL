/*   EX1
Create a trigger that prevents reducing the salary of the employees. Use the
RAISE_APPLICATION_ERROR procedure in the implementation. */

CREATE OR REPLACE TRIGGER tr_emp_sal_check  
BEFORE UPDATE OF SALARY ON EMPLOYEES 
FOR EACH ROW
BEGIN 
    IF :OLD.SALARY > :NEW.SALARY THEN 
        RAISE_APPLICATION_ERROR(-20000, 'The salary cannot be decreased.');
    END IF;
END tr_emp_sal_check;
/
UPDATE EMPLOYEES SET SALARY = SALARY * 0.8;



/*   EX2
Create a table called test_table that has a column of type NUMBER called val_num.
Create a trigger that writes to the buffer what DML statements (INSERT, UPDATE, DELETE)
were executed and when on the table.
Check the proper working of the trigger using DML statements.*/

DROP TABLE test_table;

CREATE TABLE test_table (val_num NUMBER);

CREATE OR REPLACE TRIGGER tr_logging_DML
AFTER INSERT OR UPDATE OR DELETE ON test_table
FOR EACH ROW
BEGIN 
    DBMS_OUTPUT.PUT_LINE(
        CASE 
            WHEN INSERTING THEN 'INSERT'
            WHEN UPDATING THEN 'UPDATE'
            WHEN DELETING THEN 'DELETE'
        END ||
        ' performed at ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')
    );
END tr_loggin_DML; 
/
INSERT INTO test_table VALUES(10);
INSERT INTO test_table VALUES(15);
INSERT INTO test_table VALUES(77);
UPDATE test_table SET val_num = 55 WHERE val_num = 15;
DELETE FROM test_table WHERE val_num < 20; 

SELECT * FROM test_table;
DROP TABLE test_table; 
/


/*   EX3
Create a trigger that writes the employee ID, the old salary, the new salary, and the difference
of these values to the buffer if the SALARY column of the EMPLOYEES table is updated.
For example:
100 - old: 19200, new: 23040, diff: 3840
101 - old: 13600, new: 16320, diff: 2720
... */


CREATE OR REPLACE TRIGGER tr_sal_update 
AFTER UPDATE OF SALARY ON EMPLOYEES
FOR EACH ROW 
DECLARE 
    diff NUMBER;
BEGIN 
    diff := :NEW.SALARY - :OLD.SALARY;
    DBMS_OUTPUT.PUT_LINE(:OLD.EMPLOYEE_ID ||' - old: '|| :OLD.SALARY 
                        ||', new: '|| :NEW.SALARY ||', diff: '|| diff);
END tr_sal_update; 

/
UPDATE EMPLOYEES SET SALARY = SALARY * 1.10;

