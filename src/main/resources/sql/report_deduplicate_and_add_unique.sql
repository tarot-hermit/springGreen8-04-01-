DELETE r1
FROM report r1
JOIN report r2
  ON r1.reporter_mid = r2.reporter_mid
 AND r1.target_type = r2.target_type
 AND r1.target_id = r2.target_id
 AND r1.report_id > r2.report_id;

ALTER TABLE report
    ADD CONSTRAINT uk_report_reporter_target
    UNIQUE (reporter_mid, target_type, target_id);

SELECT reporter_mid, target_type, target_id, COUNT(*) AS cnt
FROM report
GROUP BY reporter_mid, target_type, target_id
HAVING COUNT(*) > 1;