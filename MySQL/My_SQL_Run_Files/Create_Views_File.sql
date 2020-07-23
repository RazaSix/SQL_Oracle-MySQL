
CREATE VIEW Staff_Offices
AS
SELECT s.first_name, s.last_name, r.role_title, o.office_name
FROM Office o
JOIN Office_Staff os
ON os.office_id = o.office_id
JOIN Staff s
ON s.staff_id = os.staff_id
JOIN Role r
ON r.role_id = s.role_id
ORDER BY o.office_name;


CREATE VIEW Office_Managers
AS
SELECT s.first_name, s.last_name, r.role_title, o.office_name
FROM Office o
JOIN Office_Staff os
ON os.office_id = o.office_id
JOIN Staff s
ON s.staff_id = os.staff_id
JOIN Role r
ON r.role_id = s.role_id
WHERE r.role_title = 'MANAGER';


CREATE VIEW Client_Booked_Lessons
AS
SELECT c.Client_ID, c.First_Name, c.Last_Name, bl.Amount_Booked, 
s.Staff_ID, s.First_Name InstructorF, s.Last_Name  InstructorS
FROM Client c
JOIN Booked_Lesson bl
ON c.client_id = bl.client_id
JOIN Staff s
ON s.staff_id = bl.staff_id;


CREATE VIEW Car_Inspection_History
AS
SELECT ca.Car_Registration, ca.Make, ca.Model, ca.Year, ci.Date Inspection_Date, 
ci.Result, ci.Notes
FROM Car_Inspection ci
JOIN Cars ca
ON ci.car_registration = ca.car_registration
ORDER BY ca.car_registration;


CREATE VIEW Car_Allocation_History
AS
SELECT c.Car_Registration, c.Make, c.Model, c.Year, s.staff_id, s.first_name, s.last_name, ca.Date_Allocated, ca.Date_returned
FROM Cars c
JOIN Car_Allocation ca
ON c.car_registration = ca.car_registration
JOIN Staff s
ON ca.staff_id = s.staff_id;
