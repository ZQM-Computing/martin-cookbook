"""Create a disposable synthetic table for Martin's live smoke test."""
import os
import psycopg

dsn = os.environ["DATABASE_URL"]
with psycopg.connect(dsn, autocommit=True) as conn:
    conn.execute("CREATE EXTENSION IF NOT EXISTS postgis")
    conn.execute("""
        CREATE TABLE IF NOT EXISTS public.places (
            id integer PRIMARY KEY,
            name text NOT NULL,
            geom geometry(Point, 4326) NOT NULL
        )
    """)
    conn.execute("TRUNCATE TABLE public.places")
    conn.execute("""
        INSERT INTO public.places (id, name, geom)
        VALUES (1, 'Synthetic test point', ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326))
    """)
print("Seeded one synthetic PostGIS feature.")
