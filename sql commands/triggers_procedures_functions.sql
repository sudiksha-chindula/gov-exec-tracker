mysql> use govexectracker;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> DELIMITER $$
mysql> 
mysql> CREATE TRIGGER trig_calc_efficiency_before_insert
    -> BEFORE INSERT ON project_costs
    -> FOR EACH ROW
    -> BEGIN
    ->     IF NEW.projected_cost IS NOT NULL AND NEW.actual_cost IS NOT NULL THEN
    ->         SET NEW.efficiency = ((NEW.projected_cost - NEW.actual_cost) / NEW.projected_cost) * 100;
    ->     ELSE
    ->         SET NEW.efficiency = NULL;
    ->     END IF;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> DELIMITER $$
mysql> 
mysql> CREATE TRIGGER trig_calc_efficiency_before_update
    -> BEFORE UPDATE ON project_costs
    -> FOR EACH ROW
    -> BEGIN
    ->     IF NEW.projected_cost IS NOT NULL AND NEW.actual_cost IS NOT NULL THEN
    ->         SET NEW.efficiency = ((NEW.projected_cost - NEW.actual_cost) / NEW.projected_cost) * 100;
    ->     ELSE
    ->         SET NEW.efficiency = NULL;
    ->     END IF;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> INSERT INTO project_costs (project_id, projected_cost, actual_cost)
    -> VALUES (301, 100000, 75000);
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`govexectracker`.`project_costs`, CONSTRAINT `project_costs_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`))
mysql> INSERT INTO project_costs (project_id, projected_cost, actual_cost)
    -> VALUES (101, 500000, 425000);
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`govexectracker`.`project_costs`, CONSTRAINT `project_costs_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`))
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

mysql> INSERT INTO project_costs (project_id, projected_cost, actual_cost) VALUES (201, 500000, 425000);
ERROR 1062 (23000): Duplicate entry '201' for key 'project_costs.PRIMARY'
mysql> INSERT INTO project_costs (project_id, projected_cost, actual_cost) VALUES (301, 100000, 75000);
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`govexectracker`.`project_costs`, CONSTRAINT `project_costs_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`))
mysql> select * from project_costs;
+------------+----------------+-------------+------------+------------+------------+------------+------------+
| project_id | projected_cost | actual_cost | efficiency | q1_cost    | q2_cost    | q3_cost    | q4_cost    |
+------------+----------------+-------------+------------+------------+------------+------------+------------+
|        201 |    25000000.00 | 12000000.00 |      48.00 | 3000000.00 | 3000000.00 | 3000000.00 | 3000000.00 |
|        202 |    18000000.00 | 10000000.00 |      55.50 | 2500000.00 | 2500000.00 | 2500000.00 | 2500000.00 |
|        203 |     9000000.00 |  7000000.00 |      77.70 | 1750000.00 | 1750000.00 | 1750000.00 | 1750000.00 |
|        204 |    15000000.00 |  9000000.00 |      60.00 | 2250000.00 | 2250000.00 | 2250000.00 | 2250000.00 |
|        205 |    12000000.00 |  6000000.00 |      50.00 | 1500000.00 | 1500000.00 | 1500000.00 | 1500000.00 |
|        206 |    30000000.00 | 15000000.00 |      50.00 | 3750000.00 | 3750000.00 | 3750000.00 | 3750000.00 |
|        207 |     8000000.00 |  5000000.00 |      62.50 | 1250000.00 | 1250000.00 | 1250000.00 | 1250000.00 |
|        208 |     5000000.00 |  3000000.00 |      60.00 |  750000.00 |  750000.00 |  750000.00 |  750000.00 |
|        209 |    40000000.00 | 18000000.00 |      45.00 | 4500000.00 | 4500000.00 | 4500000.00 | 4500000.00 |
|        210 |     6000000.00 |  4500000.00 |      75.00 | 1125000.00 | 1125000.00 | 1125000.00 | 1125000.00 |
+------------+----------------+-------------+------------+------------+------------+------------+------------+
10 rows in set (0.00 sec)

mysql> INSERT INTO project_costs (project_id, projected_cost, actual_cost) VALUES (201, 100000, 75000);
ERROR 1062 (23000): Duplicate entry '201' for key 'project_costs.PRIMARY'
mysql> select * from project_costs where project_id=201;
+------------+----------------+-------------+------------+------------+------------+------------+------------+
| project_id | projected_cost | actual_cost | efficiency | q1_cost    | q2_cost    | q3_cost    | q4_cost    |
+------------+----------------+-------------+------------+------------+------------+------------+------------+
|        201 |    25000000.00 | 12000000.00 |      48.00 | 3000000.00 | 3000000.00 | 3000000.00 | 3000000.00 |
+------------+----------------+-------------+------------+------------+------------+------------+------------+
1 row in set (0.00 sec)

