FROM ubuntu:latest
WORKDIR /app/
COPY . .
ENTRYPOINT ["./entrypoint.sh"]
