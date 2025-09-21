INSERT INTO department (name) VALUES ('Matemática'), ('Letras');
INSERT INTO title (name) VALUES ('Mestre'), ('Doutor');

INSERT INTO professor (name, department_id, title_id) VALUES
('Prof. Girafales', 2, 2),
('Prof. Jirafales Junior', 1, 1);

INSERT INTO building (name) VALUES ('Prédio A'), ('Prédio B');
INSERT INTO room (building_id, name) VALUES
(1,'101'),(1,'102'),(2,'201');

INSERT INTO subject (code, name, professor_id) VALUES
('PORT101','Português I', 1),
('MAT101','Cálculo I', 2);

INSERT INTO class (subject_id, year, semester, code) VALUES
(1, 2025, 1, 'A'),
(2, 2025, 1, 'A');

-- Seg=1, ... Sex=5
INSERT INTO class_schedule (class_id, room_id, day_of_week, start_time, end_time) VALUES
(1, 1, '1', '08:00','09:40'),
(1, 1, '3', '08:00','09:40'),
(2, 2, '2', '10:00','12:00'),
(2, 3, '4', '10:00','12:00');
