CREATE TYPE dow AS ENUM ('1','2','3','4','5','6','7'); -- 1=Seg, ... 7=Dom (ajuste como preferir)

-- Tabelas "cadastro"
CREATE TABLE department (
  id   SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE title (
  id   SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE professor (
  id            SERIAL PRIMARY KEY,
  name          TEXT NOT NULL,
  department_id INT  NOT NULL REFERENCES department(id),
  title_id      INT  NOT NULL REFERENCES title(id)
);

CREATE TABLE building (
  id   SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE room (
  id          SERIAL PRIMARY KEY,
  building_id INT NOT NULL REFERENCES building(id),
  name        TEXT NOT NULL,
  UNIQUE(building_id, name)
);

-- Disciplinas e pré-requisitos
CREATE TABLE subject (
  id           SERIAL PRIMARY KEY,
  code         TEXT NOT NULL UNIQUE,
  name         TEXT NOT NULL,
  professor_id INT  NOT NULL REFERENCES professor(id)  -- quem ministra a disciplina
);

CREATE TABLE subject_prerequisite (
  id             SERIAL PRIMARY KEY,
  subject_id     INT NOT NULL REFERENCES subject(id) ON DELETE CASCADE,
  prerequisite_id INT NOT NULL REFERENCES subject(id) ON DELETE CASCADE,
  CONSTRAINT subject_prereq_distinct UNIQUE(subject_id, prerequisite_id),
  CONSTRAINT subject_prereq_no_self CHECK (subject_id <> prerequisite_id)
);

-- Turmas de uma disciplina em certo ano/semestre
CREATE TABLE class (
  id         SERIAL PRIMARY KEY,
  subject_id INT  NOT NULL REFERENCES subject(id) ON DELETE CASCADE,
  year       INT  NOT NULL,
  semester   INT  NOT NULL CHECK (semester IN (1,2)),
  code       TEXT NOT NULL,         -- código da turma (ex.: A, B, 01...)
  UNIQUE(subject_id, year, semester, code)
);

-- Agenda da turma (salas, dia da semana, horários)
CREATE TABLE class_schedule (
  id         SERIAL PRIMARY KEY,
  class_id   INT  NOT NULL REFERENCES class(id) ON DELETE CASCADE,
  room_id    INT  NOT NULL REFERENCES room(id),
  day_of_week dow NOT NULL,
  start_time TIME NOT NULL,
  end_time   TIME NOT NULL,
  CHECK (end_time > start_time)
);

-- Índices úteis
CREATE INDEX idx_schedule_room_day ON class_schedule(room_id, day_of_week, start_time);
CREATE INDEX idx_schedule_class    ON class_schedule(class_id);
CREATE INDEX idx_subject_prof      ON subject(professor_id);
