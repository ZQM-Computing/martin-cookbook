# 04 — Service Deploy: Running Martin as a Service

> Status: design-only, gate 1 target. This pattern has not run.
> Exact config schema, CLI spelling, and service-manager steps are
> to confirm at validation on the target node and Martin version.

## What it demonstrates

Running Martin as a persistent service instead of a foreground
process: connection settings via config file or CLI flags (the
choice is version-dependent — see below), a health check that
actually proves serving (`/catalog` plus one tile, not just a
listening port), and the failure modes that distinguish a bad
connection from a bad source.

## Prerequisites + versions

- Martin **1.15.0 or 1.16.1**; Postgres with PostGIS.
- Version behavior that decides the deployment form
  (fleet-observed, design context only):
  - 1.15.0 rejects `--postgres` — do not pass it; use the version's
    supported connection form (config file).
  - 1.16.1 ignores the `srv` config key and takes CLI flags.
- Windows service manager NSSM for the service sketch (fleet
  pattern), or any supervisor you already run — the sketch uses
  placeholders, not fleet paths.
- Fleet port context only: Node-3 serves Martin on 3002 (not 3001).
  This pattern addresses Martin only as `<MARTIN_URL>` / `<PORT>`.

## Steps

1. Fill in `config.yaml` (placeholders only) or choose the CLI
   form in `deploy.sh` matching your Martin version.
2. Start Martin in the foreground first and prove health:

   ```bash
   bash deploy.sh run
   # then: curl <MARTIN_URL>/catalog (expect 200, sources listed)
   ```

3. Only after the foreground health check passes, install the
   persistent service with the sketch in `deploy.sh` (`service`
   subcommand) and re-run the same health checks against the
   service.

## Expected output

- Foreground run: Martin logs its listening address; `/catalog`
  returns 200 listing the configured table and/or function sources.
- One tile request for a known source returns MVT bytes (200).
- Service run: same two checks pass against the service, and the
  service stays running after you close the installing shell.
- Exact log lines, config schema, and CLI spelling are to confirm
  at validation; the checks above are the design expectation, not
  a recorded run.

## Failure behavior

- Startup exit with a connection error: the DSN is wrong, Postgres
  is down, or PostGIS is missing — fix the connection, do not
  re-create sources.
- `/catalog` 200 but a source missing: the source definition
  (table visibility, function signature) does not match the
  running version — see patterns 01–02, and check Martin's log for
  which sources it registered at startup.
- Port already bound: Martin exits with a bind error; pick a free
  port (3002 is fleet context, not a requirement).
- Service starts then stops: check the service log path first —
  NSSM services that die on a bad working directory or missing
  binary log nothing to the console, so the console's silence is
  not evidence the service is fine.

## To confirm at validation

- Config-file schema for the version used (connection key, table
  and function source blocks) vs CLI-flag spelling.
- The exact foreground command per version (1.15.0 vs 1.16.1).
- NSSM command spelling on the validation node (service name,
  paths, log paths are operator choices).
- Whether a dedicated health endpoint exists in the version used
  (this pattern uses `/catalog` as the health check, which is
  fleet-verified behavior).
