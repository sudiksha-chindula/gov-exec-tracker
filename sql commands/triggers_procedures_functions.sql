-- This file contains all the cleaned, executable triggers,
-- procedures, functions, and table alterations
-- from your 'triggers_procedures_functions.sql' log.

-- Set the database to use
USE govexectracker;

-- Trigger: Calculate efficiency on INSERT
DELIMITER $$
CREATE TRIGGER trig_calc_efficiency_before_insert
    BEFORE INSERT ON project_costs
    FOR EACH ROW
    BEGIN
        IF NEW.projected_cost IS NOT NULL AND NEW.actual_cost IS NOT NULL THEN
            SET NEW.efficiency = ((NEW.projected_cost - NEW.actual_cost) / NEW.projected_cost) * 100;
        ELSE
            SET NEW.efficiency = NULL;
        END IF;
    END $$
DELIMITER ;

-- Trigger: Calculate efficiency on UPDATE
DELIMITER $$
CREATE TRIGGER trig_calc_efficiency_before_update
    BEFORE UPDATE ON project_costs
    FOR EACH ROW
    BEGIN
        IF NEW.projected_cost IS NOT NULL AND NEW.actual_cost IS NOT NULL THEN
            SET NEW.efficiency = ((NEW.projected_cost - NEW.actual_cost) / NEW.projected_cost) * 100;
        ELSE
            SET NEW.efficiency = NULL;
        END IF;
    END $$
DELIMITER ;

-- Table Fix: Re-create 'ticket_solutions' with AUTO_INCREMENT
DROP TABLE IF EXISTS ticket_solutions;
CREATE TABLE ticket_solutions (
    solution_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    summary TEXT NOT NULL,
    admin_id INT,
    report_id INT,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);

-- Trigger: Auto-create a ticket solution when a ticket is resolved
DROP TRIGGER IF EXISTS trig_auto_ticket_solution;
DELIMITER $$
CREATE TRIGGER trig_auto_ticket_solution
    AFTER UPDATE ON tickets
    FOR EACH ROW
    BEGIN
        IF LOWER(NEW.status) = 'resolved' AND LOWER(OLD.status) <> 'resolved' THEN
            INSERT INTO ticket_solutions (ticket_id, summary, admin_id, report_id)
            VALUES (NEW.ticket_id, 'Auto-created solution on resolution', NULL, NULL);
        END IF;
    END $$
DELIMITER ;

-- Table: Create 'project_updates'
CREATE TABLE project_updates (
    update_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT,
    summary TEXT,
    update_date DATE,
    admin_id INT
);

-- Table Fix: Add 'status' column to 'projects' table
ALTER TABLE projects
    ADD status ENUM('Not Started', 'In Progress', 'Completed', 'On Hold', 'Cancelled')
    DEFAULT 'Not Started';

-- Trigger: Log project status changes to 'project_updates'
DROP TRIGGER IF EXISTS trig_project_status_change;
DELIMITER $$
CREATE TRIGGER trig_project_status_change
    AFTER UPDATE ON projects
    FOR EACH ROW
    BEGIN
        IF NEW.status <> OLD.status THEN
            INSERT INTO project_updates (project_id, summary, update_date, admin_id)
            VALUES (
                NEW.project_id,
                CONCAT('Status changed from ', OLD.status, ' to ', NEW.status),
                CURDATE(),
                NULL
            );
        END IF;
    END $$
DELIMITER ;

-- Procedure: Add a new project with department validation
DROP PROCEDURE IF EXISTS add_project;
DELIMITER $$
CREATE PROCEDURE add_project(
    IN p_project_id INT,
    IN p_name VARCHAR(255),
    IN p_start DATE,
    IN p_end DATE,
    IN p_dept INT,
    IN p_summary TEXT
)
BEGIN
    DECLARE deptCount INT;

    -- Check if department exists
    SELECT COUNT(*) INTO deptCount
    FROM department
    WHERE dept_id = p_dept;

    IF deptCount = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Department does not exist';
    ELSE
        INSERT INTO projects (project_id, name, start_date, end_date, dept_id, summary)
        VALUES (p_project_id, p_name, p_start, p_end, p_dept, p_summary);
    END IF;
END $$
DELIMITER ;

-- Procedure: Get a full report for a single project
DROP PROCEDURE IF EXISTS get_project_report;
DELIMITER $$
CREATE PROCEDURE get_project_report(
    IN p_project_id INT
)
BEGIN
    SELECT 
        p.project_id,
        p.name,
        p.start_date,
        p.end_date,
        d.name AS department_name,
        pc.projected_cost,
        pc.actual_cost,
        pc.efficiency,
        pu.update_date,
        pu.summary AS last_update
    FROM projects p
    LEFT JOIN department d ON p.dept_id = d.dept_id
    LEFT JOIN project_costs pc ON p.project_id = pc.project_id
    LEFT JOIN project_updates pu ON p.project_id = pu.project_id
    WHERE p.project_id = p_project_id
    ORDER BY pu.update_date DESC
    LIMIT 1;
