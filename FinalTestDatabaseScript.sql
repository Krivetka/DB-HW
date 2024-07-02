drop table if exists task_log;
drop table if exists task_status;
drop table if exists project_team;
drop table if exists team_role;
drop table if exists team_member;
drop table if exists task;
drop table if exists project;

create table project(
	project_id serial primary key,
	project_name text not null unique);

insert into project(project_name) values
('P1'), ('P2'), ('P3');

create table task(
	task_id serial primary key,
	task_name text not null,
	project_id int not null,
	foreign key (project_id) references project(project_id));

insert into task(task_name, project_id) values
('T1P1', 1), ('T2P1', 1), ('T3P1', 1), 
('T1P2', 2), ('T2P2', 2), 
('T1P3', 3), ('T2P3', 3), ('T3P3', 3), ('T4P3', 3);

create table team_member(
	member_id serial primary key,
	name text not null);

insert into team_member(name) values
('TM1'), ('TM2'), ('TM3'), ('TM4'), ('TM5');

create table team_role(
	role_id serial primary key,
	role_name text not null unique);

insert into team_role(role_name) values
('Dev'), ('Test'), ('Manager');

create table project_team(
	project_id int,
	member_id int,
	role_id int,
	constraint pk_project_team primary key (project_id, member_id, role_id),
	foreign key (project_id) references project(project_id),
	foreign key (member_id) references team_member(member_id),
	foreign key (role_id) references team_role(role_id));

insert into project_team(project_id, member_id, role_id) values 
(1, 1, 1), (1, 2, 1), (1, 3, 3), (1, 4, 2),
(2, 2, 1), (2, 5, 2), (2, 1, 3),
(3, 3, 3), (3, 2, 1), (3, 1, 2);

create table task_status(
	status_id serial primary key,
	status_name text not null unique);
	
insert into task_status(status_name) values
('ToDo'), ('InProgress'), ('InTest'), ('Done');

create table task_log(
	task_log_id serial primary key,
	task_id int not null,
	member_id int not null,
	status_id int not null,
	assign_date date,
	foreign key (task_id) references task(task_id),
	foreign key (member_id) references team_member(member_id),
	foreign key (status_id) references task_status(status_id)
);

insert into task_log(task_id, member_id, status_id, assign_date) values
(1, 2, 2, '2024-01-02'),
(2, 2, 1, '2024-01-04'),
(3, 3, 4, '2023-12-23'),
(4, 5, 3, '2024-12-23'),
(5, 1, 2, '2024-01-08'),
(6, 3, 4, '2024-01-02'),
(7, 2, 2, '2024-02-02'),
(8, 1, 2, '2024-01-12'),
(9, 3, 2, '2024-01-25');


CREATE TABLE task_status_history(
    status_log_id SERIAL PRIMARY KEY,
    task_id INT NOT NULL,
    status_id INT NOT NULL,
    change_date DATE NOT NULL,
    FOREIGN KEY (task_id) REFERENCES task(task_id),
    FOREIGN KEY (status_id) REFERENCES task_status(status_id)
);

CREATE TABLE task_assignment_history(
    assignment_log_id SERIAL PRIMARY KEY,
    task_id INT NOT NULL,
    member_id INT NOT NULL,
    assign_date DATE NOT NULL,
    FOREIGN KEY (task_id) REFERENCES task(task_id),
    FOREIGN KEY (member_id) REFERENCES team_member(member_id)
);

INSERT INTO task_status_history (task_id, status_id, change_date)
SELECT task_id, status_id, assign_date FROM task_log;

INSERT INTO task_assignment_history (task_id, member_id, assign_date)
SELECT task_id, member_id, assign_date FROM task_log;

DROP TABLE task_log;



CREATE OR REPLACE VIEW project_tasks AS
SELECT 
    t.task_id,
    t.task_name,
    p.project_name,
    ts.status_name AS current_status,
    tm.name AS assigned_to
FROM 
    task t
JOIN 
    project p ON t.project_id = p.project_id
