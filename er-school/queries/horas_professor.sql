SELECT
  p.id,
  p.name AS professor,
  ROUND(SUM(EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)))/3600.0, 2) AS horas_semanais
FROM professor p
JOIN subject   s  ON s.professor_id = p.id
JOIN class     c  ON c.subject_id   = s.id
JOIN class_schedule cs ON cs.class_id = c.id
GROUP BY p.id, p.name
ORDER BY horas_semanais DESC, p.name;
