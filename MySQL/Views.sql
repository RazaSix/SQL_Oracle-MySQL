/* Views */

-- Staff, roles and their offices
CREATE VIEW Staff_Offices
AS
SELECT s.first_name, s.last_name, r.role_title, o.office_name
FROM office o
JOIN office_staff os
ON os.office_id = o.office_id
JOIN staff s
ON s.staff_id = os.staff_id
JOIN role r
ON r.role_id = s.role_id
ORDER BY o.office_name;


CREATE VIEW Office_Managers
AS
SELECT s.first_name, s.last_name, r.role_title, o.office_name
FROM office o
JOIN office_staff os
ON os.office_id = o.office_id
JOIN staff s
ON s.staff_id = os.staff_id
JOIN role r
ON r.role_id = s.role_id
WHERE r.role_title = 'MANAGER';


-- Client booked lessons and Instructors
CREATE VIEW Client_Booked_Lessons
AS
SELECT c.Client_ID, c.First_Name, c.Last_Name, bl.Amount_Booked, 
s.Staff_ID, s.First_Name InstructorF, s.Last_Name  InstructorS
FROM client c
JOIN booked_lesson bl
ON c.client_id = bl.client_id
JOIN staff s
ON s.staff_id = bl.staff_id;



-- Car info and inspection history
CREATE VIEW Car_Inspection_History
AS
SELECT ca.Car_Registration, ca.Make, ca.Model, ca.Year, ci.Date Inspection_Date, 
ci.Result, ci.Notes
FROM car_inspection ci
JOIN cars ca
ON ci.car_registration = ca.car_registration
ORDER BY ca.car_registration;

-- Car info and allocation history
CREATE VIEW Car_Allocation_History
AS
SELECT c.Car_Registration, c.Make, c.Model, c.Year, ca.Date_Allocated, ca.Date_returned
FROM cars c
JOIN car_allocation ca
ON c.car_registration = ca.car_registration;