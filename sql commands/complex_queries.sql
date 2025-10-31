mysql> SELECT ticket_resolution_ratio(201) AS resolution_percentage;
+-----------------------+
| resolution_percentage |
+-----------------------+
|                100.00 |
+-----------------------+
1 row in set (0.00 sec)

mysql> SELECT p.project_id, p.name, d.name AS department, p.start_date, p.end_date
    -> FROM projects p
    -> LEFT JOIN department d ON p.dept_id = d.dept_id
    -> WHERE p.end_date >= CURDATE();
Empty set (0.00 sec)

mysql> SELECT p.project_id, p.name, pc.projected_cost, pc.actual_cost
    -> FROM projects p
    -> JOIN project_costs pc ON p.project_id = pc.project_id
    -> WHERE pc.actual_cost > pc.projected_cost;
Empty set (0.00 sec)

mysql> SELECT project_id, name, get_project_efficiency(project_id) AS efficiency
    -> FROM projects;
+------------+------------------------------+------------+
| project_id | name                         | efficiency |
+------------+------------------------------+------------+
|        201 | Highway Expansion            |       3.60 |
|        202 | New Water Pipeline           |      55.56 |
|        203 | Solar Street Lights          |      77.78 |
|        204 | Smart City CCTV              |      60.00 |
|        205 | Garbage Segregation Units    |      50.00 |
|        206 | District Hospital Renovation |      50.00 |
|        207 | Govt School Digitization     |      62.50 |
|        208 | Organic Farming Training     |      60.00 |
|        209 | New Flyover Construction     |      45.00 |
|        210 | City Tree Plantation         |      75.00 |
|        902 | New Water Pipeline           |       NULL |
+------------+------------------------------+------------+
11 rows in set (0.00 sec)

mysql> SELECT 
    ->     p.project_id,
    ->     p.name,
    ->     total_tickets(p.project_id) AS total_issues
    -> FROM projects p
    -> ORDER BY total_issues DESC;
+------------+------------------------------+--------------+
| project_id | name                         | total_issues |
+------------+------------------------------+--------------+
|        201 | Highway Expansion            |            1 |
|        202 | New Water Pipeline           |            1 |
|        203 | Solar Street Lights          |            1 |
|        204 | Smart City CCTV              |            1 |
|        205 | Garbage Segregation Units    |            1 |
|        206 | District Hospital Renovation |            1 |
|        207 | Govt School Digitization     |            1 |
|        208 | Organic Farming Training     |            1 |
|        209 | New Flyover Construction     |            1 |
|        210 | City Tree Plantation         |            1 |
|        902 | New Water Pipeline           |            0 |
+------------+------------------------------+--------------+
11 rows in set (0.00 sec)

mysql> SELECT
    ->     p.project_id,
    ->     p.name,
    ->     ticket_resolution_ratio(p.project_id) AS resolution_percentage
    -> FROM projects p;
+------------+------------------------------+-----------------------+
| project_id | name                         | resolution_percentage |
+------------+------------------------------+-----------------------+
|        201 | Highway Expansion            |                100.00 |
|        202 | New Water Pipeline           |                100.00 |
|        203 | Solar Street Lights          |                  0.00 |
|        204 | Smart City CCTV              |                  0.00 |
|        205 | Garbage Segregation Units    |                  0.00 |
|        206 | District Hospital Renovation |                100.00 |
|        207 | Govt School Digitization     |                  0.00 |
|        208 | Organic Farming Training     |                  0.00 |
|        209 | New Flyover Construction     |                  0.00 |
|        210 | City Tree Plantation         |                  0.00 |
|        902 | New Water Pipeline           |                  NULL |
+------------+------------------------------+-----------------------+
11 rows in set (0.00 sec)

mysql> SELECT t.ticket_id, t.title, t.status, t.date_raised, p.name AS project
    -> FROM tickets t
    -> JOIN projects p ON t.project_id = p.project_id
    -> WHERE t.status <> 'Resolved'
    ->   AND t.date_raised < DATE_SUB(CURDATE(), INTERVAL 30 DAY);
