
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


DELIMITER $$
CREATE TRIGGER trig_lessons_left
BEFORE INSERT ON Calendar
FOR EACH ROW


BEGIN

DECLARE i_num_left INT;
DECLARE i_num_first_booking INT;


		SELECT MIN(c.Lessons_Left) INTO i_num_left 
		FROM Calendar c
		JOIN Booked_Lesson bl
		ON c.booked_lesson_id = bl.booked_lesson_id
		JOIN Client cl
		ON  cl.client_id = bl.client_id
		WHERE cl.client_id = NEW.booked_lesson_id;


		SELECT amount_booked INTO i_num_first_booking 
		FROM Booked_Lesson bl
		JOIN Client cl
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