mysql> UPDATE project_costs
    -> SET actual_cost = 900000
    -> WHERE project_id = 201;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * FROM project_costs WHERE project_id=201;
+------------+----------------+-------------+------------+------------+------------+------------+------------+
| project_id | projected_cost | actual_cost | efficiency | q1_cost    | q2_cost    | q3_cost    | q4_cost    |
+------------+----------------+-------------+------------+------------+------------+------------+------------+
|        201 |    25000000.00 |   900000.00 |      96.40 | 3000000.00 | 3000000.00 | 3000000.00 | 3000000.00 |
+------------+----------------+-------------+------------+------------+------------+------------+------------+
1 row in set (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE TRIGGER trig_auto_ticket_solution
    -> AFTER UPDATE ON tickets
    -> FOR EACH ROW
    -> BEGIN
    ->     -- Only run when status changes TO 'resolved'
    ->     IF NEW.status = 'resolved' AND OLD.status <> 'resolved' THEN
    ->         INSERT INTO ticket_solutions (ticket_id, summary, admin_id, report_id)
    ->         VALUES (NEW.ticket_id, 'Auto-created solution on resolution', NULL, NULL);
    ->     END IF;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> SELECT ticket_id, status FROM tickets;
+-----------+-------------+
| ticket_id | status      |
+-----------+-------------+
|       701 | Open        |
|       702 | Resolved    |
|       703 | In Progress |
|       704 | Open        |
|       705 | Open        |
|       706 | Resolved    |
|       707 | In Progress |
|       708 | Closed      |
|       709 | Open        |
|       710 | Open        |
+-----------+-------------+
10 rows in set (0.00 sec)

mysql> UPDATE tickets
    -> SET status = 'resolved'
    -> WHERE ticket_id = 1001;
Query OK, 0 rows affected (0.00 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> UPDATE tickets SET status = 'resolved' WHERE ticket_id = 701;
ERROR 1054 (42S22): Unknown column 'ticket_id' in 'field list'
mysql> SELECT ticket_id, status FROM tickets;
+-----------+-------------+
| ticket_id | status      |
+-----------+-------------+
|       701 | Open        |
|       702 | Resolved    |
|       703 | In Progress |
|       704 | Open        |
|       705 | Open        |
|       706 | Resolved    |
|       707 | In Progress |
|       708 | Closed      |
|       709 | Open        |
|       710 | Open        |
+-----------+-------------+
10 rows in set (0.00 sec)

mysql> UPDATE tickets SET status = 'Resolved' WHERE ticket_id = 701;
ERROR 1054 (42S22): Unknown column 'ticket_id' in 'field list'
mysql> desc tickets;
+-------------+--------------+------+-----+---------+-------+
| Field       | Type         | Null | Key | Default | Extra |
+-------------+--------------+------+-----+---------+-------+
| ticket_id   | int          | NO   | PRI | NULL    |       |
| title       | varchar(255) | YES  |     | NULL    |       |
| status      | varchar(50)  | YES  |     | NULL    |       |
| date_raised | date         | YES  |     | NULL    |       |
| citizen_id  | int          | YES  |     | NULL    |       |
| project_id  | int          | YES  | MUL | NULL    |       |
| summary     | text         | YES  |     | NULL    |       |
+-------------+--------------+------+-----+---------+-------+
7 rows in set (0.00 sec)

mysql> SELECT * from tickets WHERE ticket_id = 701;
+-----------+-------------------+--------+-------------+------------+------------+-------------------------+
| ticket_id | title             | status | date_raised | citizen_id | project_id | summary                 |
+-----------+-------------------+--------+-------------+------------+------------+-------------------------+
|       701 | Road damage issue | Open   | 2024-01-10  |          1 |        201 | Cracks after excavation |
+-----------+-------------------+--------+-------------+------------+------------+-------------------------+
1 row in set (0.00 sec)

mysql> UPDATE tickets SET status = 'Resolved' WHERE ticket_id = 701;
ERROR 1054 (42S22): Unknown column 'ticket_id' in 'field list'
mysql> UPDATE tickets SET status = 'resolved' WHERE ticket_id = 701;
ERROR 1054 (42S22): Unknown column 'ticket_id' in 'field list'
mysql> UPDATE tickets SET status = 'resolved' WHERE ticket_id=701;
ERROR 1054 (42S22): Unknown column 'ticket_id' in 'field list'
mysql> UPDATE tickets SET status = 'resolved' WHERE 'ticket_id'=701;
ERROR 1292 (22007): Truncated incorrect DOUBLE value: 'ticket_id'
mysql> UPDATE tickets SET status = 'resolved' WHERE 'ticket_id'='701';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> SELECT * from ticket_solutions WHERE ticket_id='701';
ERROR 1054 (42S22): Unknown column 'ticket_id' in 'where clause'
mysql> SELECT * from ticket_solutions WHERE ticket_id=701;
ERROR 1054 (42S22): Unknown column 'ticket_id' in 'where clause'
mysql> desc ticket_solutions;
+-------------+------+------+-----+---------+-------+
| Field       | Type | Null | Key | Default | Extra |
+-------------+------+------+-----+---------+-------+
| solution_id | int  | NO   | PRI | NULL    |       |
| summary     | text | NO   |     | NULL    |       |
| report_id   | int  | YES  |     | NULL    |       |
| admin_id    | int  | YES  |     | NULL    |       |
+-------------+------+------+-----+---------+-------+
4 rows in set (0.00 sec)

mysql> ALTER TABLE ticket_solutions
    -> ADD ticket_id INT NOT NULL;
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE ticket_solutions
    -> ADD CONSTRAINT fk_ticket_solution
    -> FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id);
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`govexectracker`.`#sql-148_15`, CONSTRAINT `fk_ticket_solution` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`ticket_id`))
mysql> SELECT * FROM ticket_solutions;
+-------------+-------------------------+-----------+----------+-----------+
| solution_id | summary                 | report_id | admin_id | ticket_id |
+-------------+-------------------------+-----------+----------+-----------+
|         801 | Fixed road crack        |       701 |        1 |         0 |
|         802 | Pipe sealing done       |       702 |        1 |         0 |
|         803 | Replaced wiring         |       703 |        2 |         0 |
|         804 | Camera realigned        |       704 |        2 |         0 |
|         805 | Damaged bins replaced   |       705 |        3 |         0 |
|         806 | Dust sheets installed   |       706 |        3 |         0 |
|         807 | Projector replaced      |       707 |        4 |         0 |
|         808 | Meeting rescheduled     |       708 |        4 |         0 |
|         809 | Barricade rearranged    |       709 |        5 |         0 |
|         810 | Watering assigned daily |       710 |        5 |         0 |
+-------------+-------------------------+-----------+----------+-----------+
10 rows in set (0.00 sec)

