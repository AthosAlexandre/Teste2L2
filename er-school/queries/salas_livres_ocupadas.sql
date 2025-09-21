-- Lista de SALAS com INTERVALOS CONTÍNUOS livres/ocupados (sem slots)
-- Ajuste aqui a janela que deseja analisar:
WITH params AS (
  SELECT time '07:00' AS h_ini,
         time '22:00' AS h_fim
),

-- 1) Ordena agendas por sala/dia para podermos fundir sobreposições
ordenado AS (
  SELECT
    cs.room_id,
    r.name        AS room,
    cs.day_of_week::text AS day_of_week,
    cs.start_time,
    cs.end_time,
    -- running max do fim anterior (por sala/dia)
    MAX(cs.end_time) OVER (
      PARTITION BY cs.room_id, cs.day_of_week
      ORDER BY cs.start_time
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
    ) AS prev_end_max
  FROM class_schedule cs
  JOIN room r ON r.id = cs.room_id
),

-- 2) Marca o começo de um novo "bloco ocupado" quando o início atual fica DEPOIS do fim acumulado
marcado AS (
  SELECT *,
         CASE
           WHEN start_time > COALESCE(prev_end_max, start_time) THEN 1 ELSE 0
         END AS is_new_block
  FROM ordenado
),

-- 3) Soma cumulativa para criar "ilhas" (gaps & islands) e mesclar colisões
ocupado_merged AS (
  SELECT
    room_id, room, day_of_week,
    MIN(start_time) AS start_time,
    MAX(end_time)   AS end_time
  FROM (
    SELECT *,
           SUM(is_new_block) OVER (
             PARTITION BY room_id, day_of_week
             ORDER BY start_time
           ) AS grp
    FROM marcado
  ) x
  GROUP BY room_id, room, day_of_week, grp
),

-- 4) Gera intervalos LIVRES como os "gaps" entre os blocos ocupados,
--    também considerando as bordas [h_ini, h_fim]
livres AS (
  -- 4.1) gap inicial: da borda inicial até a 1ª ocupação
  SELECT
    m.room_id, m.room, m.day_of_week,
    (SELECT h_ini FROM params) AS start_time,
    m.start_time               AS end_time
  FROM ocupado_merged m
  WHERE (SELECT h_ini FROM params) < m.start_time

  UNION ALL
  -- 4.2) gaps do meio: entre o fim de um bloco e o começo do bloco seguinte
  SELECT
    m.room_id, m.room, m.day_of_week,
    m.end_time AS start_time,
    LEAD(m.start_time) OVER (
      PARTITION BY m.room_id, m.day_of_week
      ORDER BY m.start_time
    ) AS end_time
  FROM ocupado_merged m

  UNION ALL
  -- 4.3) gap final: do fim da última ocupação até a borda final
  SELECT
    m.room_id, m.room, m.day_of_week,
    m.end_time                 AS start_time,
    (SELECT h_fim FROM params) AS end_time
  FROM (
    SELECT *,
      ROW_NUMBER() OVER (PARTITION BY room_id, day_of_week ORDER BY start_time DESC) AS rn
    FROM ocupado_merged
  ) m
  WHERE m.rn = 1
    AND m.end_time < (SELECT h_fim FROM params)
),

-- 5) Filtra quaisquer gaps invertidos/nulos (podem ocorrer se não houver aulas)
livres_validos AS (
  SELECT * FROM livres WHERE end_time > start_time
),

-- 6) Ocupações recortadas pela janela [h_ini, h_fim] (caso alguma extrapole)
ocupado_janela AS (
  SELECT
    room_id, room, day_of_week,
    GREATEST(start_time, (SELECT h_ini FROM params)) AS start_time,
    LEAST(end_time,   (SELECT h_fim FROM params))    AS end_time
  FROM ocupado_merged
  WHERE end_time   > (SELECT h_ini FROM params)
    AND start_time < (SELECT h_fim FROM params)
)

-- 7) Resultado unificado
SELECT room, day_of_week, start_time, end_time, 'ocupado' AS status
FROM   ocupado_janela
UNION ALL
SELECT room, day_of_week, start_time, end_time, 'livre' AS status
FROM   livres_validos
ORDER BY room, day_of_week, start_time;
