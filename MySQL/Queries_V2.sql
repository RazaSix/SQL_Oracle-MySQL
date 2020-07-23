/* Queries */

/* 1 */
•The names and the telephone numbers of the managers of each office; 

SELECT s.first_name, s.last_name, s.contact_number, o.office_name
FROM Staff s
JOIN Office_Staff os
ON s.staff_id = os.staff_id
JOIN Office o
ON os.office_id = o.office_id
WHERE s.role_id = 103;
--DONE


/* 2 */
•The names of all female instructors based in the selected office;
-- Solution is start join from role table

SELECT s.first_name, s.last_name, r.role_title /* , o.office_name */
FROM Role r
JOIN Staff s
ON r.role_id = s.role_id
JOIN Office_Staff os
ON s.staff_id = os.staff_id
JOIN Office o
ON os.office_id = o.office_id
WHERE s.gender = 'F' AND o.office_id = 150001 AND s.role_id != 104;
--DONE


/* 3 */
•The total number of staffs at each office;

SELECT o.Office_Name, count(s.staff_id)
FROM Role r
JOIN Staff s
ON r.role_id = s.role_id
JOIN Office_Staff os
ON s.staff_id = os.staff_id
JOIN Office o
ON os.office_id = o.office_id
GROUP BY o.Office_Name;
--DONE


/* 4 */
•The timetable of appointments for a given instructor next week;

SELECT s.Staff_ID, bl.Booked_Lesson_ID, c.Date, c.Time, c.Driving_Test
FROM Staff s
JOIN Booked_Lesson bl
ON s.staff_id = bl.staff_id
JOIN Calendar c
ON bl.booked_lesson_id = c.booked_lesson_id
WHERE s.Staff_ID = 1100002 AND
c.Date BETWEEN '2016-09-11' AND '2016-09-19';
--DONE

/* 5 */
•The details of interviews conducted by a given instructor;
-- With Staff Names
SELECT i.provisional, i.additional_notes, i.client_id, i.date, 
i.instructor_staff_id, s.first_name, s.last_name
FROM interview i
JOIN staff s
ON i.instructor_staff_id = s.staff_id
WHERE Instructor_Staff_ID = 1100002;

--DONE

/* 6 */
•The name and telephone number of the staff(s) who are 
	instructors and over 55 years old;
	
SELECT * FROM Staff WHERE Role_ID = 101 AND YEAR(DOB) < 1961;

SELECT first_name,last_name, contact_number, dob
FROM Staff WHERE Role_ID = 101 AND YEAR(DOB) < 1961;


--DONE

/* 7 */
•The registration of cars that have had no faults found;

SELECT Car_Registration FROM Car_Inspection WHERE Result = 'PASS';
--DONE

/* 8 */
•The names of clients who passed the driving test in a 
	particular month (e.g., in January 2008);

SELECT c.Client_ID, c.First_Name, c.Last_Name, d.Driving_Test_ID, d.Result
FROM driving_test d
JOIN calendar ca
ON d.calendar_id = ca.calendar_id
JOIN booked_lesson bl
ON ca.booked_lesson_id = bl.booked_lesson_id
JOIN client c
ON bl.client_ID = c.client_ID
WHERE YEAR(ca.Date) = 2016 AND MONTH(ca.Date) = 06;
--DONE



/* 9 */
•The names of clients who have sat the driving test 
	more than three times and have still not passed;

SELECT c.Client_ID, c.First_Name, c.Last_Name, ca.Calendar_ID, bl.Booked_Lesson_ID, COUNT(bl.booked_lesson_id) AS Test_Attempt
FROM driving_test d
JOIN calendar ca
ON d.calendar_id = ca.calendar_id
JOIN booked_lesson bl
ON ca.booked_lesson_id = bl.booked_lesson_id
JOIN client c
ON bl.client_ID = c.client_ID
WHERE ca.Lesson_ID = 1216 AND d.Result = 'FAIL'
GROUP BY bl.booked_lesson_id
HAVING Test_Attempt > 3;


/* 10 */
•The average number of miles driven during a one-hour lesson;
-- Lessons are booked per one hour slots. E.g. 2 hour lesson is booked as two 1 hour lessons
SELECT AVG(Mileage_Used)
FROM Client_Progress;
