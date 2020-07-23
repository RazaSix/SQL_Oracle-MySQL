SET SERVEROUTPUT ON

DROP TABLE staff;

CREATE TABLE staff(
staff_id NUMBER(6),
firstname VARCHAR2(15), 
surname VARCHAR2(15), 
username VARCHAR2(10),
role VARCHAR2(10),
date_of_birth DATE);



/* TRIGGER */
CREATE OR REPLACE TRIGGER trig_show_age
AFTER INSERT OR UPDATE OR DELETE OF date_of_birth ON staff
FOR EACH ROW


DECLARE 
	 vd_dob  DATE;
	 vn_age  NUMBER(3);
	 vn_retire NUMBER(3);

	 
BEGIN
	vn_age:= func_calc_age(:NEW.date_of_birth);
	
	
	IF INSERTING THEN
		DBMS_OUTPUT.PUT_LINE (:NEW.surname || 'age is: ' || vn_age);
	
	ELSIF UPDATING THEN
		vn_retire:= func_time_retire(vn_age);
		DBMS_OUTPUT.PUT_LINE ('Member has ' || vn_retire || 'years left till retire');
	
	ELSIF DELETING THEN
		DBMS_OUTPUT.PUT_LINE ('You''re deleting ' || :OLD.surname );
	END IF;
	
	
END trig_show_age;
/


SHOW ERRORS;



/* FUNCTION TO CALC AGE */
CREATE OR REPLACE FUNCTION func_calc_age(in_dob DATE)
RETURN NUMBER IS
	vn_staff_age NUMBER(3);

BEGIN
	vn_staff_age:= FLOOR(MONTHS_BETWEEN(sysdate,to_date(in_dob))/12);
	
RETURN vn_staff_age;
	
END func_calc_age;
/

SHOW ERRORS;

/* FUNCTION TO CALC RETIREMENT AGE */
CREATE OR REPLACE FUNCTION func_time_retire(in_age NUMBER)
RETURN NUMBER IS
	vn_retire_time NUMBER(3);


BEGIN
	vn_retire_time:= in_age-67;
	
	
RETURN vn_retire_time;
	
END func_time_retire;
/

SHOW ERRORS;



CREATE OR REPLACE PROCEDURE proc_show_retire (in_staff_id NUMBER) IS 
	vn_time_to_retire NUMBER(3);
	vd_dob DATE;
	vn_age NUMBER(3);


BEGIN
	SELECT date_of_birth
	INTO vd_dob
	FROM staff
	WHERE staff_id = in_staff_id;
	
	vn_age:= func_calc_age(vd_dob);
	vn_time_to_retire := func_time_retire(vn_age);
	DBMS_OUTPUT.PUT_LINE ('Time to retire is ' || vn_time_to_retire || 'years');

END proc_show_retire;
/

SHOW ERRORS;





/* Test Insert predicate in Trigger */
INSERT INTO staff VALUES (1000, 'ALISON','APPLE', NULL, 'HEAD','01-JAN-1965');
INSERT INTO staff VALUES (1001, 'BERTY','BANANA', 'BBANA', 'WORKER BEE','02-MAR-1989');
INSERT INTO staff VALUES (1002, 'CANDY','CANE', NULL,'CONTROL','12-JUN-1980');

/* Test Update predicate in Trigger */
INSERT INTO staff VALUES (1003, 'JOE','WEST', NULL,'CONTROL','02-DEC-1989');
UPDATE staff
SET date_of_birth='01-DEC-1994'
WHERE staff_id=1003;

/* Test find retire age with staff_id procdedure */
EXEC proc_show_retire (1003);

/* Test deleting predicate in trigger */
DELETE FROM staff WHERE staff_id = 1003;




------------------------------------------------------------------
--Bonus

/* EDITING FUNCTIONS TO INCLUDE EXTRA PARAMETER */
/* Time to retire, specify retirement age */

CREATE OR REPLACE FUNCTION func_choose_time_retire(in_age NUMBER, in_retire NUMBER)
RETURN NUMBER IS
	vn_retire_time NUMBER(3);


BEGIN
	vn_retire_time:= in_age-in_retire;
	
	
RETURN vn_retire_time;
	
END func_choose_time_retire;
/

SHOW ERRORS;


CREATE OR REPLACE PROCEDURE proc_show_retire (in_staff_id NUMBER, in_retire_age NUMBER) IS 
	vn_time_to_retire NUMBER(3);
	vd_dob DATE;
	vn_age NUMBER(3);


BEGIN
	SELECT date_of_birth
	INTO vd_dob
	FROM staff
	WHERE staff_id = in_staff_id;
	
	vn_age:= func_calc_age(vd_dob);
	vn_time_to_retire := func_choose_time_retire(vn_age, in_retire_age);
	DBMS_OUTPUT.PUT_LINE ('Time to retire is ' || vn_time_to_retire || 'years');

END proc_show_retire;
/

SHOW ERRORS;

/* Test choosing retirement age */
EXEC proc_show_retire(1001, 45);



DROP TRIGGER trig_show_age;