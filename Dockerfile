FROM ubuntu:latest
RUN apt-get update -y && \
    apt-get -y autoremove && \
    apt-get clean \
    && apt-get install -y unzip \
    curl
WORKDIR /app/
COPY . .
ENTRYPOINT ["./entrypoint.sh"]
