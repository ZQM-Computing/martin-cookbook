-- 05-full-workflow: synthetic points table (same 12 points as
-- pattern 02's function input). Idempotent: safe to re-run.
-- Geometries are synthetic points around an arbitrary origin
-- (lon 0, lat 0 area): not a real place, not real data.

CREATE TABLE IF NOT EXISTS synthetic_points (
  id integer PRIMARY KEY,
  name text NOT NULL,
  value integer NOT NULL,
  geom geometry(Point, 4326) NOT NULL
);

INSERT INTO synthetic_points (id, name, value, geom) VALUES
  (1, 'alpha', 10, ST_SetSRID(ST_MakePoint(0.001, 0.001), 4326)),
  (2, 'bravo', 25, ST_SetSRID(ST_MakePoint(0.002, 0.001), 4326)),
  (3, 'charlie', 40, ST_SetSRID(ST_MakePoint(0.001, 0.002), 4326)),
  (4, 'delta', 55, ST_SetSRID(ST_MakePoint(0.003, 0.002), 4326)),
  (5, 'echo', 70, ST_SetSRID(ST_MakePoint(0.002, 0.003), 4326)),
  (6, 'foxtrot', 15, ST_SetSRID(ST_MakePoint(0.004, 0.001), 4326)),
  (7, 'golf', 30, ST_SetSRID(ST_MakePoint(0.001, 0.004), 4326)),
  (8, 'hotel', 45, ST_SetSRID(ST_MakePoint(0.004, 0.004), 4326)),
  (9, 'india', 60, ST_SetSRID(ST_MakePoint(0.003, 0.003), 4326)),
  (10, 'juliet', 75, ST_SetSRID(ST_MakePoint(0.005, 0.002), 4326)),
  (11, 'kilo', 90, ST_SetSRID(ST_MakePoint(0.002, 0.005), 4326)),
  (12, 'lima', 5, ST_SetSRID(ST_MakePoint(0.005, 0.005), 4326))
ON CONFLICT (id) DO NOTHING;