END $$
DELIMITER ;

-- Procedure: Batch job to close out old projects
DROP PROCEDURE IF EXISTS close_completed_projects;
DELIMITER $$
CREATE PROCEDURE close_completed_projects()
BEGIN
    -- Step 1: Log status BEFORE updating summaries
    INSERT INTO project_updates (project_id, summary, update_date, admin_id)
    SELECT p.project_id,
           CONCAT('Project automatically marked as Completed on ', CURDATE()),
           CURDATE(),
           NULL
    FROM projects p
    WHERE p.end_date < CURDATE()
      AND (p.summary NOT LIKE '%Completed%' OR p.summary IS NULL);

    -- Step 2: Update completed projects
    UPDATE projects
    SET summary = CONCAT(IFNULL(summary,''), '\n[System] Project marked as Completed on ', CURDATE())
    WHERE end_date < CURDATE()
      AND (summary NOT LIKE '%Completed%' OR summary IS NULL);
END $$
DELIMITER ;



-- Function: Get project efficiency
DELIMITER $$
CREATE FUNCTION get_project_efficiency(p_project_id INT)
    RETURNS DECIMAL(10,2)
    DETERMINISTIC
BEGIN
    DECLARE proj_cost DECIMAL(15,2);
    DECLARE act_cost DECIMAL(15,2);
    DECLARE efficiency DECIMAL(10,2);
    SELECT projected_cost, actual_cost
    INTO proj_cost, act_cost
    FROM project_costs
    WHERE project_id = p_project_id;
    IF proj_cost IS NULL OR act_cost IS NULL OR proj_cost = 0 THEN
        RETURN NULL;
    END IF;
    SET efficiency = ((projected_cost - actual_cost) / projected_cost) * 100;
    
    RETURN efficiency;
END $$
DELIMITER ;

-- Function: Count total tickets for a project
DELIMITER $$
CREATE FUNCTION total_tickets(p_project_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE t_count INT;

    SELECT COUNT(*) INTO t_count
    FROM tickets
    WHERE project_id = p_project_id;

    RETURN t_count;
END $$
DELIMITER ;

-- Function: Calculate ticket resolution ratio
DELIMITER $$
CREATE FUNCTION ticket_resolution_ratio(p_project_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_t INT;
    DECLARE resolved_t INT;
    DECLARE ratio DECIMAL(10,2);

    -- Count total tickets for this project
    SELECT COUNT(*) INTO total_t
    FROM tickets
    WHERE project_id = p_project_id;

    -- If no tickets exist, return NULL or 0
    IF total_t = 0 THEN
        RETURN NULL;
    END IF;

    -- Count resolved tickets
    SELECT COUNT(*) INTO resolved_t
    FROM tickets
    WHERE project_id = p_project_id
      AND status = 'Resolved';

    SET ratio = (resolved_t / total_t) * 100;
    RETURN ratio;
END $$
DELIMITER ;


DROP TRIGGER IF EXISTS trig_auto_ticket_solution;


DROP PROCEDURE IF EXISTS sp_ResolveTicket;

DELIMITER $$
CREATE PROCEDURE sp_ResolveTicket(
    -- This order matches the Python call:
    -- (solution_id, ticket_id, summary, admin_id)
    IN p_solution_id INT,
    IN p_ticket_id INT,
    IN p_summary TEXT,
    IN p_admin_id INT
)
BEGIN
    START TRANSACTION;
    
    -- Insert the new solution into the ticket_solutions table
    -- Explicitly listing columns is safer.
    INSERT INTO ticket_solutions(solution_id, ticket_id, summary, admin_id)
    VALUES (p_solution_id, p_ticket_id, p_summary, p_admin_id);
    
    -- Update the original ticket's status to 'Resolved'
    UPDATE tickets
    SET status = 'Resolved'
    WHERE ticket_id = p_ticket_id;
    
    COMMIT;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE sp_LogGovtAttendance(
    IN p_govt_emp_id INT,
    IN p_attendance_date DATE,
    IN p_clock_in TIME,
    IN p_clock_out TIME,
    IN p_task_summary TEXT
)
BEGIN
    INSERT INTO employee_attendance (govt_emp_id, attendance_date, clock_in, clock_out, task_summary)
    VALUES (p_govt_emp_id, p_attendance_date, p_clock_in, p_clock_out, p_task_summary)
    ON DUPLICATE KEY UPDATE 
        clock_in = VALUES(clock_in), 
        clock_out = VALUES(clock_out), 
        task_summary = VALUES(task_summary);
END$$
