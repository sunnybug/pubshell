docker build -t mydev:gcc12 .
docker compose --env-file=$1 up -d