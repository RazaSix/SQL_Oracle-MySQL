SET SERVEROUTPUT ON


/* FUNCTION */
CREATE OR REPLACE FUNCTION func_username(in_reviewer_firstname reviewers.reviewer_firstname%TYPE, in_reviewer_surname reviewers.reviewer_surname%TYPE)
RETURN VARCHAR2 IS

	vc_reviewer_username reviewers.reviewer_username%TYPE;

BEGIN
	vc_reviewer_username := CONCAT(SUBSTR(in_reviewer_firstname,1,2),SUBSTR(in_reviewer_surname,1,5));
	
RETURN vc_reviewer_username;
	
END func_username;
/

SHOW ERRORS;


DROP FUNCTION func_username;

/* PROCEDURE */
CREATE OR REPLACE PROCEDURE proc_username_func(in_reviewer_id reviewers.reviewer_id%TYPE, in_reviewer_firstname reviewers.reviewer_firstname%TYPE, in_reviewer_surname reviewers.reviewer_surname%TYPE) IS 
	vc_rev_username reviewers.reviewer_username%TYPE;


BEGIN
	vc_rev_username := func_username(in_reviewer_firstname,in_reviewer_surname);
	
	/*
	UPDATE reviewers
	SET reviewer_username=vc_rev_username
	WHERE reviewer_id=in_reviewer_id;
	*/
	DBMS_OUTPUT.PUT_LINE ('Username is ' || vc_rev_username );
	DBMS_OUTPUT.PUT_LINE ('(PROC)Passed in id is ' || in_reviewer_id );


END proc_username_func;
/

SHOW ERRORS;

/* EXEC proc_username_func(1000); */
EXEC proc_username_func(100186, 'AAAAA', 'BBBBB');
DROP PROCEDURE proc_username_func;

/* TRIGGER */
CREATE OR REPLACE TRIGGER trig_add_username
BEFORE INSERT ON reviewers
FOR EACH ROW


DECLARE
	
BEGIN
	
	DBMS_OUTPUT.PUT_LINE ('(TRIG)New id is ' || :NEW.reviewer_id );
	DBMS_OUTPUT.PUT_LINE ('(TRIG)New fname is ' || :NEW.reviewer_firstname );
	DBMS_OUTPUT.PUT_LINE ('(TRIG)New sname is ' || :NEW.reviewer_surname );
	
	 proc_username_func(:NEW.reviewer_id, :NEW.reviewer_firstname, :NEW.reviewer_surname);
	 :NEW.reviewer_username:=func_username(:NEW.reviewer_firstname,:NEW.reviewer_surname);
	
END trig_add_username;
/
SHOW ERRORS;

DROP TRIGGER trig_add_username;

/* http://stackoverflow.com/questions/8474674/mutating-error-on-after-insert-trigger */

/* TEST INSERT TRIGGER */
INSERT INTO reviewers(reviewer_id,reviewer_firstname,reviewer_surname)
VALUES (seq_reviewer_id.NEXTVAL, 'AAAAA', 'BBBBBBB');

SELECT * FROM reviewers;

SELECT reviewer_id ID, reviewer_firstname, reviewer_surname, reviewer_username FROM reviewers;

DELETE FROM reviewers WHERE reviewer_id = 100225;




/* -------------------------------------------------------------------- */
/* -------------------------------------------------------------------- */
/* -------------------------------------------------------------------- */

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



/* FUNCTION TO CREATE USERNAME */
CREATE OR REPLACE FUNCTION func_username(in_staff_id staff.staff_id%TYPE)
RETURN VARCHAR2 IS

	vc_staff_username VARCHAR(7);

BEGIN
	SELECT CONCAT(SUBSTR(firstname,1,2),SUBSTR(surname,1,5))
	INTO vc_staff_username
	FROM staff
	WHERE staff_id = in_staff_id;
	
RETURN vc_staff_username;
	
END func_username;
/


/* PROCEDURE TO CALL FUNCTION */
CREATE OR REPLACE PROCEDURE proc_username_func(in_staff_id staff.staff_id%TYPE) IS 
	vc_username VARCHAR2(7);


BEGIN
	vc_username := func_username(in_staff_id);
	DBMS_OUTPUT.PUT_LINE ('Username is ' || vc_username );

END proc_username_func;
/

EXEC proc_username_func(1000);



