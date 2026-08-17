#!/bin/bash
set -uo pipefail

# Create the two databases the servers expect, then import the repo's schema dumps.
mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" <<'SQL'
CREATE DATABASE IF NOT EXISTS al_server_ls CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS al_server_gs CHARACTER SET utf8 COLLATE utf8_general_ci;
SQL

echo "Importing al_server_ls.sql"
mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" al_server_ls < /docker-entrypoint-initdb.d/sql/al_server_ls.sql
LS_RC=$?

echo "Importing al_server_gs.sql"
mysql --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" al_server_gs < /docker-entrypoint-initdb.d/sql/al_server_gs.sql
GS_RC=$?

echo "Database init complete. (ls rc=$LS_RC, gs rc=$GS_RC)"
exit 0