-- 02-function-source: synthetic points table + MVT function.
-- Geometries are small synthetic points around an arbitrary origin
-- (lon 0, lat 0 area): not a real place, not real data.
-- Function signature: to confirm at validation per Martin version
-- (argument names/types and query_params handling differ by version).

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

-- Parameterized MVT function: z/x/y tile coordinates plus an
-- optional minimum-value filter via query_params (spelling of the
-- params object is version-dependent: to confirm at validation).
CREATE OR REPLACE FUNCTION public.synthetic_points_fn(
  z integer, x integer, y integer,
  query_params json DEFAULT '{}'::json
) RETURNS bytea AS $$
  SELECT ST_AsMVT(tile, 'synthetic_points', 4096, 'geom') FROM (
    SELECT
      id, name, value,
      ST_AsMVTGeom(
        geom,
        ST_TileEnvelope(z, x, y),
        4096, 64, true
      ) AS geom
    FROM synthetic_points
    WHERE geom && ST_TileEnvelope(z, x, y)
      AND value >= COALESCE((query_params->>'min_value')::integer, 0)
  ) AS tile;
$$ LANGUAGE sql STABLE;