+-----------+------------------------------+-------------+-------------+---------------------------+
| ticket_id | title                        | status      | date_raised | project                   |
+-----------+------------------------------+-------------+-------------+---------------------------+
|       703 | Street lights not working    | In Progress | 2024-01-20  | Solar Street Lights       |
|       704 | Camera angle wrong           | Open        | 2024-03-15  | Smart City CCTV           |
|       705 | Garbage overflow             | Open        | 2024-02-22  | Garbage Segregation Units |
|       707 | School projector not working | In Progress | 2024-03-20  | Govt School Digitization  |
|       708 | Farmer meeting delayed       | Closed      | 2024-02-01  | Organic Farming Training  |
|       709 | Flyover blocking footpath    | Open        | 2024-03-05  | New Flyover Construction  |
|       710 | Saplings not watered         | Open        | 2024-01-18  | City Tree Plantation      |
+-----------+------------------------------+-------------+-------------+---------------------------+
7 rows in set (0.01 sec)

mysql> SELECT p.project_id, p.name, pc.projected_cost
    -> FROM projects p
    -> JOIN project_costs pc ON p.project_id = pc.project_id
    -> ORDER BY pc.projected_cost DESC
    -> LIMIT 5;
+------------+------------------------------+----------------+
| project_id | name                         | projected_cost |
+------------+------------------------------+----------------+
|        209 | New Flyover Construction     |    40000000.00 |
|        206 | District Hospital Renovation |    30000000.00 |
|        201 | Highway Expansion            |    25000000.00 |
|        202 | New Water Pipeline           |    18000000.00 |
|        204 | Smart City CCTV              |    15000000.00 |
+------------+------------------------------+----------------+
5 rows in set (0.00 sec)

mysql> SELECT we.employee_name, c.contractor_name, p.name AS project
    -> FROM working_employees we
    -> JOIN contractors c ON we.contractor_id = c.contractor_id
    -> JOIN projects p ON we.project_id = p.project_id;
ERROR 1054 (42S22): Unknown column 'we.employee_name' in 'field list'
mysql> SELECT p.project_id, p.name, COUNT(t.ticket_id) AS ticket_count
    -> FROM projects p
    -> JOIN tickets t ON p.project_id = t.project_id
    -> GROUP BY p.project_id, p.name
    -> HAVING ticket_count > 5;
Empty set (0.00 sec)

mysql> SELECT d.name, d.dept_id
    -> FROM department d
    -> WHERE d.dept_id = (
    ->     SELECT dept_id
    ->     FROM projects
    ->     GROUP BY dept_id
    ->     ORDER BY COUNT(*) DESC
    ->     LIMIT 1
    -> );
+--------------+---------+
| name         | dept_id |
+--------------+---------+
| Water Supply |     102 |
+--------------+---------+
1 row in set (0.00 sec)

mysql> CREATE OR REPLACE VIEW project_dashboard AS
    -> SELECT
    ->     p.project_id,
    ->     p.name,
    ->     d.name AS department,
    ->     get_project_efficiency(p.project_id) AS efficiency,
    ->     total_tickets(p.project_id) AS total_tickets,
    ->     ticket_resolution_ratio(p.project_id) AS resolution_rate
    -> FROM projects p
    -> LEFT JOIN department d ON p.dept_id = d.dept_id;
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE OR REPLACE VIEW project_dashboard AS
    -> SELECT
    ->     p.project_id,
    ->     p.name,
    ->     d.name AS department,
    ->     get_project_efficiency(p.project_id) AS efficiency,
    ->     total_tickets(p.project_id) AS total_tickets,
    ->     ticket_resolution_ratio(p.project_id) AS resolution_rate
    -> FROM projects p
    -> LEFT JOIN department d ON p.dept_id = d.dept_id;
Query OK, 0 rows affected (0.01 sec)

mysql> SELECT 
    ->     p.project_id,
    ->     p.name,
    ->     pc.q1_cost,
    ->     pc.q2_cost,
    ->     pc.q3_cost,
    ->     pc.q4_cost
    -> FROM projects p
    -> JOIN project_costs pc ON p.project_id = pc.project_id;