mysql> DROP TABLE ticket_solutions;
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE TABLE ticket_solutions (
    ->     solution_id INT PRIMARY KEY,
    ->     ticket_id INT NOT NULL,
    ->     summary TEXT NOT NULL,
    ->     admin_id INT,
    ->     report_id INT,
    ->     FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> DROP TRIGGER IF EXISTS trig_auto_ticket_solution;
Query OK, 0 rows affected (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE TRIGGER trig_auto_ticket_solution
    -> AFTER UPDATE ON tickets
    -> FOR EACH ROW
    -> BEGIN
    ->     IF LOWER(NEW.status) = 'resolved' AND LOWER(OLD.status) <> 'resolved' THEN
    ->         INSERT INTO ticket_solutions (solution_id, ticket_id, summary, admin_id, report_id)
    ->         VALUES (NULL, NEW.ticket_id, 'Auto-created solution on resolution', NULL, NULL);
    ->     END IF;
    -> END $$
Query OK, 0 rows affected (0.01 sec)

mysql> 
mysql> DELIMITER ;
mysql> UPDATE tickets SET status='resolved' WHERE ticket_id=701;
ERROR 1048 (23000): Column 'solution_id' cannot be null
mysql> UPDATE tickets SET status='resolved' WHERE ticket_id='701';
ERROR 1048 (23000): Column 'solution_id' cannot be null
mysql> DROP TABLE ticket_solutions;
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE TABLE ticket_solutions (
    ->     solution_id INT AUTO_INCREMENT PRIMARY KEY,
    ->     ticket_id INT NOT NULL,
    ->     summary TEXT NOT NULL,
    ->     admin_id INT,
    ->     report_id INT,
    ->     FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> DROP TRIGGER IF EXISTS trig_auto_ticket_solution;
Query OK, 0 rows affected (0.01 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE TRIGGER trig_auto_ticket_solution
    -> AFTER UPDATE ON tickets
    -> FOR EACH ROW
    -> BEGIN
    ->     IF LOWER(NEW.status) = 'resolved' AND LOWER(OLD.status) <> 'resolved' THEN
    ->         INSERT INTO ticket_solutions (ticket_id, summary, admin_id, report_id)
    ->         VALUES (NEW.ticket_id, 'Auto-created solution on resolution', NULL, NULL);
    ->     END IF;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> UPDATE tickets SET status='resolved' WHERE ticket_id='701';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * from ticket_solutions;
+-------------+-----------+-------------------------------------+----------+-----------+
| solution_id | ticket_id | summary                             | admin_id | report_id |
+-------------+-----------+-------------------------------------+----------+-----------+
|           1 |       701 | Auto-created solution on resolution |     NULL |      NULL |
+-------------+-----------+-------------------------------------+----------+-----------+
1 row in set (0.00 sec)

mysql> CREATE TABLE project_updates (
    ->     update_id INT AUTO_INCREMENT PRIMARY KEY,
    ->     project_id INT,
    ->     summary TEXT,
    ->     update_date DATE,
    ->     admin_id INT
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> DROP TRIGGER IF EXISTS trig_project_status_change;
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE TRIGGER trig_project_status_change
    -> AFTER UPDATE ON projects
    -> FOR EACH ROW
    -> BEGIN
    ->     IF NEW.status <> OLD.status THEN
    ->         INSERT INTO project_updates (project_id, summary, update_date, admin_id)
    ->         VALUES (
    ->             NEW.project_id,
    ->             CONCAT('Status changed from ', OLD.status, ' to ', NEW.status),
    ->             CURDATE(),
    ->             NULL
    ->         );
    ->     END IF;
    -> END $$
ERROR 1054 (42S22): Unknown column 'status' in 'NEW'
mysql> 
mysql> DELIMITER ;
mysql> DESC projects;
+------------+--------------+------+-----+---------+-------+
| Field      | Type         | Null | Key | Default | Extra |
+------------+--------------+------+-----+---------+-------+
| project_id | int          | NO   | PRI | NULL    |       |
| name       | varchar(255) | NO   |     | NULL    |       |
| start_date | date         | YES  |     | NULL    |       |
| end_date   | date         | YES  |     | NULL    |       |
| dept_id    | int          | YES  | MUL | NULL    |       |
| summary    | text         | YES  |     | NULL    |       |
+------------+--------------+------+-----+---------+-------+
6 rows in set (0.01 sec)

mysql> ALTER TABLE projects
    -> ADD status ENUM('Not Started', 'In Progress', 'Completed', 'On Hold', 'Cancelled')
    -> DEFAULT 'Not Started';
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> DROP TRIGGER IF EXISTS trig_project_status_change;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE TRIGGER trig_project_status_change
    -> AFTER UPDATE ON projects
    -> FOR EACH ROW
    -> BEGIN
    ->     IF NEW.status <> OLD.status THEN
    ->         INSERT INTO project_updates (project_id, summary, update_date, admin_id)
    ->         VALUES (
    ->             NEW.project_id,
    ->             CONCAT('Status changed from ', OLD.status, ' to ', NEW.status),
    ->             CURDATE(),
    ->             NULL
    ->         );
    ->     END IF;
    -> END $$
Query OK, 0 rows affected (0.01 sec)

mysql> 
mysql> DELIMITER ;
mysql> UPDATE projects
    -> SET status = 'In Progress'
    -> WHERE project_id = 201;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * FROM project_updates WHERE project_id = 201;
+-----------+------------+------------------------------------------------+-------------+----------+
| update_id | project_id | summary                                        | update_date | admin_id |
+-----------+------------+------------------------------------------------+-------------+----------+
|         1 |        201 | Status changed from Not Started to In Progress | 2025-10-31  |     NULL |
+-----------+------------+------------------------------------------------+-------------+----------+
1 row in set (0.00 sec)

mysql> DROP PROCEDURE IF EXISTS add_project;
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE PROCEDURE add_project(
    ->     IN p_project_id INT,
    ->     IN p_name VARCHAR(255),
    ->     IN p_start_date DATE,
    ->     IN p_end_date DATE,
    ->     IN p_dept_id INT,
    ->     IN p_summary TEXT
    -> )
    -> BEGIN
    ->     DECLARE deptCount INT;
    -> 
    ->     SELECT COUNT(*) INTO deptCount
    ->     FROM departments
    ->     WHERE dept_id = p_dept_id;
    -> 
    ->     IF deptCount = 0 THEN
    ->         SIGNAL SQLSTATE '45000'
    ->             SET MESSAGE_TEXT = 'Error: Department does not exist';
    ->     ELSE
    ->         INSERT INTO projects (project_id, name, start_date, end_date, dept_id, summary)
    ->         VALUES (p_project_id, p_name, p_start_date, p_end_date, p_dept_id, p_summary);
    ->     END IF;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> CALL add_project(301, 'New Water Pipeline', '2024-01-01', '2024-06-30', 1, 'Water supply improvement');
ERROR 1146 (42S02): Table 'govexectracker.departments' doesn't exist
mysql> DROP PROCEDURE IF EXISTS add_project;
Query OK, 0 rows affected (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE PROCEDURE add_project(
    ->     IN p_project_id INT,
    ->     IN p_name VARCHAR(255),
    ->     IN p_start DATE,
    ->     IN p_end DATE,
    ->     IN p_dept INT,
    ->     IN p_summary TEXT
    -> )
    -> BEGIN
    ->     DECLARE deptCount INT;
    -> 
    ->     -- Check if department exists
    ->     SELECT COUNT(*) INTO deptCount
    ->     FROM department
    ->     WHERE dept_id = p_dept;
    -> 
    ->     IF deptCount = 0 THEN
    ->         SIGNAL SQLSTATE '45000'
    ->             SET MESSAGE_TEXT = 'Error: Department does not exist';
    ->     ELSE
    ->         INSERT INTO projects (project_id, name, start_date, end_date, dept_id, summary)
    ->         VALUES (p_project_id, p_name, p_start, p_end, p_dept, p_summary);
    ->     END IF;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> CALL add_project(301, 'New Water Pipeline', '2024-01-01', '2024-06-30', 1, 'Water supply improvement');
ERROR 1644 (45000): Error: Department does not exist
mysql> SELECT dept_id, name FROM department;
+---------+---------------------+
| dept_id | name                |
+---------+---------------------+
|     101 | Roads & Transport   |
|     102 | Water Supply        |
|     103 | Electricity         |
|     104 | Urban Development   |
|     105 | Waste Management    |
|     106 | Health & Sanitation |
|     107 | Education           |
|     108 | Agriculture         |
|     109 | Public Works        |
|     110 | Environment         |
+---------+---------------------+
10 rows in set (0.00 sec)

mysql> CALL add_project(902, 'New Water Pipeline', '2024-01-01', '2024-06-30', 1, 'Water supply improvement');
ERROR 1644 (45000): Error: Department does not exist
mysql> CALL add_project(902, 'New Water Pipeline', '2024-01-01', '2024-06-30', 102, 'Water supply improvement');
Query OK, 1 row affected (0.00 sec)

mysql> DROP PROCEDURE IF EXISTS get_project_report;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE PROCEDURE get_project_report(
    ->     IN p_project_id INT
    -> )
    -> BEGIN
    ->     SELECT 
    ->         p.project_id,
    ->         p.name,
    ->         p.start_date,
    ->         p.end_date,
    ->         d.name AS department_name,
    ->         pc.projected_cost,
    ->         pc.actual_cost,
    ->         pc.efficiency,
    ->         pu.update_date,
    ->         pu.summary AS last_update
    ->     FROM projects p
    ->     LEFT JOIN department d ON p.dept_id = d.dept_id
    ->     LEFT JOIN project_costs pc ON p.project_id = pc.project_id
    ->     LEFT JOIN project_updates pu ON p.project_id = pu.project_id
    ->     WHERE p.project_id = p_project_id
    ->     ORDER BY pu.update_date DESC
    ->     LIMIT 1;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> CALL get_project_report(201);
+------------+-------------------+------------+------------+-----------------+----------------+-------------+------------+-------------+------------------------------------------------+
| project_id | name              | start_date | end_date   | department_name | projected_cost | actual_cost | efficiency | update_date | last_update                                    |
+------------+-------------------+------------+------------+-----------------+----------------+-------------+------------+-------------+------------------------------------------------+
|        201 | Highway Expansion | 2024-01-01 | 2025-06-30 | Education       |    25000000.00 |   900000.00 |      96.40 | 2025-10-31  | Status changed from Not Started to In Progress |
+------------+-------------------+------------+------------+-----------------+----------------+-------------+------------+-------------+------------------------------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

mysql> SHOW PROCEDURE STATUS WHERE Db = 'govexectracker';
+----------------+--------------------+-----------+----------------+---------------------+---------------------+---------------+---------+----------------------+----------------------+--------------------+
| Db             | Name               | Type      | Definer        | Modified            | Created             | Security_type | Comment | character_set_client | collation_connection | Database Collation |
+----------------+--------------------+-----------+----------------+---------------------+---------------------+---------------+---------+----------------------+----------------------+--------------------+
| govexectracker | add_project        | PROCEDURE | root@localhost | 2025-10-31 00:18:24 | 2025-10-31 00:18:24 | DEFINER       |         | utf8mb4              | utf8mb4_0900_ai_ci   | utf8mb4_0900_ai_ci |
| govexectracker | get_project_report | PROCEDURE | root@localhost | 2025-10-31 00:20:51 | 2025-10-31 00:20:51 | DEFINER       |         | utf8mb4              | utf8mb4_0900_ai_ci   | utf8mb4_0900_ai_ci |
+----------------+--------------------+-----------+----------------+---------------------+---------------------+---------------+---------+----------------------+----------------------+--------------------+
2 rows in set (0.01 sec)

mysql> CALL get_project_report(201);
+------------+-------------------+------------+------------+-----------------+----------------+-------------+------------+-------------+------------------------------------------------+
| project_id | name              | start_date | end_date   | department_name | projected_cost | actual_cost | efficiency | update_date | last_update                                    |
+------------+-------------------+------------+------------+-----------------+----------------+-------------+------------+-------------+------------------------------------------------+
|        201 | Highway Expansion | 2024-01-01 | 2025-06-30 | Education       |    25000000.00 |   900000.00 |      96.40 | 2025-10-31  | Status changed from Not Started to In Progress |
+------------+-------------------+------------+------------+-----------------+----------------+-------------+------------+-------------+------------------------------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE PROCEDURE close_completed_projects()
    -> BEGIN
    ->     -- Update completed projects
    ->     UPDATE projects
    ->     SET summary = CONCAT(IFNULL(summary,''), '\n[System] Project marked as Completed on ', CURDATE())
    ->     WHERE end_date < CURDATE()
    ->       AND (summary NOT LIKE '%Completed%' OR summary IS NULL);
    -> 
    ->     -- Log status
    ->     INSERT INTO project_updates (project_id, summary, update_date, admin_id)
    ->     SELECT p.project_id,
    ->            CONCAT('Project automatically marked as Completed on ', CURDATE()),
    ->            CURDATE(),
    ->            NULL
    ->     FROM projects p
    ->     WHERE p.end_date < CURDATE()
    ->       AND (p.summary NOT LIKE '%Completed%' OR p.summary IS NULL);
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> SELECT project_id, name, end_date, summary FROM projects;
+------------+------------------------------+------------+--------------------------------+
| project_id | name                         | end_date   | summary                        |
+------------+------------------------------+------------+--------------------------------+
|        201 | Highway Expansion            | 2025-06-30 | Expansion of NH45              |
|        202 | New Water Pipeline           | 2024-12-15 | Underground pipe installation  |
|        203 | Solar Street Lights          | 2023-09-14 | 1000 solar lights installed    |
|        204 | Smart City CCTV              | 2024-03-01 | City-wide surveillance network |
|        205 | Garbage Segregation Units    | 2023-10-10 | At ward level                  |
|        206 | District Hospital Renovation | 2025-01-01 | New medical equipment, ICU     |
|        207 | Govt School Digitization     | 2024-05-10 | Smart classrooms in 50 schools |
|        208 | Organic Farming Training     | 2023-11-20 | Farmer training program        |
|        209 | New Flyover Construction     | 2025-09-30 | Flyover at main junction       |
|        210 | City Tree Plantation         | 2023-06-01 | Planting 20,000 trees          |
|        902 | New Water Pipeline           | 2024-06-30 | Water supply improvement       |
+------------+------------------------------+------------+--------------------------------+
11 rows in set (0.00 sec)

mysql> CALL close_completed_projects();
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT project_id, summary FROM projects;
+------------+-----------------------------------------------------------------------------------+
| project_id | summary                                                                           |
+------------+-----------------------------------------------------------------------------------+
|        201 | Expansion of NH45
[System] Project marked as Completed on 2025-10-31              |
|        202 | Underground pipe installation
[System] Project marked as Completed on 2025-10-31  |
|        203 | 1000 solar lights installed
[System] Project marked as Completed on 2025-10-31    |
|        204 | City-wide surveillance network
[System] Project marked as Completed on 2025-10-31 |
|        205 | At ward level
[System] Project marked as Completed on 2025-10-31                  |
|        206 | New medical equipment, ICU
[System] Project marked as Completed on 2025-10-31     |
|        207 | Smart classrooms in 50 schools
[System] Project marked as Completed on 2025-10-31 |
|        208 | Farmer training program
[System] Project marked as Completed on 2025-10-31        |
|        209 | Flyover at main junction
[System] Project marked as Completed on 2025-10-31       |
|        210 | Planting 20,000 trees
[System] Project marked as Completed on 2025-10-31          |
|        902 | Water supply improvement
[System] Project marked as Completed on 2025-10-31       |
+------------+-----------------------------------------------------------------------------------+
11 rows in set (0.01 sec)

mysql> SELECT * FROM project_updates ORDER BY update_id DESC;
+-----------+------------+------------------------------------------------+-------------+----------+
| update_id | project_id | summary                                        | update_date | admin_id |
+-----------+------------+------------------------------------------------+-------------+----------+
|         1 |        201 | Status changed from Not Started to In Progress | 2025-10-31  |     NULL |
+-----------+------------+------------------------------------------------+-------------+----------+
1 row in set (0.00 sec)

mysql> DROP PROCEDURE IF EXISTS close_completed_projects;
Query OK, 0 rows affected (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE PROCEDURE close_completed_projects()
    -> BEGIN
    ->     -- Step 1: Log status BEFORE updating summaries
    ->     INSERT INTO project_updates (project_id, summary, update_date, admin_id)
    ->     SELECT p.project_id,
    ->            CONCAT('Project automatically marked as Completed on ', CURDATE()),
    ->            CURDATE(),
    ->            NULL
    ->     FROM projects p
    ->     WHERE p.end_date < CURDATE()
    ->       AND (p.summary NOT LIKE '%Completed%' OR p.summary IS NULL);
    -> 
    ->     -- Step 2: Update completed projects
    ->     UPDATE projects
    ->     SET summary = CONCAT(IFNULL(summary,''), '\n[System] Project marked as Completed on ', CURDATE())
    ->     WHERE end_date < CURDATE()
    ->       AND (summary NOT LIKE '%Completed%' OR summary IS NULL);
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> CALL close_completed_projects();
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT * FROM project_updates ORDER BY update_id DESC;
+-----------+------------+------------------------------------------------+-------------+----------+
| update_id | project_id | summary                                        | update_date | admin_id |
+-----------+------------+------------------------------------------------+-------------+----------+
|         1 |        201 | Status changed from Not Started to In Progress | 2025-10-31  |     NULL |
+-----------+------------+------------------------------------------------+-------------+----------+
1 row in set (0.00 sec)

mysql> SELECT project_id, name, end_date, summary FROM projects;
+------------+------------------------------+------------+-----------------------------------------------------------------------------------+
| project_id | name                         | end_date   | summary                                                                           |
+------------+------------------------------+------------+-----------------------------------------------------------------------------------+
|        201 | Highway Expansion            | 2025-06-30 | Expansion of NH45
[System] Project marked as Completed on 2025-10-31              |
|        202 | New Water Pipeline           | 2024-12-15 | Underground pipe installation
[System] Project marked as Completed on 2025-10-31  |
|        203 | Solar Street Lights          | 2023-09-14 | 1000 solar lights installed
[System] Project marked as Completed on 2025-10-31    |
|        204 | Smart City CCTV              | 2024-03-01 | City-wide surveillance network
[System] Project marked as Completed on 2025-10-31 |
|        205 | Garbage Segregation Units    | 2023-10-10 | At ward level
[System] Project marked as Completed on 2025-10-31                  |
|        206 | District Hospital Renovation | 2025-01-01 | New medical equipment, ICU
[System] Project marked as Completed on 2025-10-31     |
|        207 | Govt School Digitization     | 2024-05-10 | Smart classrooms in 50 schools
[System] Project marked as Completed on 2025-10-31 |
|        208 | Organic Farming Training     | 2023-11-20 | Farmer training program
[System] Project marked as Completed on 2025-10-31        |
|        209 | New Flyover Construction     | 2025-09-30 | Flyover at main junction
[System] Project marked as Completed on 2025-10-31       |
|        210 | City Tree Plantation         | 2023-06-01 | Planting 20,000 trees
[System] Project marked as Completed on 2025-10-31          |
|        902 | New Water Pipeline           | 2024-06-30 | Water supply improvement
[System] Project marked as Completed on 2025-10-31       |
+------------+------------------------------+------------+-----------------------------------------------------------------------------------+
11 rows in set (0.00 sec)

mysql> UPDATE projects
    -> SET summary = 'Test summary'
    -> WHERE project_id = 201;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> CALL close_completed_projects();
Query OK, 1 row affected (0.00 sec)

mysql> SELECT * FROM project_updates ORDER BY update_id DESC;
+-----------+------------+---------------------------------------------------------+-------------+----------+
| update_id | project_id | summary                                                 | update_date | admin_id |
+-----------+------------+---------------------------------------------------------+-------------+----------+
|         2 |        201 | Project automatically marked as Completed on 2025-10-31 | 2025-10-31  |     NULL |
|         1 |        201 | Status changed from Not Started to In Progress          | 2025-10-31  |     NULL |
+-----------+------------+---------------------------------------------------------+-------------+----------+
2 rows in set (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE FUNCTION get_project_efficiency(p_project_id INT)
    -> RETURNS DECIMAL(10,2)
    -> DETERMINISTIC
    -> BEGIN
    ->     DECLARE proj_cost DECIMAL(15,2);
    ->     DECLARE act_cost DECIMAL(15,2);
    ->     DECLARE efficiency DECIMAL(10,2);
    -> 
    ->     -- Get costs
    ->     SELECT projected_cost, actual_cost
    ->     INTO proj_cost, act_cost
    ->     FROM project_costs
    ->     WHERE project_id = p_project_id;
    -> 
    ->     -- If values missing, return NULL
    ->     IF proj_cost IS NULL OR act_cost IS NULL THEN
    ->         RETURN NULL;
    ->     END IF;
    -> 
    ->     SET efficiency = (act_cost / proj_cost) * 100;
    ->     RETURN efficiency;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> SELECT get_project_efficiency(201) AS efficiency;
+------------+
| efficiency |
+------------+
|       3.60 |
+------------+
1 row in set (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE FUNCTION total_tickets(p_project_id INT)
    -> RETURNS INT
    -> DETERMINISTIC
    -> BEGIN
    ->     DECLARE t_count INT;
    -> 
    ->     SELECT COUNT(*) INTO t_count
    ->     FROM tickets
    ->     WHERE project_id = p_project_id;
    -> 
    ->     RETURN t_count;
    -> END $$
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> DELIMITER ;
mysql> SELECT total_tickets(201) AS total_issues;
+--------------+
| total_issues |
+--------------+
|            1 |
+--------------+
1 row in set (0.00 sec)

mysql> DELIMITER $$
mysql> 
mysql> CREATE FUNCTION ticket_resolution_ratio(p_project_id INT)
    -> RETURNS DECIMAL(10,2)
    -> DETERMINISTIC
    -> BEGIN
    ->     DECLARE total_t INT;
    ->     DECLARE resolved_t INT;
    ->     DECLARE ratio DECIMAL(10,2);
    -> 
    ->     -- Count total tickets for this project
    ->     SELECT COUNT(*) INTO total_t
    ->     FROM tickets
    ->     WHERE project_id = p_project_id;
    -> 
    ->     -- If no tickets exist, return NULL or 0
    ->     IF total_t = 0 THEN
    ->         RETURN NULL;
    ->     END IF;
    -> 
    ->     -- Count resolved tickets
    ->     SELECT COUNT(*) INTO resolved_t
    ->     FROM tickets
    ->     WHERE project_id = p_project_id
    ->       AND status = 'Resolved';
    -> 
    ->     SET ratio = (resolved_t / total_t) * 100;
    ->     RETURN ratio;
    -> END $$
Query OK, 0 rows affected (0.01 sec)

mysql> 
mysql> DELIMITER ;
mysql> SELECT ticket_resolution_ratio(201) AS resolution_percentage;
+-----------------------+
| resolution_percentage |
+-----------------------+
|                100.00 |
+-----------------------+
1 row in set (0.00 sec)

mysql> notee
