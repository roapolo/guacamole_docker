# Apache Guacamole Docker

Proyecto listo para clonar y arrancar con Docker Compose.

## Incluye

- Apache Guacamole
- guacd
- MariaDB
- NGINX como proxy
- Redireccion de `80` a `443`
- Certificado autofirmado con `CN=TFG` por defecto

## Requisitos

- Docker
- Docker Compose v2
- `openssl`
- `envsubst` disponible en el sistema

## Uso rapido

```bash
cp .env.example .env
```

Edita `.env` y cambia como minimo:

- `MYSQL_ROOT_PASSWORD`
- `MYSQL_PASSWORD`
- `MYSQL_USER` si quieres otro distinto
- `MYSQL_DATABASE` si quieres otro nombre
- `SERVER_NAME`
- `CERT_CN`

Despues:

```bash
chmod +x scripts/prepare.sh
./scripts/prepare.sh
docker compose up -d
```

## Acceso

- HTTP: redirige automaticamente a HTTPS
- HTTPS: `https://TU_HOST/guacamole/`

## Notas

- El certificado es autofirmado.
- El script genera el esquema SQL oficial de Guacamole.
- Si cambias `SERVER_NAME`, vuelve a ejecutar `./scripts/prepare.sh`.