+------------+------------------------------+------------+------------+------------+------------+
| project_id | name                         | q1_cost    | q2_cost    | q3_cost    | q4_cost    |
+------------+------------------------------+------------+------------+------------+------------+
|        201 | Highway Expansion            | 3000000.00 | 3000000.00 | 3000000.00 | 3000000.00 |
|        202 | New Water Pipeline           | 2500000.00 | 2500000.00 | 2500000.00 | 2500000.00 |
|        203 | Solar Street Lights          | 1750000.00 | 1750000.00 | 1750000.00 | 1750000.00 |
|        204 | Smart City CCTV              | 2250000.00 | 2250000.00 | 2250000.00 | 2250000.00 |
|        205 | Garbage Segregation Units    | 1500000.00 | 1500000.00 | 1500000.00 | 1500000.00 |
|        206 | District Hospital Renovation | 3750000.00 | 3750000.00 | 3750000.00 | 3750000.00 |
|        207 | Govt School Digitization     | 1250000.00 | 1250000.00 | 1250000.00 | 1250000.00 |
|        208 | Organic Farming Training     |  750000.00 |  750000.00 |  750000.00 |  750000.00 |
|        209 | New Flyover Construction     | 4500000.00 | 4500000.00 | 4500000.00 | 4500000.00 |
|        210 | City Tree Plantation         | 1125000.00 | 1125000.00 | 1125000.00 | 1125000.00 |
+------------+------------------------------+------------+------------+------------+------------+
10 rows in set (0.00 sec)

mysql> SELECT e.employee_name, c.contractor_name, p.name
    -> FROM working_employees we
    -> JOIN employees e ON we.employee_id = e.employee_id
    -> JOIN contractors c ON we.contractor_id = c.contractor_id
    -> JOIN projects p ON we.project_id = p.project_id;
ERROR 1146 (42S02): Table 'govexectracker.employees' doesn't exist
mysql> SELECT e.employee_name, c.contractor_name, p.name FROM working_employees we JOIN govt_employees e ON we.employee_id = e.employee_id JOIN contractors c ON we.contractor_id = c.contractor_id JOIN projects p ON we.project_id = p.project_id;
ERROR 1146 (42S02): Table 'govexectracker.govt_employees' doesn't exist
mysql> desc tables;
ERROR 1146 (42S02): Table 'govexectracker.tables' doesn't exist
mysql> show tables;
+--------------------------+
| Tables_in_govexectracker |
+--------------------------+
| contractors              |
| department               |
| employee_attendance      |
| government_employees     |
| login_info               |
| project_costs            |
| project_dashboard        |
| project_updates          |
| projects                 |
| subtasks                 |
| ticket_solutions         |
| tickets                  |
| web_admin_list           |
| web_citizen_list         |
| working_employees        |
+--------------------------+
15 rows in set (0.01 sec)

mysql> SELECT 
    ->     ge.name AS employee_name,
    ->     c.contractor_name,
    ->     p.name AS project_name
    -> FROM working_employees we
    -> JOIN government_employees ge ON we.employee_id = ge.employee_id
    -> JOIN contractors c ON we.contractor_id = c.contractor_id
    -> JOIN projects p ON we.project_id = p.project_id;
ERROR 1054 (42S22): Unknown column 'c.contractor_name' in 'field list'
mysql> desc contractors;
+---------------+---------------+------+-----+---------+-------+
| Field         | Type          | Null | Key | Default | Extra |
+---------------+---------------+------+-----+---------+-------+
| contractor_id | int           | NO   | PRI | NULL    |       |
| name          | varchar(255)  | NO   |     | NULL    |       |
| bid_amount    | decimal(10,2) | YES  |     | NULL    |       |
| project_id    | int           | YES  | MUL | NULL    |       |
+---------------+---------------+------+-----+---------+-------+
4 rows in set (0.00 sec)

mysql> SELECT      ge.name AS employee_name,     c.name AS contractor_name,     p.name AS project_name FROM working_employees we JOIN government_employees ge ON we.employee_id = ge.employee_id JOIN contractors c ON we.contractor_id = c.contractor_id JOIN projects p ON we.project_id = p.project_id;
ERROR 1054 (42S22): Unknown column 'we.contractor_id' in 'on clause'
mysql> desc working_employees;
+--------------+--------------+------+-----+---------+-------+
| Field        | Type         | Null | Key | Default | Extra |
+--------------+--------------+------+-----+---------+-------+
| work_emp_id  | int          | NO   | PRI | NULL    |       |
| name         | varchar(255) | YES  |     | NULL    |       |
| gender       | varchar(10)  | YES  |     | NULL    |       |
| dob          | date         | YES  |     | NULL    |       |
| tasks        | varchar(300) | YES  |     | NULL    |       |
| project_id   | int          | YES  | MUL | NULL    |       |
| dept_id      | int          | YES  | MUL | NULL    |       |
| email        | varchar(255) | YES  |     | NULL    |       |
| phone_number | varchar(20)  | YES  |     | NULL    |       |
+--------------+--------------+------+-----+---------+-------+
9 rows in set (0.00 sec)

