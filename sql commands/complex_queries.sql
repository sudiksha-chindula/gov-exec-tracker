
SELECT ticket_resolution_ratio(201) AS resolution_percentage;

SELECT project_id, name, get_project_efficiency(project_id) AS efficiency
FROM projects;

SELECT 
    p.project_id,
    p.name,
    total_tickets(p.project_id) AS total_issues
FROM projects p
ORDER BY total_issues DESC;

SELECT
    p.project_id,
    p.name,
    ticket_resolution_ratio(p.project_id) AS resolution_percentage
FROM projects p;

-- Query for projects that are not yet finished
SELECT p.project_id, p.name, d.name AS department, p.start_date, p.end_date
FROM projects p
LEFT JOIN department d ON p.dept_id = d.dept_id
WHERE p.end_date >= CURDATE();

-- Query for projects that are over budget
SELECT p.project_id, p.name, pc.projected_cost, pc.actual_cost
FROM projects p
JOIN project_costs pc ON p.project_id = pc.project_id
WHERE pc.actual_cost > pc.projected_cost;

-- Query for old, unresolved tickets
SELECT t.ticket_id, t.title, t.status, t.date_raised, p.name AS project
FROM tickets t
JOIN projects p ON t.project_id = p.project_id
WHERE t.status <> 'Resolved'
  AND t.date_raised < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- Aggregate query: Top 5 most expensive projects
SELECT p.project_id, p.name, pc.projected_cost
FROM projects p
JOIN project_costs pc ON p.project_id = pc.project_id
ORDER BY pc.projected_cost DESC
LIMIT 5;

-- Query to find projects with more than 5 tickets
SELECT p.project_id, p.name, COUNT(t.ticket_id) AS ticket_count
FROM projects p
JOIN tickets t ON p.project_id = t.project_id
GROUP BY p.project_id, p.name
HAVING ticket_count > 5;

-- Nested Subquery: Find the department with the most projects
SELECT d.name, d.dept_id
FROM department d
WHERE d.dept_id = (
    SELECT dept_id
    FROM projects
    GROUP BY dept_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- Creating a View
CREATE OR REPLACE VIEW project_dashboard AS
SELECT
    p.project_id,
    p.name,
    d.name AS department,
    get_project_efficiency(p.project_id) AS efficiency,
    total_tickets(p.project_id) AS total_tickets,
    ticket_resolution_ratio(p.project_id) AS resolution_rate
FROM projects p
LEFT JOIN department d ON p.dept_id = d.dept_id;

-- Query for quarterly costs
SELECT 
    p.project_id,
    p.name,
    pc.q1_cost,
    pc.q2_cost,
    pc.q3_cost,
    pc.q4_cost
FROM projects p
JOIN project_costs pc ON p.project_id = pc.project_id;

-- Multi-table JOIN (this was the final, successful version from your log)
SELECT 
    ge.name AS employee_name, 
    c.name AS contractor_name, 
    p.name AS project_name 
FROM working_employees we 
JOIN government_employees ge ON we.work_emp_id = ge.govt_emp_id 
JOIN contractors c ON we.work_emp_id = c.contractor_id 
JOIN projects p ON we.project_id = p.project_id;
