mysql> create database gov-exec-tracker;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '-exec-tracker' at line 1
mysql> create database govexectracker;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| airlines_db        |
| Fest_Database      |
| govexectracker     |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
7 rows in set (0.01 sec)

mysql> use govexectracker;
Database changed
mysql> CREATE TABLE department (
    ->     dept_id INT NOT NULL,
    ->     name VARCHAR(255) NOT NULL,
    ->     strength INT NOT NULL,
    ->     PRIMARY KEY (dept_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> CREATE TABLE projects (
    ->     project_id INT NOT NULL,
    ->     name VARCHAR(255) NOT NULL,
    ->     start_date DATE,
    ->     end_date DATE,
    ->     dept_id INT,
    ->     summary TEXT,
    ->     PRIMARY KEY (project_id),
    ->     FOREIGN KEY (dept_id) REFERENCES department(dept_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> CREATE TABLE contractors (
    ->     contractor_id INT NOT NULL,
    ->     name VARCHAR(255) NOT NULL,
    ->     bid_amount DECIMAL(10,2),
    ->     project_id INT,
    ->     PRIMARY KEY (contractor_id),
    ->     FOREIGN KEY (project_id) REFERENCES projects(project_id)
    -> );
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE TABLE government_employees (
    ->     govt_emp_id INT NOT NULL,
    ->     name VARCHAR(255),
    ->     gender VARCHAR(10),
    ->     dob DATE,
    ->     email VARCHAR(255),
    ->     phone_number VARCHAR(20),
    ->     proj_id INT,
    ->     dept_id INT,
    ->     manager VARCHAR(255),
    ->     PRIMARY KEY (govt_emp_id),
    ->     FOREIGN KEY (proj_id) REFERENCES projects(project_id),
    ->     FOREIGN KEY (dept_id) REFERENCES department(dept_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> CREATE TABLE login_info (
    ->     emp_id INT NOT NULL,
    ->     password VARCHAR(30),
    ->     PRIMARY KEY (emp_id),
    ->     FOREIGN KEY (emp_id) REFERENCES government_employees(govt_emp_id)
    -> );
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE TABLE project_costs (
    ->     project_id INT NOT NULL,
    ->     projected_cost DECIMAL(10,2),
    ->     actual_cost DECIMAL(10,2),
    ->     efficiency DECIMAL(10,2),
    ->     q1_cost DECIMAL(10,2),
    ->     q2_cost DECIMAL(10,2),
    ->     q3_cost DECIMAL(10,2),
    ->     q4_cost DECIMAL(10,2),
    ->     PRIMARY KEY (project_id),
    ->     FOREIGN KEY (project_id) REFERENCES projects(project_id)
    -> );
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE TABLE subtasks (
    ->     task_id INT NOT NULL,
    ->     name VARCHAR(255),
    ->     status VARCHAR(50),
    ->     start_date DATE,
    ->     end_date DATE,
    ->     project_id INT,
    ->     PRIMARY KEY (task_id),
    ->     FOREIGN KEY (project_id) REFERENCES projects(project_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> CREATE TABLE employee_attendance (
    ->     emp_id INT,
    ->     attendance_date DATE,
    ->     in_time TIME,
    ->     out_time TIME,
    ->     day_summary TEXT,
    ->     FOREIGN KEY (emp_id) REFERENCES government_employees(govt_emp_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> 
mysql> CREATE TABLE employee_attendance (
    ->     emp_id INT,
    ->     attendance_date DATE,
    ->     in_time TIME,
    ->     out_time TIME,
    ->     day_summary TEXT,
    ->     FOREIGN KEY (emp_id) REFERENCES government_employees(govt_emp_id)
    -> );
ERROR 1050 (42S01): Table 'employee_attendance' already exists
mysql> 
mysql> CREATE TABLE working_employees (
    ->     work_emp_id INT NOT NULL,
    ->     name VARCHAR(255),
    ->     gender VARCHAR(10),
    ->     dob DATE,
    ->     tasks VARCHAR(300),
    ->     project_id INT,
    ->     dept_id INT,
    ->     email VARCHAR(255),
    ->     phone_number VARCHAR(20),
    ->     PRIMARY KEY (work_emp_id),
    ->     FOREIGN KEY (project_id) REFERENCES projects(project_id),
    ->     FOREIGN KEY (dept_id) REFERENCES department(dept_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> CREATE TABLE tickets (
    ->     ticket_id INT NOT NULL,
    ->     title VARCHAR(255),
    ->     status VARCHAR(50),
    ->     date_raised DATE,
    ->     citizen_id INT,
    ->     project_id INT,
    ->     summary TEXT,
    ->     PRIMARY KEY (ticket_id),
    ->     FOREIGN KEY (project_id) REFERENCES projects(project_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> CREATE TABLE ticket_solutions (
    ->     solution_id INT NOT NULL,
    ->     summary TEXT NOT NULL,
    ->     report_id INT,
    ->     admin_id INT,
    ->     PRIMARY KEY (solution_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> CREATE TABLE web_admin_list (
    ->     admin_id INT NOT NULL,
    ->     name VARCHAR(255),
    ->     PRIMARY KEY (admin_id)
    -> );
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE TABLE web_citizen_list (
    ->     citizen_id INT NOT NULL,
    ->     name VARCHAR(255),
    ->     phone_number VARCHAR(10),
    ->     PRIMARY KEY (citizen_id)
    -> );
Query OK, 0 rows affected (0.00 sec)

mysql> INSERT INTO department VALUES
    -> (101, 'Roads & Transport', 55),
    -> (102, 'Water Supply', 40),
    -> (103, 'Electricity', 30),
    -> (104, 'Urban Development', 65),
    -> (105, 'Waste Management', 25),
    -> (106, 'Health & Sanitation', 50),
    -> (107, 'Education', 70),
    -> (108, 'Agriculture', 45),
    -> (109, 'Public Works', 80),
    -> (110, 'Environment', 35);
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO projects VALUES
    -> (201, 'Highway Expansion', '2024-01-01', '2025-06-30', 101, 'Expansion of NH45'),
    -> (202, 'New Water Pipeline', '2023-03-12', '2024-12-15', 102, 'Underground pipe installation'),
    -> (203, 'Solar Street Lights', '2022-10-01', '2023-09-14', 103, '1000 solar lights installed'),
    -> (204, 'Smart City CCTV', '2023-04-01', '2024-03-01', 104, 'City-wide surveillance network'),
    -> (205, 'Garbage Segregation Units', '2023-01-11', '2023-10-10', 105, 'At ward level'),
    -> (206, 'District Hospital Renovation', '2023-02-01', '2025-01-01', 106, 'New medical equipment, ICU'),
    -> (207, 'Govt School Digitization', '2023-05-01', '2024-05-10', 107, 'Smart classrooms in 50 schools'),
    -> (208, 'Organic Farming Training', '2022-04-02', '2023-11-20', 108, 'Farmer training program'),
    -> (209, 'New Flyover Construction', '2023-07-07', '2025-09-30', 101, 'Flyover at main junction'),
    -> (210, 'City Tree Plantation', '2022-08-01', '2023-06-01', 110, 'Planting 20,000 trees');
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO contractors VALUES
    -> (301, 'BuildRight Pvt Ltd', 25000000, 201),
    -> (302, 'WaterFlow Constructions', 18000000, 202),
    -> (303, 'GreenLight Tech', 9000000, 203),
    -> (304, 'SecureVision Ltd', 15000000, 204),
    -> (305, 'CleanWaste Ltd', 12000000, 205),
    -> (306, 'MediServe Pvt Ltd', 30000000, 206),
    -> (307, 'EduSmart Technologies', 8000000, 207),
    -> (308, 'AgroBoost Farms', 5000000, 208),
    -> (309, 'Skyline BuildCorp', 40000000, 209),
    -> (310, 'EcoPlant Services', 6000000, 210);
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO government_employees VALUES
    -> (401, 'Ramesh Kumar', 'Male', '1984-02-12', 'ramesh@gov.in', '9876543210', 201, 101, 'Yes'),
    -> (402, 'Priya Sharma', 'Female', '1990-08-20', 'priya@gov.in', '9898989898', 202, 102, 'No'),
    -> (403, 'Arvind Rao', 'Male', '1981-11-10', 'arvind@gov.in', '9123456780', 203, 103, 'Yes'),
    -> (404, 'Nandini Singh', 'Female', '1988-05-04', 'nandini@gov.in', '9988776655', 204, 104, 'No'),
    -> (405, 'Kapil Verma', 'Male', '1992-09-17', 'kapil@gov.in', '9234567890', 205, 105, 'No'),
    -> (406, 'Deepa Mahajan', 'Female', '1987-03-30', 'deepa@gov.in', '9556677889', 206, 106, 'Yes'),
    -> (407, 'Suresh Hegde', 'Male', '1980-01-25', 'suresh@gov.in', '9345678123', 207, 107, 'Yes'),
    -> (408, 'Sanjana Rao', 'Female', '1995-12-13', 'sanjana@gov.in', '9789789789', 208, 108, 'No'),
    -> (409, 'Rohit Mehta', 'Male', '1986-07-08', 'rohit@gov.in', '9001234567', 209, 101, 'Yes'),
    -> (410, 'Aisha Khan', 'Female', '1993-10-21', 'aisha@gov.in', '9112233445', 210, 110, 'No');
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO login_info VALUES
    -> (401, 'pw401'),
    -> (402, 'pw402'),
    -> (403, 'pw403'),
    -> (404, 'pw404'),
    -> (405, 'pw405'),
    -> (406, 'pw406'),
    -> (407, 'pw407'),
    -> (408, 'pw408'),
    -> (409, 'pw409'),
    -> (410, 'pw410');
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO project_costs VALUES
    -> (201, 25000000, 12000000, 48.0, 3000000, 3000000, 3000000, 3000000),
    -> (202, 18000000, 10000000, 55.5, 2500000, 2500000, 2500000, 2500000),
    -> (203, 9000000, 7000000, 77.7, 1750000, 1750000, 1750000, 1750000),
    -> (204, 15000000, 9000000, 60.0, 2250000, 2250000, 2250000, 2250000),
    -> (205, 12000000, 6000000, 50.0, 1500000, 1500000, 1500000, 1500000),
    -> (206, 30000000, 15000000, 50.0, 3750000, 3750000, 3750000, 3750000),
    -> (207, 8000000, 5000000, 62.5, 1250000, 1250000, 1250000, 1250000),
    -> (208, 5000000, 3000000, 60.0, 750000, 750000, 750000, 750000),
    -> (209, 40000000, 18000000, 45.0, 4500000, 4500000, 4500000, 4500000),
    -> (210, 6000000, 4500000, 75.0, 1125000, 1125000, 1125000, 1125000);
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO subtasks VALUES
    -> (501, 'Land Clearance', 'Completed', '2024-01-05', '2024-03-01', 201),
    -> (502, 'Pipeline Digging', 'In Progress', '2023-03-20', '2024-10-10', 202),
    -> (503, 'Pole Installation', 'Completed', '2022-10-10', '2023-01-20', 203),
    -> (504, 'Camera Setup', 'In Progress', '2023-06-01', '2024-02-20', 204),
    -> (505, 'Unit Assembly', 'Completed', '2023-02-01', '2023-05-01', 205),
    -> (506, 'ICU Setup', 'In Progress', '2023-04-01', '2024-12-01', 206),
    -> (507, 'Smart Boards', 'Completed', '2023-05-10', '2023-09-10', 207),
    -> (508, 'Farmer Training', 'In Progress', '2022-05-01', '2023-09-10', 208),
    -> (509, 'Foundation Work', 'In Progress', '2023-08-01', '2025-01-01', 209),
    -> (510, 'Nursery Planting', 'Completed', '2022-08-15', '2023-03-15', 210);
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO employee_attendance VALUES
    -> (401, '2024-05-01', '09:00:00', '17:00:00', 'On-site inspection'),
    -> (402, '2024-05-01', '09:15:00', '17:30:00', 'Pipe testing'),
    -> (403, '2024-05-01', '08:45:00', '17:00:00', 'Solar lamp installations'),
    -> (404, '2024-05-01', '09:20:00', '18:00:00', 'CCTV alignment'),
    -> (405, '2024-05-01', '09:00:00', '17:00:00', 'Unit inspection'),
    -> (406, '2024-05-01', '09:30:00', '17:45:00', 'Hospital work'),
    -> (407, '2024-05-01', '08:50:00', '17:10:00', 'School installations'),
    -> (408, '2024-05-01', '09:40:00', '17:50:00', 'Farmer training'),
    -> (409, '2024-05-01', '09:00:00', '18:00:00', 'Flyover visit'),
    -> (410, '2024-05-01', '09:10:00', '17:20:00', 'Tree plantation');
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO working_employees VALUES
    -> (601, 'Ramesh Kumar', 'Male', '1984-02-12', 'Survey Work', 201, 101, 'ramesh@gov.in', '9876543210'),
    -> (602, 'Priya Sharma', 'Female', '1990-08-20', 'Pipe Supervision', 202, 102, 'priya@gov.in', '9898989898'),
    -> (603, 'Arvind Rao', 'Male', '1981-11-10', 'Solar Poles', 203, 103, 'arvind@gov.in', '9123456780'),
    -> (604, 'Nandini Singh', 'Female', '1988-05-04', 'CCTV Testing', 204, 104, 'nandini@gov.in', '9988776655'),
    -> (605, 'Kapil Verma', 'Male', '1992-09-17', 'Garbage Unit Setup', 205, 105, 'kapil@gov.in', '9234567890'),
    -> (606, 'Deepa Mahajan', 'Female', '1987-03-30', 'Hospital Repair', 206, 106, 'deepa@gov.in', '9556677889'),
    -> (607, 'Suresh Hegde', 'Male', '1980-01-25', 'Smart Boards', 207, 107, 'suresh@gov.in', '9345678123'),
    -> (608, 'Sanjana Rao', 'Female', '1995-12-13', 'Farmer Coordination', 208, 108, 'sanjana@gov.in', '9789789789'),
    -> (609, 'Rohit Mehta', 'Male', '1986-07-08', 'Foundation Work', 209, 101, 'rohit@gov.in', '9001234567'),
    -> (610, 'Aisha Khan', 'Female', '1993-10-21', 'Tree Plantation', 210, 110, 'aisha@gov.in', '9112233445');
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO tickets VALUES
    -> (701, 'Road damage issue', 'Open', '2024-01-10', 1, 201, 'Cracks after excavation'),
    -> (702, 'Water pressure low', 'Resolved', '2024-02-11', 2, 202, 'Pipeline not sealed'),
    -> (703, 'Street lights not working', 'In Progress', '2024-01-20', 3, 203, 'Faulty wiring'),
    -> (704, 'Camera angle wrong', 'Open', '2024-03-15', 4, 204, 'Pole alignment issue'),
    -> (705, 'Garbage overflow', 'Open', '2024-02-22', 5, 205, 'Bins damaged'),
    -> (706, 'Hospital dust issue', 'Resolved', '2024-01-15', 6, 206, 'Workers not covering area'),
    -> (707, 'School projector not working', 'In Progress', '2024-03-20', 7, 207, 'Loose connections'),
    -> (708, 'Farmer meeting delayed', 'Closed', '2024-02-01', 8, 208, 'Weather issue'),
    -> (709, 'Flyover blocking footpath', 'Open', '2024-03-05', 9, 209, 'Temporary barricades'),
    -> (710, 'Saplings not watered', 'Open', '2024-01-18', 10, 210, 'Municipal negligence');
Query OK, 10 rows affected (0.01 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO ticket_solutions VALUES
    -> (801, 'Fixed road crack', 701, 1),
    -> (802, 'Pipe sealing done', 702, 1),
    -> (803, 'Replaced wiring', 703, 2),
    -> (804, 'Camera realigned', 704, 2),
    -> (805, 'Damaged bins replaced', 705, 3),
    -> (806, 'Dust sheets installed', 706, 3),
    -> (807, 'Projector replaced', 707, 4),
    -> (808, 'Meeting rescheduled', 708, 4),
    -> (809, 'Barricade rearranged', 709, 5),
    -> (810, 'Watering assigned daily', 710, 5);
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO web_admin_list VALUES
    -> (1, 'Administrator A'),
    -> (2, 'Administrator B'),
    -> (3, 'Administrator C'),
    -> (4, 'Administrator D'),
    -> (5, 'Administrator E'),
    -> (6, 'Administrator F'),
    -> (7, 'Administrator G'),
    -> (8, 'Administrator H'),
    -> (9, 'Administrator I'),
    -> (10, 'Administrator J');
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> INSERT INTO web_citizen_list VALUES
    -> (1, 'Rajesh', '9876543210'),
    -> (2, 'Meena', '9876501234'),
    -> (3, 'Dinesh', '9845098450'),
    -> (4, 'Kavita', '9009009009'),
    -> (5, 'Amit', '9988776655'),
    -> (6, 'Sunil', '9123456789'),
    -> (7, 'Latha', '9811112222'),
    -> (8, 'Imran', '9090909090'),
    -> (9, 'Shreya', '9877776666'),
    -> (10, 'Chris', '9999999999');
Query OK, 10 rows affected (0.00 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> show users
    -> ;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'users' at line 1
mysql> select * from projects;
+------------+------------------------------+------------+------------+---------+--------------------------------+
| project_id | name                         | start_date | end_date   | dept_id | summary                        |
+------------+------------------------------+------------+------------+---------+--------------------------------+
|        201 | Highway Expansion            | 2024-01-01 | 2025-06-30 |     107 | Expansion of NH45              |
|        202 | New Water Pipeline           | 2023-03-12 | 2024-12-15 |     102 | Underground pipe installation  |
|        203 | Solar Street Lights          | 2022-10-01 | 2023-09-14 |     103 | 1000 solar lights installed    |
|        204 | Smart City CCTV              | 2023-04-01 | 2024-03-01 |     104 | City-wide surveillance network |
|        205 | Garbage Segregation Units    | 2023-01-11 | 2023-10-10 |     105 | At ward level                  |
|        206 | District Hospital Renovation | 2023-02-01 | 2025-01-01 |     106 | New medical equipment, ICU     |
|        207 | Govt School Digitization     | 2023-05-01 | 2024-05-10 |     107 | Smart classrooms in 50 schools |
|        208 | Organic Farming Training     | 2022-04-02 | 2023-11-20 |     108 | Farmer training program        |
|        209 | New Flyover Construction     | 2023-07-07 | 2025-09-30 |     101 | Flyover at main junction       |
|        210 | City Tree Plantation         | 2022-08-01 | 2023-06-01 |     110 | Planting 20,000 trees          |
+------------+------------------------------+------------+------------+---------+--------------------------------+
10 rows in set (0.00 sec)

mysql> CREATE USER 'app_admin'@'localhost' IDENTIFIED BY 'StrongPassword1';
Query OK, 0 rows affected (0.01 sec)

mysql> CREATE USER 'data_entry_user'@'localhost' IDENTIFIED BY 'EntryPass1';
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE USER 'viewer_user'@'localhost' IDENTIFIED BY 'ViewOnly1';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON dbmsmini.* TO 'app_admin'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON govexectracker TO 'app_admin'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT SELECT, INSERT, UPDATE PRIVILEGES ON govexectracker TO 'data_entry_user'@'localhost';
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'PRIVILEGES ON govexectracker TO 'data_entry_user'@'localhost'' at line 1
mysql> GRANT SELECT, INSERT, UPDATE ON govexectracker TO 'data_entry_user'@'localhost';
ERROR 1146 (42S02): Table 'govexectracker.govexectracker' doesn't exist
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| airlines_db        |
| Fest_Database      |
| govexectracker     |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
7 rows in set (0.00 sec)

mysql> GRANT SELECT, INSERT, UPDATE ON govexectracker.* TO 'data_entry_user'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT SELECT ON govexectracker.* TO 'viewer_user'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

mysql> mysql -u viewer_user -p
    -> ;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'mysql -u viewer_user -p' at line 1
mysql> notee
