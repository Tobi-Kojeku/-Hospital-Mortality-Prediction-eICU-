SELECT name
FROM sqlite_master
WHERE type='table'
ORDER BY name;
PRAGMA table_info(apachepatientresult);
SELECT actualhospitalmortality, COUNT(*) AS cnt
FROM apachepatientresult
GROUP BY actualhospitalmortality
ORDER BY cnt DESC;
SELECT actualicumortality, COUNT(*) AS cnt
FROM apachepatientresult
GROUP BY actualicumortality
ORDER BY cnt DESC;
SELECT COUNT(*) AS rows_total,
       COUNT(DISTINCT patientunitstayid) AS stays_total
FROM apachepatientresult;
SELECT
  patientunitstayid,
  MAX(CASE WHEN actualhospitalmortality = 'EXPIRED' THEN 1 ELSE 0 END) AS y
FROM apachepatientresult
GROUP BY patientunitstayid;
WITH vitals_6h AS (
  SELECT patientunitstayid
  FROM vitalperiodic
  WHERE observationoffset BETWEEN 0 AND 360
  GROUP BY patientunitstayid
),
labels AS (
  SELECT
    patientunitstayid,
    MAX(CASE WHEN actualhospitalmortality='EXPIRED' THEN 1 ELSE 0 END) AS y
  FROM apachepatientresult
  GROUP BY patientunitstayid
)
SELECT COUNT(*) AS n_rows
FROM labels l
JOIN vitals_6h v
  ON v.patientunitstayid = l.patientunitstayid;
WITH labels AS (
  SELECT
    patientunitstayid,
    MAX(CASE WHEN actualhospitalmortality = 'EXPIRED' THEN 1 ELSE 0 END) AS y
  FROM apachepatientresult
  GROUP BY patientunitstayid
),
vitals_6h AS (
  SELECT
    patientunitstayid
  FROM vitalperiodic
  WHERE observationoffset BETWEEN 0 AND 360
  GROUP BY patientunitstayid
),
labs_6h AS (
  SELECT
    patientunitstayid
  FROM lab
  WHERE labresultoffset BETWEEN 0 AND 360
    AND labname IN ('bedside glucose','potassium','sodium','chloride','creatinine','bun','hemoglobin','lactate','bicarbonate')
  GROUP BY patientunitstayid
)
SELECT COUNT(*) AS n_rows
FROM labels l
JOIN vitals_6h v
  ON v.patientunitstayid = l.patientunitstayid
LEFT JOIN labs_6h x
  ON x.patientunitstayid = l.patientunitstayid;
WITH
labels AS (
  SELECT
    patientunitstayid,
    MAX(CASE WHEN actualhospitalmortality = 'EXPIRED' THEN 1 ELSE 0 END) AS y
  FROM apachepatientresult
  GROUP BY patientunitstayid
),
vitals_6h AS (
  SELECT
    patientunitstayid,
    MIN(systemicsystolic)   AS sys_min,
    MIN(temperature)       AS temp_min,
    MIN(sao2)               AS sao2_min,
    MIN(respiration)       AS rr_min,
    MIN(heartrate)         AS hr_min,
    MIN(cvp)                AS cvp_min,
    MIN(etco2)              AS etco2_min,
    MIN(systemicdiastolic) AS dia_min,
    MIN(systemicmean)      AS mean_min,
    MIN(pasystolic)        AS pa_sys_min,
    MIN(padiastolic)       AS pa_dia_min,
    MIN(pamean)            AS pa_mean_min,
    MIN(st1)               AS st1_min,
    MIN(st2)               AS st2_min,
    MIN(st3)               AS st3_min,
    MIN(icp)               AS icp_min
  FROM vitalperiodic
  WHERE observationoffset BETWEEN 0 AND 360
  GROUP BY patientunitstayid
),
labs_6h AS (
  SELECT
    patientunitstayid,
    MIN(CASE WHEN labname = 'bedside glucose' THEN labresult END) AS bedside_glucose_min,
    MIN(CASE WHEN labname = 'potassium' THEN labresult END)       AS potassium_min,
    MIN(CASE WHEN labname = 'sodium' THEN labresult END)          AS sodium_min,
    MIN(CASE WHEN labname = 'chloride' THEN labresult END)        AS chloride_min,
    MIN(CASE WHEN labname = 'creatinine' THEN labresult END)     AS creatinine_min,
    MIN(CASE WHEN labname = 'bun' THEN labresult END)             AS bun_min,
    MIN(CASE WHEN labname = 'hemoglobin' THEN labresult END)       AS hemoglobin_min,
    MIN(CASE WHEN labname = 'lactate' THEN labresult END)        AS lactate_min,
    MIN(CASE WHEN labname = 'bicarbonate' THEN labresult END)    AS bicarbonate_min
  FROM lab
  WHERE labresultoffset BETWEEN 0 AND 360
    AND labname IN ('bedside glucose','potassium','sodium','chloride','creatinine','bun','hemoglobin','lactate','bicarbonate')
  GROUP BY patientunitstayid
)
SELECT COUNT(*) AS n_rows
FROM labels l
JOIN vitals_6h v
  ON v.patientunitstayid = l.patientunitstayid
LEFT JOIN labs_6h x
  ON x.patientunitstayid = l.patientunitstayid;