mysql> SELECT      ge.name AS employee_name,     c.name AS contractor_name,     p.name AS project_name FROM working_employees we JOIN government_employees ge ON we.employee_id = ge.employee_id JOIN contractors c ON we.work_emp_id = c.contractor_id JOIN projects p ON we.project_id = p.project_id;
ERROR 1054 (42S22): Unknown column 'we.employee_id' in 'on clause'
mysql> desc govt_employees;
ERROR 1146 (42S02): Table 'govexectracker.govt_employees' doesn't exist
mysql> desc government_employees;
+--------------+--------------+------+-----+---------+-------+
| Field        | Type         | Null | Key | Default | Extra |
+--------------+--------------+------+-----+---------+-------+
| govt_emp_id  | int          | NO   | PRI | NULL    |       |
| name         | varchar(255) | YES  |     | NULL    |       |
| gender       | varchar(10)  | YES  |     | NULL    |       |
| dob          | date         | YES  |     | NULL    |       |
| email        | varchar(255) | YES  |     | NULL    |       |
| phone_number | varchar(20)  | YES  |     | NULL    |       |
| proj_id      | int          | YES  | MUL | NULL    |       |
| dept_id      | int          | YES  | MUL | NULL    |       |
| manager      | varchar(255) | YES  |     | NULL    |       |
+--------------+--------------+------+-----+---------+-------+
9 rows in set (0.01 sec)

mysql> SELECT      ge.name AS employee_name,     c.name AS contractor_name,     p.name AS project_name FROM working_employees we JOIN government_employees ge ON we.work_emp_id = ge.govt_emp_id_id JOIN contractors c ON we.work_emp_id = c.contractor_id JOIN projects p ON we.project_id = p.project_id;
ERROR 1054 (42S22): Unknown column 'ge.govt_emp_id_id' in 'on clause'
mysql> SELECT      ge.name AS employee_name,     c.name AS contractor_name,     p.name AS project_name FROM working_employees we JOIN government_employees ge ON we.work_emp_id = ge.govt_emp_id JOIN contractors c ON we.work_emp_id = c.contractor_id JOIN projects p ON we.project_id = p.project_id;
Empty set (0.00 sec)

mysql> desc login;
ERROR 1146 (42S02): Table 'govexectracker.login' doesn't exist
mysql> show tables;
+--------------------------+
| Tables_in_govexectracker |
+--------------------------+
| contractors              |
| department               |
| employee_attendance      |
| government_employees     |
| login_info               |
| project_costs            |
| project_dashboard        |
| project_updates          |
| projects                 |
| subtasks                 |
| ticket_solutions         |
| tickets                  |
| web_admin_list           |
| web_citizen_list         |
| working_employees        |
+--------------------------+
15 rows in set (0.00 sec)

mysql> web_admin_list;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'web_admin_list' at line 1
mysql> select * from web_admin_list;
+----------+-----------------+
| admin_id | name            |
+----------+-----------------+
|        1 | Administrator A |
|        2 | Administrator B |
|        3 | Administrator C |
|        4 | Administrator D |
|        5 | Administrator E |
|        6 | Administrator F |
|        7 | Administrator G |
|        8 | Administrator H |
|        9 | Administrator I |
|       10 | Administrator J |
+----------+-----------------+
10 rows in set (0.00 sec)

mysql> select * from login_info
    -> ;
+--------+----------+
| emp_id | password |
+--------+----------+
|    401 | pw401    |
|    402 | pw402    |
|    403 | pw403    |
|    404 | pw404    |
|    405 | pw405    |
|    406 | pw406    |
|    407 | pw407    |
|    408 | pw408    |
|    409 | pw409    |
|    410 | pw410    |
+--------+----------+
10 rows in set (0.00 sec)

mysql> exit
