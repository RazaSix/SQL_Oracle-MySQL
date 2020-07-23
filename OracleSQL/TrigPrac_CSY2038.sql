SET SERVEROUTPUT ON

CREATE OR REPLACE TRIGGER trig_dob_ck
BEFORE INSERT OR UPDATE OF date_of_birth ON students
FOR EACH ROW
WHEN (NEW.date_of_birth> SYSDATE)

BEGIN

	RAISE_APPLICATION_ERROR(-20000, 'ERROR - THIS STUDENT WAS BORN AFTER TODAY, AMEND STUDENT DATE OF BIRTH!');

END trig_dob_ck;
/

/* Test Trigger */
INSERT INTO students(student_id,student_firstname,student_surname,date_of_birth)
VALUES (103928,'JOHN','SMITH','09-JUN-2016');

DROP TRIGGER trig_dob_ck;

DELETE FROM students WHERE student_id = 103928;

CREATE OR REPLACE TRIGGER trig_dob_null_chk
BEFORE INSERT OR UPDATE OF date_of_birth ON students
FOR EACH ROW
WHEN (NEW.date_of_birth IS NOT NULL)

BEGIN
	
	IF(:NEW.date_of_birth > SYSDATE-(386*18))
		THEN DBMS_OUTPUT.PUT_LINE('date_of_birth is less than 18 years ago');
	ELSE 
		DBMS_OUTPUT.PUT_LINE('date_of_birth is more than 18 years ago');
	END IF;
END trig_dob_null_chk;
/ 

/* Test Trigger */
/* Less than 18 */
INSERT INTO students(student_id,student_firstname,student_surname,date_of_birth)
VALUES (103928,'JOHN','SMITH','24-FEB-1998');

DELETE FROM students WHERE student_id = 103928;

/* More than 18 */
INSERT INTO students(student_id,student_firstname,student_surname,date_of_birth)
VALUES (113928,'JOHN','SMITH','23-FEB-1988');

DELETE FROM students WHERE student_id = 113928;


/* BLOCKS INSERT OF AGE YOUNGER THAN 18 */
CREATE OR REPLACE TRIGGER trig_dob_null_chk
BEFORE INSERT OR UPDATE OF date_of_birth ON students
FOR EACH ROW
WHEN (NEW.date_of_birth IS NOT NULL)

BEGIN
	
	IF(:NEW.date_of_birth > SYSDATE-(386*18))
		THEN DBMS_OUTPUT.PUT_LINE('date_of_birth is less than 18 years ago');
		RAISE_APPLICATION_ERROR(-20000, 'ERROR - THIS STUDENT IS NOT YET 18, AMEND STUDENT DATE OF BIRTH!');
	ELSE 
		DBMS_OUTPUT.PUT_LINE('date_of_birth is more than 18 years ago');
		
	END IF;
END trig_dob_null_chk;
/ 