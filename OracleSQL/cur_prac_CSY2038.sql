SHOW SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE proc_imp_cursor(in_site_loc sites.location%TYPE) IS 
	

BEGIN
	DELETE FROM sites WHERE location = in_site_loc;
	IF SQL%FOUND THEN
		DBMS_OUTPUT.PUT_LINE(in_site_loc ||' DELETED');
	ELSE
		DBMS_OUTPUT.PUT_LINE('NO SUCH LOCATION');
	END IF;


END proc_imp_cursor;
/

SHOW ERRORS;

SELECT * FROM sites;
SELECT * FROM sites WHERE site_id=13;

INSERT INTO sites(site_id,location)
VALUES (13, 'NORTHAMPTON');

EXEC proc_imp_cursor('NORTHAMPTON');
EXEC proc_imp_cursor('NO PLACE');





CREATE OR REPLACE PROCEDURE proc_exp_cursor(in_course_cost courses.cost%TYPE) IS 

CURSOR cur_course IS
SELECT title, cost FROM courses WHERE cost>in_course_cost;

rec_cur_course cur_course%ROWTYPE;

vn_res_num NUMBER(5);

BEGIN


	FOR rec_cur_course   IN  cur_course   LOOP
	/* DBMS_OUTPUT.PUT_LINE('TITLE: ' || rec_cur_course.title || 'COST: ' || rec_cur_course.cost); */
	/* DBMS_OUTPUT.PUT_LINE(cur_course%ROWCOUNT); */
	vn_res_num := cur_course%ROWCOUNT;
	END LOOP;
	
	IF vn_res_num IS NULL THEN
		DBMS_OUTPUT.PUT_LINE('0');
	ELSE
		DBMS_OUTPUT.PUT_LINE(vn_res_num);
	END IF;
	
	
	
EXCEPTION

WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('0');

	
END proc_exp_cursor;
/

SHOW ERRORS;

EXEC proc_exp_cursor(1994);
EXEC proc_exp_cursor(20000);