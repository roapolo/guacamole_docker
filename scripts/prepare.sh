#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
ENV_EXAMPLE="${ROOT_DIR}/.env.example"

if [[ ! -f "${ENV_FILE}" ]]; then
  cp "${ENV_EXAMPLE}" "${ENV_FILE}"
  echo "Se ha creado .env a partir de .env.example"
fi

set -a
source "${ENV_FILE}"
set +a

mkdir -p "${ROOT_DIR}/certs" "${ROOT_DIR}/init"

if [[ ! -f "${ROOT_DIR}/certs/tfg.key" || ! -f "${ROOT_DIR}/certs/tfg.crt" ]]; then
  openssl genrsa -out "${ROOT_DIR}/certs/tfg.key" 4096
  openssl req -x509 -new -nodes \
    -key "${ROOT_DIR}/certs/tfg.key" \
    -sha256 -days 3650 \
    -out "${ROOT_DIR}/certs/tfg.crt" \
    -subj "/CN=${CERT_CN}"
  echo "Certificado autofirmado generado con CN=${CERT_CN}"
fi

docker run --rm "guacamole/guacamole:${GUACAMOLE_VERSION}" \
  /opt/guacamole/bin/initdb.sh --mysql > "${ROOT_DIR}/init/01_guacamole_schema.sql"

cat > "${ROOT_DIR}/init/00_initdb.sql" <<SQL
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT SELECT,INSERT,UPDATE,DELETE ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

envsubst '\$SERVER_NAME' < "${ROOT_DIR}/nginx/default.conf.template" > "${ROOT_DIR}/nginx/default.conf"

echo "Proyecto preparado. Revisa .env y luego ejecuta: docker compose up -d"
