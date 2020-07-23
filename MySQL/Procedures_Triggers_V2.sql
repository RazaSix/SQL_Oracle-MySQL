/* Calculate price of total lessons booked
	- Trigger on booked_lesson insert
	- multiply price by number of lessons
	Inserted into booked lesson total_price column
	
	Block Insert of Clients with no provisional licence
	(BOOKED LESSON)
*/

DROP TRIGGER trig_prov_check;

DELIMITER $$
CREATE TRIGGER trig_prov_check
BEFORE INSERT ON Booked_Lesson
FOR EACH ROW

BEGIN
	SET @PROV = (SELECT provisional FROM Interview WHERE Client_ID = NEW.client_id);
	
	IF(@PROV = 'N') THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Client Needs Provisional Licence';
	ELSE
		SET NEW.total_price = NEW.amount_booked* 12.99;
	END IF;

	
END$$
DELIMITER ;

-- TEST
-- Will be blocked (Provisional is N)
INSERT INTO `db14438658`.`Booked_Lesson`
(`Amount_Booked`,
`Client_ID`,
`Staff_ID`)
VALUES
(15,
121002,
1100002);

-- Will work. (Provisional is Y)
INSERT INTO `db14438658`.`Booked_Lesson`
(`Amount_Booked`,
`Client_ID`,
`Staff_ID`)
VALUES
(15,
121003,
1100002);


/* 
Procedure to find client lesson history
By inputting Client_ID
*/
DELIMITER //
CREATE PROCEDURE proc_client_history (
IN in_client_id INT)
	
BEGIN
	
	SELECT cl.Client_ID, cl.First_Name, cl.Last_Name, cp.Mileage_Used, cp.Progress_Notes
	FROM Client_Progress cp
	JOIN Calendar c
	ON c.calendar_id = cp.calendar_lesson_id
	JOIN Booked_Lesson bl
	ON bl.booked_lesson_id = c.booked_lesson_id
	JOIN Client cl
	ON  cl.client_id = bl.client_id
	WHERE cl.client_id = in_client_id;
	

END //
DELIMITER ;


-- TEST
CALL proc_client_history(121003);




/* Procedure to find how many lessons left from client id */

DROP PROCEDURE proc_calc_lessons_left;

DELIMITER //
CREATE PROCEDURE proc_calc_lessons_left (
IN in_client_id INT)
	
BEGIN
	
	SELECT cl.First_Name, cl.Last_Name, MIN(c.Lessons_Left)
	FROM Calendar c
	JOIN Booked_Lesson bl
	ON c.booked_lesson_id = bl.booked_lesson_id
	JOIN Client cl
	ON  cl.client_id = bl.client_id
	WHERE cl.client_id = in_client_id;
	

END //
DELIMITER ;


-- TEST
CALL proc_calc_lessons_left(121008);



/* Procedure to find clients of an instructor */
DELIMITER //
CREATE PROCEDURE proc_find_client (
IN in_instructor_id INT)
	
BEGIN
	
	SELECT c.Client_ID, c.First_Name, c.Last_Name
	FROM Client c
	JOIN Booked_Lesson bl
	ON c.Client_ID = bl.Client_ID
	JOIN Staff s
	ON bl.Staff_ID = s.Staff_ID
	WHERE bl.Staff_ID = in_instructor_id;
	

END //
DELIMITER ;

-- TEST
CALL proc_find_instructor(1100002);



/* Procedure to find instructor of a client */
DELIMITER //
CREATE PROCEDURE proc_find_instructor (
IN in_instructor_id INT)
	
BEGIN
	
	SELECT s.Staff_ID, s.First_Name, s.Last_Name
	FROM Staff s
	JOIN Booked_Lesson bl
	ON s.Staff_ID = bl.Staff_ID
	JOIN Client c
	ON bl.Client_ID = c.Client_ID
	WHERE bl.Client_ID = in_instructor_id;
	

END //
DELIMITER ;


-- TEST
CALL proc_find_client(121013);

/* Trigger to calculate lessons left on insert into calendar
(CALENDAR)
*/

/* DOES NOT ACCOUNT FOR 1st TIME BOOKINGS 
DROP TRIGGER trig_lessons_left;

DELIMITER $$
CREATE TRIGGER trig_lessons_left
BEFORE INSERT ON calendar
FOR EACH ROW

BEGIN
	CALL proc_calc_lessons_left(NEW.booked_lesson_id, @outa);
	SET NEW.Lessons_Left = @outa;
	

END$$
DELIMITER ;
*/


/* DOES NOT WORK CALLING THE PROCEDURE
DELIMITER $$
CREATE TRIGGER trig_lessons_left
BEFORE INSERT ON calendar
FOR EACH ROW

BEGIN

	IF(NEW.booked_lesson_id < 1) THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Out of Booked Lessons';
	ELSE
		CALL proc_calc_lessons_left(NEW.booked_lesson_id, @outa);
		SET NEW.Lessons_Left = @outa;
	END IF;
	

END$$
DELIMITER ;
*/

DROP TRIGGER trig_lessons_left;

DELIMITER $$
CREATE TRIGGER trig_lessons_left
BEFORE INSERT ON calendar
FOR EACH ROW


BEGIN

DECLARE i_num_left INT;
DECLARE i_num_first_booking INT;


		SELECT MIN(c.Lessons_Left) INTO i_num_left 
		FROM calendar c
		JOIN booked_lesson bl
		ON c.booked_lesson_id = bl.booked_lesson_id
		JOIN client cl
		ON  cl.client_id = bl.client_id
		WHERE cl.client_id = NEW.booked_lesson_id;


		SELECT amount_booked INTO i_num_first_booking 
		FROM booked_lesson bl
		JOIN client cl
		ON  bl.client_id = cl.client_id
		WHERE bl.booked_lesson_id = NEW.booked_lesson_id;

	IF(i_num_left < 1 AND i_num_first_booking < 1 OR i_num_first_booking IS NULL OR i_num_left IS NULL) THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Out of Booked Lessons';
	
	ELSEIF (i_num_left < 1 OR i_num_left IS NULL AND i_num_first_booking > 0 OR i_num_first_booking IS NOT NULL) THEN 
		SET NEW.Lessons_Left = i_num_first_booking - 1;
	
	ELSEIF (i_num_left > 0 AND i_num_first_booking > 0) THEN 
		SET NEW.Lessons_Left = i_num_left-1;

	
	END IF;
	

END$$
DELIMITER ;


-- TEST
INSERT INTO `db14438658`.`Calendar` (`Date`, `Time`, `Booked_Lesson_ID`, `Lesson_ID`, `Driving_Test`)
VALUES ('2016-06-30', '10:00:00', '181120', '1213', 'N');