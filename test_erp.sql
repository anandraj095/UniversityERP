-- ========================================
-- University ERP Test Script
-- ========================================

-- 1️⃣ Use Databases
USE auth_db;

-- 2️⃣ Check Auth Users
SELECT user_id, username, role, status FROM users_auth;

-- 3️⃣ Use ERP DB
USE erp_db;

-- 4️⃣ View Courses (Catalog)
SELECT sec.section_id, c.code, c.title, c.credits, sec.capacity, i.name AS instructor
FROM courses c
JOIN sections sec ON c.course_id = sec.course_id
JOIN instructors i ON sec.instructor_id = i.user_id;

-- 5️⃣ Student Flow
-- Check if stu1 is enrolled in section 1
SELECT * FROM enrollments WHERE student_id = 3 AND section_id = 1;

-- Register stu1 in section 1 (only if not enrolled)
INSERT IGNORE INTO enrollments (student_id, section_id)
VALUES (3, 1);

-- View student timetable / registrations
SELECT e.student_id, c.code, c.title, sec.day_time, sec.room, e.status
FROM enrollments e
JOIN sections sec ON e.section_id = sec.section_id
JOIN courses c ON sec.course_id = c.course_id
WHERE e.student_id = 3;

-- Drop section (simulate drop)
UPDATE enrollments
SET status = 'dropped'
WHERE student_id = 3 AND section_id = 1;

-- View timetable after drop
SELECT e.student_id, c.code, c.title, sec.day_time, sec.room, e.status
FROM enrollments e
JOIN sections sec ON e.section_id = sec.section_id
JOIN courses c ON sec.course_id = c.course_id
WHERE e.student_id = 3;

-- 6️⃣ Instructor Flow
-- View sections assigned to Prof. Smith (user_id = 2)
SELECT sec.section_id, c.code, c.title, sec.day_time, sec.room
FROM sections sec
JOIN courses c ON sec.course_id = c.course_id
WHERE sec.instructor_id = 2;

-- Add grades for stu1 enrollment
INSERT INTO grades (enrollment_id, component, score)
VALUES (1, 'midterm', 85),
       (1, 'final', 90);

-- Compute final grade (simple sum / placeholder)
UPDATE grades
SET final_grade = score
WHERE enrollment_id = 1;

-- View grades for stu1
SELECT e.student_id, c.code, c.title, g.component, g.score, g.final_grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN sections s ON e.section_id = s.section_id
JOIN courses c ON s.course_id = c.course_id
WHERE e.student_id = 3;

-- 7️⃣ Admin Flow
-- Add a new student (stu3)
INSERT INTO auth_db.users_auth (username, role, password_hash)
VALUES ('stu3','student','<bcrypt_hash>');

-- Add stu3 profile in ERP DB
INSERT INTO students (user_id, roll_no, name, program, year)
VALUES (5,'S103','Charlie','CS',1);

-- Create new course CS102 and section
INSERT INTO courses (code, title, credits)
VALUES ('CS102','Data Structures',4);

INSERT INTO sections (course_id, instructor_id, day_time, room, capacity, semester, year)
VALUES (2, 2, 'Wed 14:00-16:00','R102',25,'Fall',2025);

-- Toggle Maintenance Mode ON
INSERT INTO settings (`key`,`value`)
VALUES ('maintenance_on','true')
ON DUPLICATE KEY UPDATE `value`='true';

-- Check maintenance flag
SELECT * FROM settings;

-- 8️⃣ Edge & Integrity Tests
-- Attempt duplicate enrollment (should fail)
INSERT IGNORE INTO enrollments (student_id, section_id)
VALUES (3, 1);

-- Attempt negative capacity (should fail)
INSERT INTO sections (course_id, instructor_id, day_time, room, capacity, semester, year)
VALUES (2, 2, 'Fri 10:00-12:00','R103',-5,'Fall',2025);

-- 9️⃣ Export Simulation (Transcript for stu1)
SELECT c.code, c.title, g.component, g.score, g.final_grade
FROM grades g
JOIN enrollments e ON g.enrollment_id = e.enrollment_id
JOIN sections s ON e.section_id = s.section_id
JOIN courses c ON s.course_id = c.course_id
WHERE e.student_id = 3;

-- ========================================
-- End of Test Script
-- ========================================