LEFT JOIN 
    (SELECT DISTINCT ON (task_id) task_id, status_id, change_date 
     FROM task_status_history 
     ORDER BY task_id, change_date DESC) tsh ON t.task_id = tsh.task_id
LEFT JOIN 
    task_status ts ON tsh.status_id = ts.status_id
LEFT JOIN 
    (SELECT DISTINCT ON (task_id) task_id, member_id, assign_date 
     FROM task_assignment_history 
     ORDER BY task_id, assign_date DESC) tah ON t.task_id = tah.task_id
LEFT JOIN 
    team_member tm ON tah.member_id = tm.member_id;

SELECT * FROM project_tasks



SELECT 
    p.project_name,
    tm.name AS team_member,
    tr.role_name
FROM 
    project p
JOIN 
    project_team pt ON p.project_id = pt.project_id
JOIN 
    team_member tm ON pt.member_id = tm.member_id
JOIN 
    team_role tr ON pt.role_id = tr.role_id
ORDER BY 
    p.project_name, tr.role_name, tm.name;




DROP FUNCTION IF EXISTS assign_task(INT, INT);

CREATE OR REPLACE FUNCTION assign_task(p_task_id INT, p_member_id INT) RETURNS VOID AS $$
DECLARE
    v_project_id INT;
BEGIN
    SELECT t.project_id INTO v_project_id FROM task t WHERE t.task_id = p_task_id;
    
    IF NOT EXISTS (
        SELECT 1 
        FROM project_team pt 
        WHERE pt.project_id = v_project_id AND pt.member_id = p_member_id
    ) THEN
        RAISE EXCEPTION 'Team member is not part of the project team';
    END IF;

    INSERT INTO task_assignment_history (task_id, member_id, assign_date)
    VALUES (p_task_id, p_member_id, CURRENT_DATE);
    
    RAISE NOTICE 'Task assigned successfully';
END;
$$ LANGUAGE plpgsql;

SELECT assign_task(3, 4);

SELECT * FROM task_assignment_history WHERE task_id = 3;





WITH task_id_param AS (
    SELECT 3 AS task_id  -- task_id
)

SELECT 
    t.task_name,
    th.status_name,
    th.change_date,
    ta.assigned_to,
    ta.assign_date
FROM 
    task t
JOIN task_id_param param ON t.task_id = param.task_id
LEFT JOIN 
    (SELECT tsh.task_id, ts.status_name, tsh.change_date 
     FROM task_status_history tsh 
     JOIN task_status ts ON tsh.status_id = ts.status_id) th ON t.task_id = th.task_id
LEFT JOIN 
    (SELECT tah.task_id, tm.name AS assigned_to, tah.assign_date 
     FROM task_assignment_history tah 
     JOIN team_member tm ON tah.member_id = tm.member_id) ta ON t.task_id = ta.task_id
ORDER BY 
    th.change_date, ta.assign_date;




INSERT INTO task (task_name, project_id) VALUES ('BacklogP3', 3);

DO $$
DECLARE
    new_task_id INT;
BEGIN
    SELECT task_id INTO new_task_id FROM task WHERE task_name = 'BacklogP3';

    INSERT INTO task_status_history (task_id, status_id, change_date)
    VALUES (new_task_id, (SELECT status_id FROM task_status WHERE status_name = 'ToDo'), CURRENT_DATE);

    INSERT INTO task_assignment_history (task_id, member_id, assign_date)
    VALUES (new_task_id, (SELECT member_id FROM project_team WHERE project_id = 3 AND role_id = (SELECT role_id FROM team_role WHERE role_name = 'Manager')), CURRENT_DATE);
END $$;

SELECT * FROM task



UPDATE project_team
SET role_id = CASE
    WHEN role_id = (SELECT role_id FROM team_role WHERE role_name = 'Dev') THEN
        (SELECT role_id FROM team_role WHERE role_name = 'Test')
    WHEN role_id = (SELECT role_id FROM team_role WHERE role_name = 'Test') THEN
        (SELECT role_id FROM team_role WHERE role_name = 'Dev')
    ELSE role_id
END
FROM project
WHERE project_team.project_id = project.project_id
AND project.project_name = 'P2';



